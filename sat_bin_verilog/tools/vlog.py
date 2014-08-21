#!python
# -*- coding: utf-8 -*-

import os
import sys
import json
import re
import subprocess
import gen_num_verilog as gn

# vlog_exe = "D:/questasim_10.0c/win32/vlog.exe"
vlog_exe = "vlog.exe"
vlog_db_mtime = 'vlog_mtime.db'
vlog_db_ref = 'vlog_include_ref.db'
editer = '"D:/Program Files/Sublime Text 3/sublime_text.exe" '
usevim = 0
usesubl = 0

# 忽略的文件
ignore_list = ["case", "class"]


def in_ignore(filename):
    for l in ignore_list:
        if l in filename:
            return True
    return False


def init_vlog():
    if os.path.isfile(vlog_db_mtime) is False:
        mtime_list = {}
    else:
        file_db = open(vlog_db_mtime, 'r+')
        data = file_db.read()
        # print data
        mtime_list = json.loads(data)
        file_db.close()

    if os.path.isfile(vlog_db_ref) is False:
        ref_list = {}
    else:
        file_db = open(vlog_db_ref, 'r+')
        data = file_db.read()
        # print data
        ref_list = json.loads(data)
        file_db.close()
    return mtime_list, ref_list


# 将文件列表过滤一遍，找出需要编译的
def find_vlog_list(mtime_list, ref_list):
    need_vlog_flist = []
    for i in xrange(1, len(sys.argv)):
        filename = sys.argv[i]
        print filename
        statinfo = os.stat(filename)
        mtime = statinfo.st_mtime
        mtime = int(mtime)

        if filename in mtime_list:
            if mtime_list[filename] == mtime:
                continue

        if filename.endswith('.v') or filename.endswith('.sv') or \
                filename.endswith('.gen'):
            need_vlog_flist += [filename]
            if filename not in ref_list:
                continue
            for f in ref_list[filename]:
                if f not in need_vlog_flist:
                    need_vlog_flist += [f]

    print "need_vlog_flist"
    for f in need_vlog_flist:
        print f
    return need_vlog_flist


# 编译
def vlog_file(need_vlog_flist):
    pattern_error = re.compile(r'\((\d+)\)')
    for filename in need_vlog_flist:
        if filename.endswith('.v') or filename.endswith('.sv'):
            if not in_ignore(filename):
                # subp = subprocess.Popen(["vlog", "-quiet", filename])
                # subp = subprocess.Popen("vlog -sv %s" % filename)
                subp = subprocess.Popen(vlog_exe + " -sv " + filename,
                                        stdout=subprocess.PIPE)
                # str_all = ""
                # while subp.poll() is None:
                #     vlog_info = subp.stdout.read()
                #     print vlog_info
                #     str_all += vlog_info
                vlog_info = subp.stdout.read()
                print vlog_info
                if "Error" in vlog_info:
                    if usevim == 1:
                        # subprocess.Popen("start gvim %s" % filename)
                        match = pattern_error.search(vlog_info)
                        print match.group(1)
                        subprocess.Popen(["gvim", filename, "+%s" % match.group(1)])
                    elif usesubl == 1:
                        subprocess.Popen(editer + filename)
                    break
                subp.wait()
        elif filename.endswith('.gen'):
            # subp = subprocess.Popen(["../tools/gen_num_verilog.py",
            #                         filename,
            #                         '8'])
            gn.gen_num_verilog(filename, 8)

        statinfo = os.stat(filename)
        mtime = statinfo.st_mtime
        mtime = int(mtime)
        mtime_list[filename] = mtime

    file_db = open(vlog_db_mtime, 'w')
    str1 = json.dumps(mtime_list, indent=2)
    file_db.write(str1)

if __name__ == '__main__':
    mtime_list, ref_list = init_vlog()
    need_vlog_flist = find_vlog_list(mtime_list, ref_list)
    vlog_file(need_vlog_flist)
