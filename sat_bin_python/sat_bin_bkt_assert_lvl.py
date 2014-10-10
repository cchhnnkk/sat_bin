#!python
# -*- coding: utf-8 -*-

# 版本说明 #
# 去掉lvl_state的has_bkt
# 翻转：出现冲突时，学习子句中level最高的var值翻转，并将其level设置为
# 次高变量的level。如果直接发生冲突，将冲突的子句按照学习子句一样处理。
# 回退：回退时回退到次高level所在的bin。

import argparse
import logging
import os
import sys
from time import clock

# 全局变量便于调试
bin_manager = None
sat_engine = None
logger = None
TIME_OUT_LIMIT = 1000     # 执行时间限制，单位s

# 全局变量，在control中进行实例化
gen_debug_info = None

# dynamic选择开关
opt_dynamic_bin_choice = True
opt_dynamic_var_choice = True


class VarState(object):
    __slots__ = ['value', 'implied', 'level', 'activity', 'assign_bin']

    def __init__(self):

        self.value = 0           # 0:free 1:false 2:true 3:conflict
        self.implied = False     # Whether the variable is implied
        self.level = 0           # The decision level
        self.activity = 0        # var的活跃度
        self.assign_bin = 0         # The bin that assigned our decided var

    def __str__(self):
        str_info = " VarState {\n"
        str_info += "\tvalue : %s\n" % str(self.value)
        str_info += "\timplied : %s\n" % str(self.implied)
        str_info += "\tlevel : %s}\n" % str(self.level)
        return str_info

    def reset(self):
        self.value = 0
        self.implied = False
        self.level = 0
        self.activity = 0
        self.assign_bin = 0

    def get(self):
        return self.value, self.implied, self.level

    def set(self, value, implied, level, assign_bin):
        self.value = value
        self.implied = implied
        self.level = level
        self.assign_bin = assign_bin


class Clause(object):
    """ 子句 """

    def __init__(self):
        self.lits = []            # 文字列表
        self.islearnt = False     # 子句是否为学习子句
        self.activity = 0         # 子句的活跃值
        self.owner_bin  = -1      # 子句的所属的bin


class ClauseBin(object):
    """ 子句块 """

    def __init__(self, cmax, vmax, cbin, vbin):
        self.clauses   = []          # 类clause
        self.bram_cbin = []          # bram格式的clauses
        self.variables = []          # 打包的变量
        self.n_oc      = 0           # 打包时子句的个数，包括学习子句
        self.n_lc      = 0           # 新学习子句的个数
        self.base_lvl  = 0           # 新建bin时当前的层级
        self.cmax      = cmax
        self.vmax      = vmax
        self.init(cbin, vbin)

    def init(self, cbin, vbin):
        self.clauses = cbin
        self.variables = vbin
        self.n_oc = len(cbin)
        self.n_lc = 0
        self.cvt_to_bram_bin()

    def cvt_to_bram_c(self, lits):
        """ 将clauses转换成bram clause的形式 """
        c_bram = []
        for j in xrange(self.vmax):
            p = 0
            if j < len(self.variables):
                if self.variables[j] in lits:     # true
                    p = 2
                elif -self.variables[j] in lits:  # false
                    p = 1
            c_bram += [p]
        return c_bram

    def cvt_to_lits(self, bram_c):
        """ 将clauses转换成lits的形式 """
        lits = []
        for j in xrange(len(self.variables)):
            l = 0
            if bram_c[j] == 0:
                continue
            elif bram_c[j] == 1:     # false
                l = -self.variables[j]
            elif bram_c[j] == 2:     # true
                l = self.variables[j]
            lits += [l]
        return lits

    def cvt_to_bram_bin(self):
        """ 将cbin转换成bram clause array的形式 """
        for c in self.clauses:
            lits = c.lits
            c_bram = self.cvt_to_bram_c(lits)
            self.bram_cbin += [c_bram]

    def get_learntc_list(self):
        """返回lits格式的learntc列表"""
        learntc = []
        for i in xrange(self.n_lc):
            ci = self.n_oc + i
            self.clauses[ci].lits = self.cvt_to_lits(self.bram_cbin[ci]) 
            learntc += [self.clauses[ci]]
        return learntc


class ClauseArray(object):

    """Manage the clauses array and its state"""

    def __init__(self, cmax):
        self.cmax        = cmax
        self.cbin        = None     # 类ClauseBin
        self.clauses     = None     # 指向cbin的bram_cbin
        # clauses state #
        self.csat        = [False] * cmax
        self.cfreelit    = [0] * cmax
        self.c_max_lvl_i = [0] * cmax  # the max lvl of each clauses
                                       # use to find the implied lvl in bcp
        self.c_isreason  = [False] * cmax
        self.c_len       = [0] * cmax

        # dynamic adjust clause's activity
        self.cal_inc     = 1          # activity的每次增加值
        self.cal_decay   = 0.95       # activity的衰减值

    def __str__(self):
        str_info = "ClauseArray {\n"
        str_info += "\tcmax : %s\n" % str(self.cmax)
        # str_info += "\tclauses : %s\n" % str(self.clauses)
        str_info += "\tn_oc : %s\n" % str(self.cbin.n_oc)
        str_info += "\tn_lc : %s\n" % str(self.cbin.n_lc)
        str_info += "\tcsat : %s\n" % str(self.csat)
        str_info += "\tcfreelit : %s\n" % str(self.cfreelit)
        str_info += "\tc_max_lvl_i : %s\n" % str(self.c_max_lvl_i)
        str_info += "\tc_isreason : %s\n" % str(self.c_isreason)
        str_info += "\tc_len : %s}\n" % str(self.c_len)
        return str_info

    def reset_states(self):
        for i in xrange(len(self.csat)):
            self.csat[i] = False
            self.cfreelit[i] = 0
            self.c_max_lvl_i[i] = 0
            self.c_isreason[i] = False
            self.c_len[i] = 0

    def init_state(self, vs):
        """return conflict, ccindex"""

        self.reset_states()
        for i in xrange(len(self.clauses)):
            c = self.clauses[i]
            c_max_lvl = 0
            for j, v in enumerate(c):
                if v != 0 and j < len(vs):
                    if v == vs[j].value:
                        # the clause is sat
                        self.csat[i] = True
                        break
                    elif vs[j].value == 0:
                        self.cfreelit[i] += 1

                    if c_max_lvl < vs[j].level:
                        c_max_lvl = vs[j].level
                        self.c_max_lvl_i[i] = j

            # find conflict
            if self.csat[i] != 1 and self.cfreelit[i] == 0:
                return True, i

        return False, 0

    def update_state(self, vindex, vs):
        """ return conflict, ccindex """
        for i in xrange(len(self.clauses)):
            lit = self.clauses[i][vindex]
            if lit != 0:
                if lit == vs[vindex].value:
                    self.csat[i] = True

                if vs[vindex].value != 0:
                    self.cfreelit[i] -= 1
                    if self.cfreelit[i] == 0 and self.csat[i] is False:
                        # find conflict
                        return True, i

                    mindex = self.c_max_lvl_i[i]
                    if vs[mindex].level < vs[vindex].level:
                        self.c_max_lvl_i[i] = vindex
        return False, 0

    def find_learntc_inserti(self):
        if self.cbin.n_lc == self.cmax / 2:
            # 找到最长的子句，并且不是原因子句
            # # learnt clauses are full, find the longest learntc
            # # which is not reasonc
            # inserti = 0
            # max_len = 0
            # for i in xrange(self.cbin.n_lc):
            #     cindex = self.cbin.n_oc + i
            #     if self.c_isreason[i] is False \
            #             and max_len < self.c_len[cindex]:
            #         max_len = self.c_len[cindex]
            #         inserti = cindex
            # 找到活跃值最低的子句，并且不是原因子句
            inserti = 0
            min_act = self.cbin[self.cbin.n_oc].activity
            for i in xrange(self.cbin.n_lc):
                cindex = self.cbin.n_oc + i
                if self.c_isreason[i] is False \
                        and min_act > self.c_len[cindex]:
                    min_act = self.cbin[cindex].activity
                    inserti = cindex
        else:
            inserti = self.cbin.n_oc + self.cbin.n_lc
            c = Clause()
            self.clauses += [[]]
            self.cbin.clauses += [c]
            self.cbin.n_lc += 1
        return inserti

    def insert_learntc(self, learntc):
        inserti = self.find_learntc_inserti()
        # assert len(self.clauses[inserti]) == len(learntc)

        self.clauses[inserti] = learntc[:]

        c_len = 0
        for c in learntc:
            if c != 0:
                c_len += 1
        self.c_len[inserti] = c_len
        return inserti

    # 查找单元子句，返回子句和文字索引
    def find_unitc(self, vs):
        unitc_i = []
        for i, c in enumerate(self.clauses):
            if self.csat[i] is False and self.cfreelit[i] == 1:
                c = self.clauses[i]
                for j, v in enumerate(c):
                    if v != 0 and vs[j].value == 0:
                        # the free lit
                        unitc_i += [(i, j)]
                        break
        return unitc_i

    def decay_cal_inc(self):
        self.cal_inc *= (1 / self.cal_decay)

    def bump_cal_activity(self, ci):
        self.cbin.clauses[ci].activity += self.cal_inc


class LocalVars(object):

    """docstring for LocalVarStates"""

    def __init__(self, vmax):
        self.vs = []  # 在load时进行赋值

        self.conflict_tag = [0] * vmax   # 冲突标志，用于冲突分析中生成learntc
        self.reason = [0] * vmax         # 原因子句的编号
        self.global_var = None           # 指向var_bin的引用，在load_bin时赋值
        self.nv = 0                      # 变量个数，在load时进行赋值

        #dynamic choose vars
        self.var_inc        = 1          # activity的每次增加值
        self.var_decay      = 0.95       # activity的衰减值

    def reset_reason(self):
        for i in xrange(self.nv):
            self.reason[i] = 0

    def reset_conflict_tag(self):
        for i in xrange(self.nv):
            self.conflict_tag[i] = 0

    def decay_var_inc(self):
        self.var_inc *= (1 / self.var_decay)

    def bump_var_activity(self, vi):
        self.vs[vi].activity += self.var_inc

    def choose_next_var(self):
        max_acti = -1
        vi = -1
        l = ''
        # for i in xrange(self.nv):
        #     l += ' ' + str(self.vs[i].activity)
        # logger.info('\t\tactivity ' + l)
        # 查找一个free var且activity最大
        if opt_dynamic_bin_choice:
            for i in xrange(self.nv):
                if self.vs[i].value == 0 and self.vs[i].activity > max_acti:
                    max_acti = self.vs[i].activity
                    vi = i
        else:
            for i in xrange(self.nv):
                if self.vs[i].value == 0:
                    vi = i
                    break
        self.vs[vi].activity = 0

        return vi


class SatEngine(object):

    """ SatEngine """

    def __init__(self, cmax, vmax):
        cmax = cmax * 2
        self.cmax = cmax
        self.vmax = vmax
        self.cur_lvl = 1
        self.cur_bin = 1
        self.base_lvl = 1

        # vars state #
        self.local_vars = LocalVars(vmax)

        # clauses array #
        self.c_array = ClauseArray(cmax)

        # level state

        # bcp info
        self.need_bcp = False

        # conflict info
        self.conflict_fifo = []
        self.learntc = [0] * vmax

    def __str__(self):
        str_info = "SatEngine {\n"
        str_info += "\tcmax : %s\n" % str(self.cmax)
        str_info += "\tvmax : %s\n" % str(self.vmax)
        str_info += "\tcur_lvl : %s\n" % str(self.cur_lvl)
        str_info += "\tcur_bin : %s\n" % str(self.cur_bin)

        str_info += "\tc_array : %s\n" % str(self.c_array).replace('\t',
                                                                   '\t\t')
        str_info += "\tneed_bcp : %s\n" % str(self.need_bcp)
        str_info += "\tconflict_fifo : %s\n" % str(self.conflict_fifo)
        str_info += "\tlearntc : %s}\n" % str(self.learntc)
        return str_info

    def push_cclause_fifo(self, cindex, cur_lvl):
        self.c_array.bump_cal_activity(cindex)
        c = self.c_array.clauses[cindex]
        cctag = self.local_vars.conflict_tag
        for i in xrange(self.local_vars.nv):
            lit = c[i]
            vs = self.local_vars.vs[i]
            if lit != 0 and cctag[i] != 3:
                cctag[i] = 3
                # 当前层推理得到的变量加入conflict fifo
                if vs.level == cur_lvl and vs.implied == 1\
                        and self.local_vars.reason[i] != 0:
                    self.conflict_fifo += [i]
                else:
                    # 将文字添加到学习子句
                    self.learntc[i] = lit

            if vs.level == cur_lvl and vs.implied == 1\
                    and self.local_vars.reason[i] == 0:
                # 在load以后，一些变量的原因子句在其他bin中
                # 此时直接bcp()可能会进入这个分支
                # print self
                pass

    def decision(self, cur_bi):
        """ return allsat """
        logger.info('--\tdecision')
        global gen_debug_info
        gen_debug_info.cnt_decision += 1
        logger.info('\t\tcnt_decision: %d' % gen_debug_info.cnt_decision)

        # 如果所有的子句均已满足，则该bin为partial sat
        allsat = True
        for i in xrange(len(self.c_array.clauses)):
            if self.c_array.csat[i] is False:
                allsat = False
                break

        if allsat is True:
            logger.info('----\t\tpartial sat')
            return True

        # 遍历查找一个free var, 并且assign it false
        vi = self.local_vars.choose_next_var()
        if vi != -1:
            vs = self.local_vars.vs[vi]
            vs.value = 1
            vs.implied = False
            vs.level = self.cur_lvl
            vs.assign_bin = cur_bi

            if self.c_array.update_state(vi, self.local_vars.vs) is False:
                print 'this is impossible'
                sys.exit()
            str1 = '\t\tvar %d gvar %d value 1 level %d'\
                % (vi + 1, self.local_vars.global_var[vi], vs.level)
            logger.info(str1)
            self.need_bcp = True
            self.cur_lvl += 1
            return False

        print 'error in decision'
        for i in xrange(len(self.c_array.clauses)):
            if self.c_array.csat[i] is False:
                logger.debug('\t\tfalse c%d' % (i + 1))
                logger.debug(gen_debug_info.one_clause(self.c_array.clauses[i],
                                                       self.local_vars,
                                                       '\t\t'))
        sys.exit()
        # if kk_debug == 2: print '----\t\tpartial sat'
        # return True

    def bcp(self, cur_bi):
        """return conflict, conflict clause index, conflict var index"""
        logger.info('--\tbcp')
        global gen_debug_info
        gen_debug_info.cnt_bcp += 1
        logger.info('\t\tcnt_bcp: %d' % gen_debug_info.cnt_bcp)

        conflict, ccindex = self.c_array.init_state(self.local_vars.vs)
        if conflict is True:
            logger.info('\t\tfind conflict in c_array.init_state()')
            return True, ccindex, -1

        self.need_bcp = True
        while self.need_bcp:
            self.need_bcp = False
            c_array = self.c_array
            unitc_i = self.c_array.find_unitc(self.local_vars.vs)
            for i, j in unitc_i:
                c = self.c_array.clauses[i]  # unit clause
                vs = self.local_vars.vs[j]
                mindex = c_array.c_max_lvl_i[i]
                mvs = self.local_vars.vs[mindex]

                # 当出现一个文字出现多个推理时可以有几种不同的实现方式
                if vs.value != 0:  # 选择第一个推理的
                    continue
                # 选择最小层级推理的
                # if vs.value != 0 and self.local_vars.vs[mindex] > vs.level:
                #     continue

                vs.value = c[j]  # the free lit
                vs.level = mvs.level
                vs.implied = True
                vs.assign_bin = cur_bi
                self.local_vars.reason[j] = i + 1
                c_array.c_isreason[i] = True

                str1 = '\t\tc%d ' % (i + 1)
                str1 += 'var %d gvar %d '\
                    % (j + 1, self.local_vars.global_var[j])
                str1 += 'value %d level %d' % (c[j], vs.level)
                logger.info(str1)
                logger.debug(gen_debug_info.one_clause(self.c_array.clauses[i],
                                                       self.local_vars,
                                                       '\t\t'))
                conflict, ccindex = \
                    c_array.update_state(j, self.local_vars.vs)

                self.need_bcp = True
                if conflict is True:
                    # find conflict
                    return True, ccindex, j
        return False, 0, 0

    def find_bkt_lvl(self, clause):
        # find the max lvl to be bkt lvl
        bkt_lvl = 0
        for i, lit in enumerate(clause):
            if i >= self.local_vars.nv:
                break
            vs = self.local_vars.vs[i]
            if lit != 0 and bkt_lvl < vs.level:
                bkt_lvl = vs.level
                tag_i = i
        assert(len(clause) > 0)  # 子句长度的为1的情况待实现
        # find the convert lvl
        cvt_lvl = 0
        convert_bin = 0
        for i, lit in enumerate(clause):
            if i >= self.local_vars.nv:
                break
            vs = self.local_vars.vs[i]
            if lit != 0 and i != tag_i and cvt_lvl < vs.level:
                cvt_lvl = vs.level
        return bkt_lvl, cvt_lvl

    def analysis(self, ccindex, cvindex):
        logger.info('--\tanalysis the conflict')
        logger.info('\t\tconflict c%d' % (ccindex + 1))
        global gen_debug_info
        gen_debug_info.cnt_analysis += 1
        logger.info('\t\tcnt_analysis: %d' % gen_debug_info.cnt_analysis)
        logger.debug(gen_debug_info.one_clause(self.c_array.clauses[ccindex],
                                               self.local_vars,
                                               '\t\t'))
        self.local_vars.reset_conflict_tag()

        if cvindex != -1:  # -1是直接冲突产生的
            self.local_vars.conflict_tag[cvindex] = 3
            self.conflict_fifo += [cvindex]
        self.push_cclause_fifo(ccindex, self.cur_lvl - 1)
        if len(self.conflict_fifo) > 0:
            while len(self.conflict_fifo) > 0:
                v = self.conflict_fifo[0]
                del(self.conflict_fifo[0])
                assert self.local_vars.reason[v] > 0
                self.push_cclause_fifo(self.local_vars.reason[v] - 1,
                                       self.cur_lvl - 1)
            inserti = self.c_array.insert_learntc(self.learntc)
            for i in self.learntc:
                if i != 0:
                    self.local_vars.bump_var_activity(i)
            self.c_array.bump_cal_activity(inserti)
            gen_debug_info.cnt_learntc += 1
            logger.info('--\tthe learntc c%d %s'
                        % (inserti + 1,
                           gen_debug_info.convert_csr_clause(self.learntc)))
        else:
            # 冲突子句的变量的原因子句都在其他bin中，无法得到的学习子句
            # 此时的learntc等于ccindex
            logger.info('--\tno learntc')
            for i in self.c_array.clauses[ccindex]:
                if i != 0:
                    self.local_vars.bump_var_activity(i)
        self.c_array.decay_cal_inc()

        bkt_lvl, cvt_lvl = self.find_bkt_lvl(self.learntc)

        logger.info('\t\tbkt_lvl %d' % (bkt_lvl))

        self.learntc = [0] * self.vmax    # reset next learnt clause
        self.cur_lvl = bkt_lvl + 1
        return bkt_lvl, cvt_lvl

    # bin内回退
    def backtrack_cur_bin(self, bkt_lvl, cvt_lvl, cvt_bin):
        logger.info('--\tbacktrack_cur_bin: bkt_lvl == %d' % bkt_lvl)
        global gen_debug_info
        gen_debug_info.cnt_cur_bkt += 1
        logger.info('\t\tcnt_cur_bkt: %d' % gen_debug_info.cnt_cur_bkt)
        # backtrack the variables' states
        for i in xrange(self.local_vars.nv):
            vs = self.local_vars.vs[i]
            value = vs.value
            if value == 0:
                continue

            if vs.level == bkt_lvl and vs.implied is False:
                if value == 1:
                    value = 2
                else:
                    value = 1
                vs.set(value, True, cvt_lvl, cvt_bin)
                str1 = '\t\tvar %d gvar %d value %d level %d' % (
                    i + 1,
                    self.local_vars.global_var[i] + 1,
                    vs.value,
                    vs.level)
                logger.info(str1)
            elif vs.level >= bkt_lvl:
                # clear reason clause
                reasonc = self.local_vars.reason[i] - 1
                if reasonc > 0:
                    self.c_array.c_isreason[reasonc] = False

                vs.reset()

        self.cur_lvl = bkt_lvl + 1

    def run_core(self, cur_bi, next_lvl):
        """ return psat, next_bin, next_lvl, bkt_lvl, cvt_lvl """
        self.cur_lvl = next_lvl
        self.cur_bin = cur_bi
        logger.info('sat engine run_core: cur_bin == %d' % cur_bi)

        while 1:
            conflict, ccindex, cvindex = self.bcp(cur_bi)
            if conflict is False:
                # no conflict
                allsat = self.decision(cur_bi)
                if allsat:
                    # sat
                    return True, cur_bi + 1, self.cur_lvl, 0, 0     # next bin index
            else:
                # conflict
                bkt_lvl, cvt_lvl = self.analysis(ccindex, cvindex)
                self.local_vars.decay_var_inc()
                if bkt_lvl < self.base_lvl:      # partial unsat
                    logger.info('----\t\tpartial unsat')
                    return False, 0, bkt_lvl + 1, bkt_lvl, cvt_lvl
                else:
                    self.backtrack_cur_bin(bkt_lvl, cvt_lvl, cur_bi)


class BinPacker(object):

    """动态decomposition the cnf，打包成bin"""

    # todo 学习子句的删除，当学习子句非常多时，等先测试后再实现

    def __init__(self, bin_cmax, bin_vmax):
        self.clause_db  = []          # 子句类clause
        self.cbins      = []          # 打包的子句
        self.ci_bins    = []          # 打包的子句的索引
        self.nc         = 0           # total clauses Num
        self.nv         = 0           # total vars Num
        self.nb         = 0           # total bins Num
        self.bin_cmax   = bin_cmax
        self.bin_vmax   = bin_vmax

    def init(self, filename):
        """初始化clause_db等"""
        cnf = [l.strip().split() for l in file(filename) if l[0] not in 'c%0\n']
        clauses_list = [[int(x) for x in m[:-1]] for m in cnf if m[0] != 'p']
        self.nv = [int(n[2]) for n in cnf if n[0] == 'p'][0]
        self.nc = len(clauses_list)
        for lits in clauses_list:
            c = Clause()
            c.lits = lits
            self.clause_db += [c]
        self.vars_act = [0] * self.nv

    def push_bin(self, cbin, packci):
        self.nb += 1
        if self.nb <= len(self.cbins):
            self.cbins[self.nb - 1] = cbin
            self.ci_bins[self.nb - 1] = packci
        else:
            self.cbins += [cbin]
            self.ci_bins += [packci]

    def pack_new_bin(self):
        """打包新的bin，如果没有子句可打包返回False，否则True"""
        cbin = []
        vbin = set()
        new_cbin = []
        new_vbin = set()
        packci = []
        while True:
            # 找到最大activity的还没有打包的子句
            max_act = -1
            max_c = None
            for i, c in enumerate(self.clause_db):
                if c.owner_bin == -1 and c.activity > max_act:
                    max_act = c.activity
                    max_c = self.clause_db[i]
                    packi = i
            if max_act == -1:
                break
            new_cbin += [max_c]
            vset = set()
            for lit in max_c.lits:
                v = abs(lit)
                vset.add(v)
            new_vbin |= vset
            if len(new_cbin) > self.bin_cmax/2 or len(new_vbin) > self.bin_vmax:
                break
            max_c.owner_bin = self.nb + 1
            cbin += [max_c]
            vbin |= vset
            packci += [packi+1]
        vbin = sorted(list(vbin))
        if cbin == []:
            return False
        # ClauseBin
        clause_bin = ClauseBin(self.bin_cmax, self.bin_vmax, cbin, vbin)
        self.push_bin(clause_bin, packci)
        # logger.info('pack_new_bin %d ' % (self.nb))
        # for ci in packci:
        #    logger.info('\tgc%d %s' % (ci, str(self.clause_db[ci-1].lits)))
        return True

    def clear_bin(self, bkt_bi):
        """回退清除bin，并将子句状态及学习子句记录到子句库中"""
        for i in xrange(bkt_bi, self.nb):
            for c in self.cbins[i].clauses:
                c.owner_bin = -1
            learntc_list = self.cbins[i].get_learntc_list()
            for c in learntc_list:
                self.clause_db += [c]
        self.nb = bkt_bi


class BinManager(object):

    """manage the bins to be solved"""

    def __init__(self, cmax, vmax):
        self.global_vs    = []
        self.cmax         = cmax
        self.vmax         = vmax
        self.bin_packer   = BinPacker(cmax, vmax)

        # 每一层赋值变量的个数，每次回退会导致低层次的个数增加
        self.lvl_dcd_cnt = []

    # --------------------------------------------------------
    def init_bins(self, filename):
        self.bin_packer.init(filename)
        for i in xrange(self.bin_packer.nv):
            self.global_vs += [VarState()]
        self.init_var_activity()
        self.init_cal_activity()
        self.lvl_dcd_cnt = [0] * self.bin_packer.nv 

    def init_var_activity(self):
        """初始化变量的activity值"""
        # 根据var出现的次数
        for c in self.bin_packer.clause_db:
            for l in c.lits:
                v = abs(l)
                self.global_vs[v - 1].activity += 1

    def init_cal_activity(self):
        """初始化变量和子句的activity值"""
        # 根据变量的重要性来
        # 改进的话，也可以通过图分割的理论来
        for c in self.bin_packer.clause_db:
            for l in c.lits:
                v = abs(l)
                c.activity += self.global_vs[v - 1].activity

    def load_bin(self, bin_i, next_lvl, sat_engine):
        """load clause bin data to sat engine"""
        logger.info('\n===============================================\n')
        global gen_debug_info
        gen_debug_info.cnt_load += 1
        logger.info('load_bin %d' % (bin_i + 1))
        logger.info('\tcnt_load %d' % (gen_debug_info.cnt_load))
        assert isinstance(sat_engine, SatEngine)
        assert bin_i >= 0
        sat_engine.c_array.cbin = self.bin_packer.cbins[bin_i]
        sat_engine.c_array.clauses = sat_engine.c_array.cbin.bram_cbin
        vbin = self.bin_packer.cbins[bin_i].variables
        sat_engine.local_vars.global_var = vbin
        sat_engine.cur_bin = bin_i
        sat_engine.cur_lvl = next_lvl
        sat_engine.base_lvl = self.bin_packer.cbins[bin_i].base_lvl

        # load var states
        sat_engine.local_vars.nv = len(vbin)
        local_vs = []
        for i in xrange(self.vmax):
            if i < sat_engine.local_vars.nv:
                v = vbin[i]
                local_vs += [self.global_vs[v - 1]]
                assert(local_vs[i].value != 3)

        sat_engine.local_vars.vs = local_vs
        sat_engine.local_vars.reset_reason()

        if logger.level <= logging.INFO:
            logger.info(gen_debug_info.bin_clauses(
                bin_i,
                sat_engine,
                self.bin_packer.cbins[bin_i].variables))
        if logger.level <= logging.NOTSET:
            logger.info(gen_debug_info.bin_clauses_sv(sat_engine))

    def update_bin(self, bin_i, conflict, sat_engine):
        """ update sat engine's result to clauses bins """
        global gen_debug_info
        gen_debug_info.cnt_update += 1
        logger.info('update_bin %d' % (bin_i + 1))
        logger.info('\tcnt_update %d' % (gen_debug_info.cnt_update))

        # update var states，因为是引用的形式，所以不用更新
        # 只有当没有冲突时才更新，发生冲突的bin是unsat的，不需要
        # if conflict is False:
        #     for i in xrange(sat_engine.local_vars.nv):
        #         v = self.vars_bins[bin_i][i]
        #         self.global_vs[v] = sat_engine.local_vars.vs[i]

        if conflict is False:
            if logger.level <= logging.INFO:
                logger.info(gen_debug_info.bin_clauses(
                    bin_i,
                    sat_engine,
                    self.bin_packer.cbins[bin_i].variables))
            if logger.level <= logging.NOTSET:
                logger.info(gen_debug_info.bin_clauses_sv(sat_engine))

    def backtrack_across_bin(self, bkt_lvl, cvt_lvl):
        """ return bkt_bi, cvt_bin """
        str1 = '--\tbacktrack_across_bin: bkt_lvl == %d' % bkt_lvl
        logger.info(str1)
        gen_debug_info.cnt_across_bkt += 1
        # print [l.value for l in self.global_vs]
        # 得到bkt_bi, cvt_bin
        bkt_bin = 0
        cvt_bin = 0
        for i, vs in enumerate(self.global_vs):
            value = vs.value
            gen_debug_info.cnt_gbkt_visit_vs += 1
            if value == 0:
                continue
            if vs.level == bkt_lvl and vs.implied is False:
                bkt_bin = vs.assign_bin
            if vs.level == cvt_lvl and vs.implied is False:
                cvt_bin = vs.assign_bin
        print ''
        print 'value     ', [l.value for l in self.global_vs]
        print 'imply     ', [int(l.implied) for l in self.global_vs]
        print 'level     ', [l.level for l in self.global_vs]
        print 'assign_bin', [l.assign_bin for l in self.global_vs]
        print 'bkt_lvl bkt_bin', bkt_lvl, bkt_bin
        print 'cvt_lvl cvt_bin', cvt_lvl, cvt_bin
        print ''
        # 清除全局变量状态
        for i, vs in enumerate(self.global_vs):
            value = vs.value
            gen_debug_info.cnt_gbkt_visit_vs += 1
            if value == 0:
                continue
            if vs.level == bkt_lvl and vs.implied is False:
                if value == 1:
                    value = 2
                else:
                    value = 1
                vs.set(value, True, cvt_lvl, cvt_bin)
                gen_debug_info.cnt_gbkt_clear_vs += 1
                str1 = '\t\tgvar %d value %d level %d' % (
                    i + 1,
                    vs.value,
                    vs.level)
                logger.info(str1)
            elif vs.level >= bkt_lvl:
                vs.set(0, False, 0, 0)
                gen_debug_info.cnt_gbkt_clear_vs += 1

        # 清除全局变量状态
        self.bin_packer.clear_bin(bkt_bin)
        return bkt_bin

    def compute_lvl_dcd_cnt(self):
        print [l.level for l in self.global_vs]
        next_cnt = [0] * self.bin_packer.nv 
        for i in xrange(self.bin_packer.nv):
            if self.global_vs[i].value != 0:
                lvl = self.global_vs[i].level
                next_cnt[lvl - 1] += 1

        if logger.level <= logging.DEBUG:
            ltemp = '  level   '
            stemp = '  dcd_cnt '
            for i in xrange(lvl):
                ltemp += '%3d' % (i + 1)
                stemp += '%3d' % int(next_cnt[i])
            # logger.info(ltemp)
            logger.info(stemp)
            print stemp

        next_bigger = False
        for i in xrange(self.bin_packer.nv):
            if next_cnt > self.lvl_dcd_cnt:
                next_bigger = True
                break
        assert(next_bigger)
        self.lvl_dcd_cnt = next_cnt


    def test(self, filename):
        cnf = [l.strip().split() for l in file(filename) if l[0] not in 'c%0\n']
        clauses_list = [[int(x) for x in m[:-1]] for m in cnf if m[0] != 'p']
        print ''
        sat_model = []
        for i, l in enumerate(self.global_vs):
            v = i + 1
            if l.value == 1:
                sat_model += [-v]
            elif l.value == 2:
                sat_model += [v]
            else:
                sat_model += [0]
        # print sat_model
        # for c in self.bin_packer.clause_db:
        #     print c.lits

        var_value = [l.value for l in self.global_vs]
        for i, lits in enumerate(clauses_list):
            strv = ''
            c_sat = False
            for lit in lits:
                v = abs(lit)
                strv += ' ' + str(var_value[v - 1])
                if lit > 0 and var_value[v - 1] == 2 \
                        or lit < 0 and var_value[v - 1] == 1:
                    c_sat = True
                    strl = '%4d %4d' % (lit, sat_model[v - 1])
                    break
            # print strl, lits, strv
            if c_sat is False:
                print 'test fail'
                print 'clauses', i + 1, lits
                c = self.bin_packer.clause_db[i]
                print 'clauses', i + 1, c.lits
                print 'owner_bin', c.owner_bin
                print ''
                return
        logger.info('test success\n')
        print 'test success\n'


class GenDebugInfo(object):

    """docstring for GenDebugInfo"""

    def __init__(self, bin_manager):
        self.bin_manager = bin_manager

        self.cnt_across_bkt = 0
        self.cnt_load = 0
        self.cnt_update = 0

        self.cnt_decision = 0
        self.cnt_bcp = 0
        self.cnt_cur_bkt = 0
        self.cnt_analysis = 0
        self.cnt_learntc = 0

        # 记录回退时访问var states的次数，info
        self.cnt_gbkt_visit_vs = 0
        # 实际清除的次数
        self.cnt_gbkt_clear_vs = 0

    def __str__(self):
        str_info = "\nGenDebugInfo\n"
        str_info += "  cnt_load          : %s\n" % str(self.cnt_load)
        str_info += "  cnt_update        : %s\n" % str(self.cnt_update)
        str_info += "  cnt_across_bkt    : %s\n" % str(self.cnt_across_bkt)
        str_info += "  cnt_gbkt_visit_vs : %s\n" % str(self.cnt_gbkt_visit_vs)
        str_info += "  cnt_gbkt_clear_vs : %s\n" % str(self.cnt_gbkt_clear_vs)
        str_info += "  cnt_decision      : %s\n" % str(self.cnt_decision)
        str_info += "  cnt_bcp           : %s\n" % str(self.cnt_bcp)
        str_info += "  cnt_cur_bkt       : %s\n" % str(self.cnt_cur_bkt)
        str_info += "  cnt_analysis      : %s\n" % str(self.cnt_analysis)
        str_info += "  cnt_learntc       : %s\n" % str(self.cnt_learntc)
        str_info += "  num_bins          : %s\n" % str(self.bin_manager.bin_packer.nb)
        str_info += "  num_clauses       : %s\n" % str(self.bin_manager.bin_packer.nc)
        str_info += "  num_vars          : %s\n" % str(self.bin_manager.bin_packer.nv)
        str_info += "  cmax              : %s\n" % str(self.bin_manager.cmax)
        str_info += "  vmax              : %s\n" % str(self.bin_manager.vmax)
        return str_info

    def one_clause(self, c, local_vars, strtab):
        vs = local_vars.vs
        cc = []
        value = []
        implied = []
        level = []
        bini = []
        has_bkt = []
        reason = []
        for i in xrange(len(c)):
            var = i + 1
            if c[i] != 0:
                if c[i] == 1:
                    var = -var
                cc += [var]
                value += [vs[i].value]
                implied += [vs[i].implied]
                level += [vs[i].level]
                bini += [vs[i].assign_bin]
                reason += [local_vars.reason[i]]
        str1 = ''
        str1 += '%slits    %s\n' % (strtab, cc)
        str1 += '%svalue   %s\n' % (strtab, value)
        str1 += '%simplied %s\n' % (strtab, [int(l) for l in implied])
        str1 += '%slevel   %s\n' % (strtab, level)
        str1 += '%sbin     %s\n' % (strtab, bini)
        str1 += '%sreason  %s\n' % (strtab, reason)
        return str1

    def bin_clauses(self, bin_i, sat_engine, variables):
        clauses = sat_engine.c_array.clauses
        vs = sat_engine.local_vars.vs
        ci = 1
        str1 = ''
        ci_bin = bin_manager.bin_packer.ci_bins[bin_i]
        str1 += '\tglobal cid\n'
        for i in ci_bin:
            str1 += '\t\tgc%d ' % (i)
            if i <= len(bin_manager.bin_packer.clause_db):
                str1 += str(bin_manager.bin_packer.clause_db[i-1].lits)
            str1 += '\n'
        for c in clauses:
            strc = '\tc%d  ' % ( ci)
            # print len(c), len(variables)
            for i in xrange(len(variables)):
                # var = variables[i]+1
                var = i + 1
                if c[i] == 1:
                    strc += str(-var) + ' '
                elif c[i] == 2:
                    strc += str(var) + ' '
            str1 += strc + '\n'
            ci += 1
        str1 += '\tglobal vars %s\n' % [l for l in variables]
        str1 += '\tlocal vars  %s\n' % [l + 1 for l in range(len(variables))]
        str1 += '\tvar_state_list:\n'
        str1 += '\tvalue       %s\n' % [l.value for l in vs]
        str1 += '\timplied     %s\n' % [int(l.implied) for l in vs]
        str1 += '\tlevel       %s\n' % [l.level for l in vs]
        str1 += '\tassign_bin  %s\n' % [l.assign_bin for l in vs]
        str1 += '\tctrl:\n'
        str1 += '\tcur_bin_num : %d\n' % (sat_engine.cur_bin + 1)
        str1 += '\tcur_lvl     : %d\n' % sat_engine.cur_lvl
        return str1

    def bin_clauses_sv(self, sat_engine):
        # return
        clauses = sat_engine.c_array.clauses
        vs = sat_engine.local_vars.vs
        cmax = sat_engine.cmax
        vmax = sat_engine.vmax
        ci = 1
        str1 = ''
        str_bin = "\tbin = '{\n"
        for ci in xrange(cmax):
            if ci < len(clauses):
                c = clauses[ci]
            else:
                c = [0] * vmax
            strc = "\t\t'{"
            # print len(c), len(variables)
            for vi in xrange(vmax):
                if vi < len(c):
                    var = c[vi]
                else:
                    var = 0
                strc += str(var)
                if vi != vmax - 1:
                    strc += ', '
            if ci != cmax - 1:
                str_bin += strc + '},\n'
            else:
                str_bin += strc + '}\n'

        str_bin += '\t};\n'

        str1 = str_bin

        str1 += '\t//var state list:\n'
        str1 += '\tvalue      = %s\n' % [l.value for l in vs]
        str1 += '\timplied    = %s\n' % [int(l.implied) for l in vs]
        str1 += '\tlevel      = %s\n' % [l.level for l in vs]
        str1 += '\tassign_bin = %s\n' % [l.assign_bin for l in vs]

        str1 += '\t//ctrl\n'
        str1 += '\tcur_bin_num = %d;\n' % (sat_engine.cur_bin + 1)
        str1 += '\tload_lvl = %d;\n' % (sat_engine.cur_lvl - 1)

        str1 = str1.replace('= [', "= '{")
        str1 = str1.replace(']\n', '};\n')
        return str1

    def convert_csr_clause(self, c):
        l = []
        for i in xrange(len(c)):
            if c[i] != 0:
                var = i + 1
                if c[i] == 1:
                    l += [-var]
                elif c[i] == 2:
                    l += [var]
        return l

    def csr_clause_str(self, c, varl):
        strc = ''
        for i in xrange(len(varl)):
            if varl[i] != 0:
                var = varl[i] + 1
                if c[i] == 1:
                    strc += str(-var) + ' '
                elif c[i] == 2:
                    strc += str(var) + ' '
        return strc


def control(filename, bin_cmax, bin_vmax):
    """总体控制"""
    starttime = clock()
    global bin_manager
    global sat_engine
    bin_manager = BinManager(bin_cmax, bin_vmax)
    bin_manager.init_bins(filename)
    sat_engine = SatEngine(bin_manager.cmax, bin_manager.vmax)
    global gen_debug_info
    gen_debug_info = GenDebugInfo(bin_manager)

    if bin_manager.bin_packer.pack_new_bin() is False:
        print 'no clause'
    bin_i = 1
    next_lvl = 1
    while True:
            bin_manager.load_bin(bin_i - 1, next_lvl, sat_engine)
            if gen_debug_info.cnt_load == 34:
                pass
            psat, next_bi, next_lvl, bkt_lvl, cvt_lvl = \
                sat_engine.run_core(bin_i, next_lvl)
            # print gen_debug_info.cnt_load, bin_manager.bin_packer.clause_db[3].owner_bin
            conflict = False
            if not psat:
                # partial unsat
                if bkt_lvl == 0:
                    logger.info('\nunsatisfiable')
                    print '\nunsatisfiable'
                    return 'unsat'
                bkt_bi = bin_manager.backtrack_across_bin(bkt_lvl, cvt_lvl)
                conflict = True
                next_lvl = bkt_lvl
                next_bi = bkt_bi
                bin_manager.compute_lvl_dcd_cnt()
            else:
                if bin_manager.bin_packer.pack_new_bin() is False:
                    break
                next_bi = bin_manager.bin_packer.nb
                bin_manager.bin_packer.cbins[next_bi - 1].base_lvl = next_lvl

            bin_manager.update_bin(bin_i - 1, conflict, sat_engine)

            bin_i = next_bi
            curtime = clock()
            if curtime - starttime > TIME_OUT_LIMIT:
                logger.critical('time out')
                return 'time out'

    logger.info('\nsatisfiable')
    print '\nsatisfiable'

    logger.info('\nresult model')
    str_var_value = '\t'
    for i, vs in enumerate(bin_manager.global_vs):
        assert(vs.value != 3)
        var = i + 1
        if vs.value == 1:
            var = -var
        str_var_value += str(var) + ' '
    logger.info(str_var_value)

    # test the satisfiability
    bin_manager.test(filename)

    for i in xrange(bin_manager.bin_packer.nb):
        ci_bin = bin_manager.bin_packer.ci_bins[i]
        logger.info('bin %d %s' % (i + 1, str(ci_bin)))
    return 'sat'


def set_logging_file(level=logging.WARNING):
    logging.basicConfig(filename=os.path.join(os.getcwd(), 'debug.info.log'),
                        format='',
                        filemode='w')
    global logger
    logger = logging.getLogger()
    logger.setLevel(level)
    print "view debug.info.log for more"


def set_logging_console(level=logging.WARNING):
    logging.basicConfig(format='')
    global logger
    logger = logging.getLogger()
    logger.setLevel(level)
    # logger.info('ee')
    # sys.exit()

# 定义日志级别为WARNING级别
# CRITICAL    50
# ERROR       40
# WARNING     30
# INFO        20
# DEBUG       10
# NOTSET      0

loglevel = logging.WARNING
log2file = False


def run(filename, bin_cmax, bin_vmax):
    strl = ["NOTSET", "INFO", "DEBUG", "WARNING", "ERROR", "CRITICAL"]
    print "the loglevel is %s" % strl[loglevel / 10]

    if log2file:
        set_logging_file(loglevel)
    else:
        set_logging_console(loglevel)

    control(filename, bin_cmax, bin_vmax)
    print str(gen_debug_info)
    if log2file:
        logger.debug(str(gen_debug_info))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename',
                        type=str,
                        help='input filename',
                        default='testdata/uf20-91/uf20-01.cnf'
                        )
    parser.add_argument('--cmax',
                        type=int,
                        help='default:8; bin的子句最大个数',
                        default=8
                        )
    parser.add_argument('--vmax',
                        type=int,
                        help='default:8; bin的变量最大个数',
                        default=8
                        )
    parser.add_argument('--log2file',
                        type=int,
                        help='default:0; 1:输出到file；0:输出到console',
                        default=0
                        )
    parser.add_argument('--loglevel',
                        type=int,
                        help="""0-50; default: 30;
                                # CRITICAL = 50
                                # ERROR    = 40
                                # WARNING  = 30
                                # INFO     = 20
                                # DEBUG    = 10
                                # NOTSET   = 0""",
                        default=logging.WARNING
                        )
    args = parser.parse_args()
    filename = args.filename
    bin_cmax = args.cmax
    bin_vmax = args.cmax

    # print args.info
    # return

    global loglevel, log2file
    loglevel = args.loglevel
    log2file = args.log2file

    log2file = 1
    # loglevel = logging.CRITICAL
    # loglevel = logging.WARNING
    # loglevel = logging.INFO
    loglevel = logging.DEBUG
    # loglevel = logging.NOTSET
    # logfile = True
    # filename = 'testdata/uf50-91/uf50-02.cnf'
    # filename = "testdata/uuf50-218/uuf50-01.cnf"
    bin_vmax = 8
    bin_cmax = bin_vmax # * 2
    run(filename, bin_cmax, bin_vmax)


if __name__ == '__main__':
    # import profile
    start = clock()
    # profile.run("main()")
    main()
    finish = clock()
    print 'runtime: %lfs' % (finish - start)
