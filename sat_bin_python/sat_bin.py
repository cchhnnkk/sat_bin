#!python
# -*- coding: utf-8 -*-

# 版本说明 #
# 使用lvl state结构来保存decided var, bin, and has_bkt
# 没有implication graph

import argparse
import logging
import os
import sys
from time import clock

# 全局变量便于调试
bin_manager = None
sat_engine = None
logger = None
CNT_ACROSS_BKT = 100    # 控制print_bkted_lvl打印输出的间隔
TIME_OUT_LIMIT = 10     # 执行时间限制，单位s

# 全局变量，在control中进行实例化
gen_debug_info = None


class VarState(object):
    __slots__ = ['value', 'implied', 'level']

    def __init__(self):

        self.value = 0        # 0:free 1:false 2:true 3:conflict
        self.implied = False  # Whether the variable is implied
        self.level = 0        # The decision level

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

    def get(self):
        return self.value, self.implied, self.level

    def set(self, value, implied, level):
        self.value = value
        self.implied = implied
        self.level = level


class LvlState(object):
    __slots__ = ['dcd_bin', 'has_bkt']

    def __init__(self):
        # 去掉了dcd_var，只需记录dcd_bin记录就可找到dcd_var
        self.dcd_bin = 0        # The bin that assigned our decided var
        self.has_bkt = False    # True/False

    def __str__(self):
        str_info = "LvlState {\n"
        str_info += "\tdcd_bin : %s\n" % str(self.dcd_bin)
        str_info += "\thas_bkt : %s}\n" % str(self.has_bkt)
        return str_info

    def reset(self):
        self.dcd_bin = 0
        self.has_bkt = False

    def get(self):
        return self.dcd_bin, self.has_bkt

    def set(self, dcd_bin, has_bkt):
        self.dcd_bin = dcd_bin
        self.has_bkt = has_bkt


class ClauseArray(object):

    """Manage the clauses array and its state"""

    def __init__(self, cmax):
        self.cmax = cmax
        self.clauses = None
        self.n_oc = 0
        self.n_lc = 0

        # clauses state #
        self.csat = [False] * cmax
        self.cfreelit = [0] * cmax
        self.c_max_lvl_i = [0] * cmax  # the max lvl of each clauses
                                       # use to find the implied lvl in bcp
        self.c_isreason = [False] * cmax
        self.c_len = [0] * cmax

    def __str__(self):
        str_info = "ClauseArray {\n"
        str_info += "\tcmax : %s\n" % str(self.cmax)
        str_info += "\tclauses : %s\n" % str(self.clauses)
        str_info += "\tn_oc : %s\n" % str(self.n_oc)
        str_info += "\tn_lc : %s\n" % str(self.n_lc)
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
        """
        return conflict, ccindex
        """
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
        if self.n_lc == self.cmax / 2:
            # learnt clauses are full, find the longest learntc
            # which is not reasonc
            inserti = 0
            max_len = 0
            for i in xrange(self.n_lc):
                cindex = self.n_oc + i
                if self.c_isreason[i] is False \
                        and max_len < self.c_len[cindex]:
                    max_len = self.c_len[cindex]
                    inserti = cindex
        else:
            inserti = self.n_oc + self.n_lc
            self.clauses += [[]]
            self.n_lc += 1
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


class LocalVars(object):

    """docstring for LocalVarStates"""

    def __init__(self, vmax):
        self.vs = []  # 在load时进行赋值

        self.conflict_tag = [0] * vmax   # 冲突标志，用于analysis中生成learntc
        self.reason = [0] * vmax         # 原因子句的编号
        self.global_var = None           # 指向var_bin的引用，在load_bin时赋值
        self.nv = 0                      # 变量个数，在load时进行赋值

    def reset_reason(self):
        for i in xrange(self.nv):
            self.reason[i] = 0

    def reset_conflict_tag(self):
        for i in xrange(self.nv):
            self.conflict_tag[i] = 0


class SatEngine(object):

    """
    docstring for SatEngine
    """

    def __init__(self, cmax, vmax):

        cmax = cmax * 2
        self.cmax = cmax
        self.vmax = vmax
        self.cur_lvl = 1
        self.cur_bin = 1

        # vars state #
        self.local_vars = LocalVars(vmax)

        # clauses array #
        self.c_array = ClauseArray(cmax)

        # level state
        self.lvl_state = []     # 在load时进行赋值
        self.base_lvl = 0

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
        str_info += "\tlvl_state :\n"
        for i, l in enumerate(self.lvl_state):
            str_info += '\t' + str(i) + '\t' + str(l).replace('\t', '\t\t\t')
        str_info += "\tbase_lvl : %s\n" % str(self.base_lvl)
        str_info += "\tneed_bcp : %s\n" % str(self.need_bcp)
        str_info += "\tconflict_fifo : %s\n" % str(self.conflict_fifo)
        str_info += "\tlearntc : %s}\n" % str(self.learntc)
        return str_info

    def push_cclause_fifo(self, cindex, cur_lvl):
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
        for i in xrange(self.local_vars.nv):
            vs = self.local_vars.vs[i]
            if vs.value == 0:
                vs.value = 1
                vs.implied = False
                vs.level = self.cur_lvl
                assert(self.cur_lvl >= self.base_lvl)
                assert(self.cur_lvl - self.base_lvl <= self.local_vars.nv)
                ls = self.lvl_state[self.cur_lvl - self.base_lvl]
                ls.dcd_bin = cur_bi
                ls.has_bkt = False

                if self.c_array.update_state(i, self.local_vars.vs) is False:
                    print 'this is impossible'
                    sys.exit()
                str1 = '\t\tvar %d gvar %d value 1 level %d'\
                    % (i + 1, self.local_vars.global_var[i] + 1, vs.level)
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

    def bcp(self):
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
                self.local_vars.reason[j] = i + 1
                c_array.c_isreason[i] = True

                str1 = '\t\tc%d ' % (i + 1)
                str1 += 'var %d gvar %d '\
                    % (j + 1, self.local_vars.global_var[j] + 1)
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
        bkt_lvl = 0
        for i, lit in enumerate(clause):
            if i >= self.local_vars.nv:
                break
            vs = self.local_vars.vs[i]
            # find the max lvl to be bkt lvl
            if lit != 0 and bkt_lvl < vs.level:
                bkt_lvl = vs.level

        if bkt_lvl < self.base_lvl:
            # 需要bin间回退
            return 0, bkt_lvl

        ls = self.lvl_state[bkt_lvl - self.base_lvl]
        bkt_bi = ls.dcd_bin
        bkted = ls.has_bkt

        if bkted is True:
            # 沿着lvl states向前查找bkted为False的层级
            findflag = False
            for l in range(bkt_lvl, self.base_lvl - 1, -1):
                ls = self.lvl_state[l - self.base_lvl]
                if ls.has_bkt is False:
                    bkt_lvl = l
                    bkt_bi = ls.dcd_bin
                    findflag = True
                    break
            if findflag is False:
                bkt_bi = 0
                bkt_lvl = self.base_lvl - 1

        return bkt_bi, bkt_lvl

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

            logger.info('--\tthe learntc c%d %s'
                        % (inserti + 1,
                           gen_debug_info.convert_csr_clause(self.learntc)))
        else:
            # 冲突子句的变量的原因子句都在其他bin中，无法得到的学习子句
            # 此时的learntc等于ccindex
            logger.info('--\tno learntc')
            pass

        bkt_bi, bkt_lvl = self.find_bkt_lvl(self.learntc)

        logger.info('\t\tbkt_bin %d bkt_lvl %d' % (bkt_bi, bkt_lvl))

        self.learntc = [0] * self.vmax    # reset next learnt clause
        self.cur_lvl = bkt_lvl + 1
        return bkt_bi, bkt_lvl

    # bin内回退
    def backtrack_cur_bin(self, bkt_lvl):
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
                vs.set(value, False, vs.level)
                # has_bkt的翻转也可以放到find_bkt_lvl中
                self.lvl_state[vs.level - self.base_lvl].has_bkt = True
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
        """ return next_bin, next_lvl, bkt_lvl """
        self.cur_lvl = next_lvl
        self.cur_bin = cur_bi
        logger.info('sat engine run_core: cur_bin == %d' % cur_bi)

        while 1:
            conflict, ccindex, cvindex = self.bcp()
            if conflict is False:
                # no conflict
                allsat = self.decision(cur_bi)
                if allsat:
                    # sat
                    return cur_bi + 1, self.cur_lvl, 0     # next bin index
            else:
                # conflict
                bkt_bi, bkt_lvl = self.analysis(ccindex, cvindex)
                if bkt_bi != cur_bi:      # unsat
                    logger.info('----\t\tpartial unsat')
                    return bkt_bi, bkt_lvl + 1, bkt_lvl
                else:
                    self.backtrack_cur_bin(bkt_lvl)


class BinManager(object):

    """docstring for BinManager"""

    def __init__(self):
        self.global_vs = []
        self.clauses_bins = []
        self.n_oc_bin = []        # the Num of the origin clauses in the bins
        self.n_lc_bin = []        # the Num of the learnt clauses in the bins
        self.vars_bins = []
        self.nb = 0               # Num of the bins
        self.nc = 0               # total clauses Num
        self.nv = 0               # total vars Num
        self.cmax = 0
        self.vmax = 0

        self.lvl_state = []

        # the s_bkt is monotone increasing, this guarantees the solver's
        # complete
        self.s_bkt = 0

    def init_bins(self, filename):
        lists = [l for l in file(filename) if l[0] not in '\n']
        i = 0
        while i < len(lists):
            liststrip = lists[i].strip().split()
            if liststrip == []:
                pass
            elif liststrip[0] == 'total':
                if liststrip[3] == 'bins':
                    self.nb = int(liststrip[-1])
                elif liststrip[3] == 'variables':
                    self.nv = int(liststrip[-1])
                elif liststrip[3] == 'clauses':
                    self.nc = int(liststrip[-1])

            elif liststrip[0] == 'cmax':
                self.cmax = int(liststrip[-1])
            elif liststrip[0] == 'vmax':
                self.vmax = int(liststrip[-1])

            elif liststrip[0] == 'bin':
                cntc_bin = 0
                cbin = []

            elif liststrip[0] == 'variables':
                i += 1
                vbin = [int(l) - 1 for l in lists[i].strip().split()]
                self.vars_bins += [vbin]

            elif liststrip[0] == 'clauses':
                nc_bin = int(liststrip[-1])

            else:
                c = [int(l) for l in liststrip]
                cbin += [c]
                cntc_bin += 1
                if cntc_bin == nc_bin:
                    self.clauses_bins += [cbin]
                    self.n_oc_bin += [nc_bin]
                    self.n_lc_bin += [0]

            i += 1

        for i in xrange(self.nv):
            self.global_vs += [VarState()]
        for i in xrange(self.nv):
            self.lvl_state += [LvlState()]

    # load clause bin data to sat engine
    def load_bin(self, bin_i, next_lvl, sat_engine):
        logger.info('\n===============================================\n')
        global gen_debug_info
        gen_debug_info.cnt_load += 1
        logger.info('load_bin %d' % (bin_i + 1))
        logger.info('\tcnt_load %d' % (gen_debug_info.cnt_load))
        assert isinstance(sat_engine, SatEngine)
        assert bin_i >= 0
        sat_engine.c_array.clauses = self.clauses_bins[bin_i]
        sat_engine.c_array.n_oc = self.n_oc_bin[bin_i]
        sat_engine.c_array.n_lc = self.n_lc_bin[bin_i]
        sat_engine.local_vars.global_var = self.vars_bins[bin_i]
        sat_engine.cur_bin = bin_i
        sat_engine.cur_lvl = next_lvl

        # load var states
        sat_engine.local_vars.nv = len(self.vars_bins[bin_i])
        local_vs = []
        for i in xrange(self.vmax):
            if i < sat_engine.local_vars.nv:
                v = self.vars_bins[bin_i][i]
                local_vs += [self.global_vs[v]]
                assert(local_vs[i].value != 3)

        sat_engine.local_vars.vs = local_vs
        sat_engine.local_vars.reset_reason()

        # 找到min_lvl
        sat_engine.base_lvl = next_lvl
        for l in xrange(next_lvl - 1, 0, -1):
            ls = self.lvl_state[l - 1]
            if ls.dcd_bin != bin_i + 1:
                break
            sat_engine.base_lvl = l

        # load lvl states
        sat_engine.lvl_state = []
        for i in xrange(sat_engine.local_vars.nv):
            index = sat_engine.base_lvl - 1 + i
            if index < len(self.lvl_state):
                sat_engine.lvl_state += [self.lvl_state[index]]

        if logger.level <= logging.INFO:
            logger.info(gen_debug_info.bin_clauses(
                sat_engine,
                self.vars_bins[bin_i]))

        if logger.level <= logging.NOTSET:
            logger.info(gen_debug_info.bin_clauses_sv(sat_engine))

    # update sat engine's result to clauses bins
    def update_bin(self, bin_i, conflict, sat_engine):
        global gen_debug_info
        gen_debug_info.cnt_update += 1
        logger.info('update_bin %d' % (bin_i + 1))
        logger.info('\tcnt_update %d' % (gen_debug_info.cnt_update))

        self.n_oc_bin[bin_i] = sat_engine.c_array.n_oc
        self.n_lc_bin[bin_i] = sat_engine.c_array.n_lc

        # update var states，因为是引用的形式，所以不用更新
        # 只有当没有冲突时才更新，发生冲突的bin是unsat的，不需要
        # if conflict is False:
        #     for i in xrange(sat_engine.local_vars.nv):
        #         v = self.vars_bins[bin_i][i]
        #         self.global_vs[v] = sat_engine.local_vars.vs[i]

        if logger.level <= logging.INFO:
            logger.info(gen_debug_info.bin_clauses(
                sat_engine,
                self.vars_bins[bin_i]))

        if logger.level <= logging.NOTSET:
            logger.info(gen_debug_info.bin_clauses_sv(sat_engine))

    def find_global_bkt_lvl(self, bkt_lvl):
        ls = self.lvl_state[bkt_lvl - 1]
        bkt_bi = ls.dcd_bin
        bkted = ls.has_bkt

        if bkted is True:
            # 沿着lvl states向前查找bkted为False的层级
            findflag = False
            for l in range(bkt_lvl, 0, -1):
                ls = self.lvl_state[l - 1]
                if ls.has_bkt is False:
                    bkt_lvl = l
                    bkt_bi = ls.dcd_bin
                    findflag = True
                    break
            if findflag is False:
                bkt_bi = 0
                bkt_lvl = 0

        # 找到回退的bin
        logger.info('--\tfind_global_bkt_lvl\n\t\tbkt_bin %d bkt_lvl %d'
                    % (bkt_bi, bkt_lvl))
        assert(self.lvl_state[bkt_lvl - 1].has_bkt is False)
        return bkt_bi, bkt_lvl

    def backtrack_across_bin(self, bkt_lvl):
        str1 = '--\tbacktrack_across_bin: bkt_lvl == %d' % bkt_lvl
        logger.info(str1)
        gen_debug_info.cnt_across_bkt += 1
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
                vs.set(value, False, vs.level)
                self.lvl_state[vs.level - 1].has_bkt = True
                gen_debug_info.cnt_gbkt_clear_vs += 1
                str1 = '\t\tgvar %d value %d level %d' % (
                    i + 1,
                    vs.value,
                    vs.level)
                logger.info(str1)

            elif vs.level >= bkt_lvl:
                vs.set(0, False, 0)
                gen_debug_info.cnt_gbkt_clear_vs += 1

        # ls的回退是不需要的，但为了调试verilog，可以加上
        # for i in xrange(bkt_lvl, len(self.lvl_state)):
        #     self.lvl_state[i].reset()

    def print_bkted_lvl(self, lvl):
        ltemp = '  level '
        stemp = '  bkted '
        btemp = '  d_bin '
        for i in xrange(lvl):
            ltemp += '%3d' % (i + 1)
            stemp += '%3d' % int(self.lvl_state[i].has_bkt)
            btemp += '%3d' % int(self.lvl_state[i].dcd_bin)
        logger.info(ltemp)
        logger.info(stemp)
        logger.info(btemp)

    def compute_s_bkt(self, lvl, bin_i, next_bi):
        # the s_bkt is monotone increasing, this guarantees the solver's
        # complete
        if logger.level <= logging.DEBUG or bin_i != next_bi - 1:
            self.print_bkted_lvl(lvl)

        if bin_i != next_bi - 1:
            s_bkt = 1
            for i in xrange(self.nv):
                if i < lvl:
                    s_bkt = s_bkt * 2 + int(self.lvl_state[i].has_bkt)
                else:
                    s_bkt = s_bkt * 2

            assert(s_bkt > self.s_bkt)
            self.s_bkt = s_bkt

            logger.info('%d bin %d' % (s_bkt, bin_i))

    def test(self, filename):
        print ''
        varvalue = [l.value for l in self.global_vs]
        self.init_bins(filename)
        for bi in xrange(self.nb):
            for c in self.clauses_bins[bi]:
                sat = False
                # print self.vars_bins[bi]
                # print c
                for i in xrange(len(self.vars_bins[bi])):
                    lit = c[i]
                    var = self.vars_bins[bi][i]
                    if lit == varvalue[var]:
                        sat = True
                        break
                if sat is False:
                    print 'test fail'
                    print 'bin', bi
                    cstr = gen_debug_info.csr_clause_str(c, self.vars_bins[bi])
                    print 'clause', cstr
                    print 'vars_bins', [l + 1 for l in self.vars_bins[bi]]
                    print 'varsvalue', \
                        [varvalue[l] for l in self.vars_bins[bi]]
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
        ls = self.bin_manager.lvl_state
        for i in xrange(len(c)):
            var = i + 1
            if c[i] != 0:
                if c[i] == 1:
                    var = -var
                cc += [var]
                value += [vs[i].value]
                implied += [vs[i].implied]
                level += [vs[i].level]
                bini += [ls[vs[i].level - 1].dcd_bin]
                has_bkt += [ls[vs[i].level - 1].has_bkt]
                reason += [local_vars.reason[i]]
        str1 = ''
        str1 += '%slits    %s\n' % (strtab, cc)
        str1 += '%svalue   %s\n' % (strtab, value)
        str1 += '%simplied %s\n' % (strtab, [int(l) for l in implied])
        str1 += '%slevel   %s\n' % (strtab, level)
        str1 += '%sbin     %s\n' % (strtab, bini)
        str1 += '%sbkted   %s\n' % (strtab, [int(l) for l in has_bkt])
        str1 += '%sreason  %s\n' % (strtab, reason)
        return str1

    def bin_clauses(self, sat_engine, variables):
        clauses = sat_engine.c_array.clauses
        vs = sat_engine.local_vars.vs
        ls = sat_engine.lvl_state
        ci = 1
        str1 = ''
        for c in clauses:
            strc = '\tc%d  ' % ci
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
        str1 += '\tglobal vars %s\n' % [l + 1 for l in variables]
        str1 += '\tlocal vars  %s\n' % [l + 1 for l in range(len(variables))]
        str1 += '\tvar_state_list:\n'
        str1 += '\tvalue       %s\n' % [l.value for l in vs]
        str1 += '\timplied     %s\n' % [int(l.implied) for l in vs]
        str1 += '\tlevel       %s\n' % [l.level for l in vs]
        str1 += '\tlvl state list:\n'
        str1 += '\tdcd_bin     %s\n' % [l.dcd_bin for l in ls]
        str1 += '\thas_bkt     %s\n' % [int(l.has_bkt) for l in ls]
        str1 += '\tctrl:\n'
        str1 += '\tcur_bin_num : %d\n' % (sat_engine.cur_bin + 1)
        str1 += '\tbase_lvl    : %d\n' % sat_engine.base_lvl
        str1 += '\tcur_lvl     : %d\n' % sat_engine.cur_lvl
        return str1

    def bin_clauses_sv(self, sat_engine):
        # return
        clauses = sat_engine.c_array.clauses
        vs = sat_engine.local_vars.vs
        ls = sat_engine.lvl_state
        cmax = sat_engine.cmax
        vmax = sat_engine.vmax
        ci = 1
        str1 = ''
        str_bin = "\tint bin[%d][%d] = '{\n" % (cmax, vmax)
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
        str1 += '\tint value[]   = %s\n' % [l.value for l in vs]
        str1 += '\tint implied[] = %s\n' % [int(l.implied) for l in vs]
        str1 += '\tint level[]   = %s\n' % [l.level for l in vs]

        str1 += '\t//lvl state list:\n'
        str1 += '\tint dcd_bin[] = %s\n' % [l.dcd_bin for l in ls]
        str1 += '\tint has_bkt[] = %s\n' % [int(l.has_bkt) for l in ls]

        str1 += '\t//ctrl\n'
        str1 += '\tint cur_bin_num = %d;\n' % (sat_engine.cur_bin + 1)
        str1 += '\tint base_lvl = %d;\n' % sat_engine.base_lvl
        str1 += '\tint load_lvl = %d;\n' % sat_engine.cur_lvl

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


def control(filename):
    starttime = clock()
    global bin_manager
    global sat_engine
    bin_manager = BinManager()
    bin_manager.init_bins(filename)

    sat_engine = SatEngine(bin_manager.cmax, bin_manager.vmax)

    global gen_debug_info
    gen_debug_info = GenDebugInfo(bin_manager)

    bin_i = 1
    next_lvl = 1
    while bin_i <= bin_manager.nb:
            bin_manager.load_bin(bin_i - 1, next_lvl, sat_engine)

            next_bi, next_lvl, bkt_lvl = \
                sat_engine.run_core(bin_i, next_lvl)

            conflict = False
            if bin_i != next_bi - 1:
                # partial unsat
                bkt_bi, bkt_lvl = bin_manager.find_global_bkt_lvl(bkt_lvl)
                if bkt_bi == 0:
                    logger.info('\nunsatisfiable')
                    print '\nunsatisfiable'
                    return 'unsat'
                bin_manager.backtrack_across_bin(bkt_lvl)
                conflict = True
                next_lvl = bkt_lvl + 1
                next_bi = bkt_bi

            bin_manager.update_bin(bin_i - 1, conflict, sat_engine)

            bin_manager.compute_s_bkt(next_lvl - 1, bin_i, next_bi)

            bin_i = next_bi

            curtime = clock()
            if curtime - starttime > TIME_OUT_LIMIT:
                logger.critical('time out')
                sys.exit()

    logger.info('\nsatisfiable')
    print '\nsatisfiable'

    logger.info('\nresult var value')
    str_var_value = '\t'
    for i, vs in enumerate(bin_manager.global_vs):
        assert(vs.value == 1 or vs.value == 2)
        var = i + 1
        if vs.value == 1:
            var = -var
        str_var_value += str(var) + ' '
    logger.info(str_var_value)

    # test the satisfiability
    bin_manager.test(filename)
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


def run(filename):

    strl = ["NOTSET", "INFO", "DEBUG", "WARNING", "ERROR", "CRITICAL"]
    print "the loglevel is %s" % strl[loglevel / 10]

    if log2file:
        set_logging_file(loglevel)
    else:
        set_logging_console(loglevel)

    control(filename)
    print str(gen_debug_info)
    if log2file:
        logger.debug(str(gen_debug_info))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename',
                        type=str,
                        help='input filename',
                        default='bram.txt'
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
    # filename = 'testdata/bram_bin_uf20-0232.cnf'
    # filename = 'testdata/bram_bin_uf20-01.cnf'
    # filename = 'bram.txt'

    # print args.info
    # return

    global loglevel, log2file
    loglevel = args.loglevel
    log2file = args.log2file

    # loglevel = logging.CRITICAL
    # loglevel = logging.WARNING
    # loglevel = logging.INFO
    # loglevel = logging.DEBUG
    # loglevel = logging.NOTSET
    # logfile = True
    run(filename)


if __name__ == '__main__':
    # import profile
    start = clock()
    # profile.run("main()")
    main()
    finish = clock()
    print 'runtime: %lfs' % (finish - start)
