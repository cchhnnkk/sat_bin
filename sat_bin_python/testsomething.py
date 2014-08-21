# coding: utf-8

# 中文注释
import logging

logging.basicConfig(filename='debug.info.todo',
                    format='',
                    filemode='w')
logging.shutdown()
logging.basicConfig(filename='')

logging.basicConfig(level=logging.DEBUG)  # 定义日志级别为INFO级别
logging.getLogger().setLevel(logging.DEBUG)

str1 = 'ss'
logging.debug(str1 + 'this is a message' + ' yi')
logging.info('this is a message')
print 'ok'
exit()


class LvlState(object):

    def __init__(self):
        self.dcd_var = 0        # The decided var in decision level
        self.dcd_bin = 0        # The bin that decided our decided var
        self.has_bkt = False    # True/False

    def reset(self):
        self.dcd_var = 0
        self.dcd_bin = 0
        self.has_bkt = False

    def get(self):
        return self.dcd_var, self.dcd_bin, self.has_bkt

    def set(self, dcd_var, dcd_bin, has_bkt):
        self.dcd_var = dcd_var
        self.dcd_bin = dcd_bin
        self.has_bkt = has_bkt

# load lvl states
lvl_state = []
for i in xrange(8):
    lvl_state += [LvlState()]

lss = []
# for l in xrange(8, 4, -1):
#     ls = lvl_state[l - 1]
#     lss.insert(0, ls)

# for i in xrange(4, 7):
#     lss += [lvl_state[i]]

lss = lvl_state[4:7]

lss[0].has_bkt = True
lss[1].has_bkt = False
print [l.has_bkt for l in lss]
print [l.has_bkt for l in lvl_state]
