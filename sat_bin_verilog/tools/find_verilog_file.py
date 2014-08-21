#!python
# -*- coding: utf-8 -*-

# find_verilog_file.py ../tb ../src

import os
import sys

files = ""
for i in xrange(1, len(sys.argv)):
    src_dir = sys.argv[i]
    files1 = os.popen('find %s -name "*.v"' % src_dir).read()
    files2 = os.popen('find %s -name "*.sv"' % src_dir).read()
    files += files1 + files2

print files.strip()
