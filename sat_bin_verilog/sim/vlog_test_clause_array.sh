#!bash

# ../tools/vlog.py ../src/sat_engine/clauses.gen
# ../tools/vlog.py ../src/sat_engine/clauses.v
# ../tools/vlog.py ../src/sat_engine/lit1.v
# ../tools/vlog.py ../src/sat_engine/lits.v
# ../tools/vlog.py ../src/sat_engine/terminal_cell.v
# ../tools/vlog.py ../src/sat_engine/clause1.v
# ../tools/vlog.py ../src/sat_engine/clause_array.v
# ../tools/vlog.py ../src/sat_engine/max_in_datas.v
# ../tools/vlog.py ../tb/class_clause_data.sv
# ../tools/vlog.py ../tb/class_clause_array.sv
# ../tools/vlog.py ../tb/test_clause_array.sv

shopt -s expand_aliases
# 必须设置这个选项, 否则脚本不会打开别名功能. 

alias myvlog='../tools/vlog.py'

gfile=$(find ../src/sat_engine/clause_array -name "*.gen")
# echo $gfile

vfile=$(find ../src/sat_engine/clause_array -name "*.v")
# echo $vfile
myvlog $gfile $vfile

myvlog ../tb/class_clause_data.sv
myvlog ../tb/class_clause_array.sv
myvlog ../tb/test_clause_array.sv
