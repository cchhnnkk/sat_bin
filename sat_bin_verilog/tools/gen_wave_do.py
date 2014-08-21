#!python
# -*- coding: utf-8 -*-

# cat hietree.json | gen_wave_do.py 3 > wave_gen.do
# 输出是json格式 [name, inst, [sublit]]

import sys
import json

expand_list = []
if len(sys.argv) == 1:
    expand_lvl = 3
elif len(sys.argv) == 2:
    expand_lvl = int(sys.argv[1])
elif len(sys.argv) == 3:
    expand_lvl = int(sys.argv[1])
    expand_list = open(sys.argv[2]).readlines()
    expand_list = [l for l in expand_list if l[0] != '#']

data = sys.stdin.read()

mlist_json = json.loads(data)
# print mlist_json

str_wave = 'add wave -noupdate '


def in_exlist(ex_str):
    for l in expand_list:
        if ex_str in l:
            return True
    return False


def gen_sub(mlist, str_inst, str_group, depth):
    sublist = []
    # print mlist[0], mlist[1]
    inst = mlist[1]
    sublist = mlist[2]

    str_inst1 = str_inst[:]
    str_inst1 += '/' + inst
    str_group1 = str_group[:]

    if depth < expand_lvl or in_exlist(str_inst1):
        str_group1 += '-expand -group {%s} ' % inst
    else:
        str_group1 += '-group {%s} ' % inst

    print str_wave + str_group1 + str_inst1 + '/*'

    for l in sublist:
        gen_sub(l, str_inst1, str_group1, depth + 1)


gen_sub(mlist_json, "", "", 0)
