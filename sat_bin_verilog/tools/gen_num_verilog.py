#!python
# -*- coding: utf-8 -*-

import sys
import re


def gen_verilog(filename, num):

    pattern = re.compile(r'{(\$NUM.*?)}')

    str_v = open(filename).read()

    num_list = pattern.findall(str_v)
    # print num_list
    num_dict = {}
    for l in num_list:
        if l not in num_dict:
            le = l.replace('$NUM', str(num))
            value = eval(le)
            num_dict[l] = value

    print num_dict
    for l in num_dict:
        str1 = '{%s}' % l
        str2 = str(num_dict[l])
        str_v = str_v.replace(str1, str2)

    return str_v + '\n'


def gen_num_verilog(filename, num):
    vfile_name = filename.replace(".gen", ".v")

    str_v = """
/**
 *  该文件是使用%s生成的
 *  %s %s %s
 */
""" % ('gen_num_verilog.py', "gen_num_verilog", filename, num)

    while(num > 1):
        str_v += gen_verilog(filename, num)
        num = num / 2

    open(vfile_name, 'w').write(str_v)

if __name__ == '__main__':
    if len(sys.argv) == 3:
        filename = sys.argv[1]
        num = int(sys.argv[2])
    else:
        print "please input:"
        print "gen_num_verilog lit.gen 8"

    gen_num_verilog(filename, num)
