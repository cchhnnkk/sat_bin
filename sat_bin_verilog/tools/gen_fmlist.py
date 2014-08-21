#!python
# -*- coding: utf-8 -*-

# 这个还不能用，因为vlog编译的对象包括类等，太麻烦了
# cat hielist.json | gen_fmlist.py > fmlist.json

import os
import sys
import json
import re

# prj_dir = os.popen("pwd | perl -pe 's/(.*sat_bin_verilog).*/$1/'").read()

# str1 = os.popen("pwd").read()
# prj_name = 'sat_bin_verilog'
# pos1 = str1.find(prj_name)
# prj_dir = str1[0: pos1] + prj_name

# print prj_dir.strip()

data = sys.stdin.read()
mlist_json = json.loads(data)

files1 = os.popen('find .. -name "*.v"').read()
files2 = os.popen('find .. -name "*.sv"').read()
files = files1 + files2
# print files

filelist = files.strip().split('\n')

# cat $files1 $files2 | gen_hielist.py > hielist.json

pattern_module = re.compile(r'^module[\s\t]+([\w\d]+\b)')
for f in filelist:
    print f
    fdata = open(f).read()
    mname_list = pattern_module.findall(fdata)
    print mname_list
    for mname in mname_list:
        print mname
        mlist_json[mname].insert(0, f)

fmlist_json = json.dumps(mlist_json, indent=2)
print fmlist_json
