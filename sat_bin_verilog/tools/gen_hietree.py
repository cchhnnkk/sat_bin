#!python
# -*- coding: utf-8 -*-

# cat hielist.json | gen_hietree.py test_clause_array_top > hietree.json
# 输入是json格式 {name: [instlist]}
# 输出是json格式 [name, inst, [sublit]]

import sys
import json

data = sys.stdin.read()

mlist_json = json.loads(data)
# print mlist_json

topm = sys.argv[1]

toplist = []
toplist += [topm] * 2


def find_sub(mname, mlist):
    sublist = []
    if mname not in mlist_json:
        return
    for l in mlist_json[mname]:
        sublist1 = l[:]
        find_sub(l[0], sublist1)
        sublist += [sublist1]
        # print l
        # print sublist1

    mlist += [sublist]

find_sub(topm, toplist)

mtree_json = json.dumps(toplist, indent=2)
print mtree_json
