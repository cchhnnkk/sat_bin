#!python
# -*- coding: utf-8 -*-

# find_verilog_file.py ../tb ../src

import os
import sys


def remove_ifdef(datas):
    new_datas = []
    tagif = False
    i = 0

    while i < len(datas):
        line = datas[i]
        if '`ifdef DEBUG' in line:
            tagif = True
        elif '`else' in line:
            tagif = False
        elif '`endif' in line:
            tagif = False
        elif 'debug_define.v' in line:
            pass
        elif tagif is False:
            new_datas += [line]

        i += 1

    return new_datas

def mkdir(path):
    path=path.strip()
    path=path.rstrip("\\")
 
    # ÅÐ¶ÏÂ·¾¶ÊÇ·ñ´æÔÚ
    isExists=os.path.exists(path)
 
    if not isExists:
        os.makedirs(path)
        return True
    else:
        return False
 


str_files = os.popen('find ../src -name "*.v"').read()

files = str_files.strip().split()


# mkdir('../xilinx/src')

for fname in files:
    print fname
    data = open(fname).readlines()
    xfname = fname.replace('src', 'xilinx/src')
    print xfname
    fwrite = open(xfname, 'w')
    xdata = remove_ifdef(data)
    for l in xdata:
        fwrite.write(l)
    fwrite.close()

xfadd = open('../xilinx/add_file.tcl', 'w')
for fname in files:
    xfname = fname.replace('../src', 'src')
    xfadd.write('xfile add ' + xfname + ';\n')

