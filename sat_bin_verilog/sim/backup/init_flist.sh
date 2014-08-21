#!/bin/bash

find .. | egrep "\.v$|\.sv$" > verilog_flist.f
cat verilog_flist.f | xargs stat -c %Y > temp
paste -d " " verilog_flist.f temp > verilog_flist_ctimes.txt
rm temp
