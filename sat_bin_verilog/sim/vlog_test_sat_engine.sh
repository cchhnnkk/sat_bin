#!bash

# 必须设置这个选项, 否则脚本不会打开别名功能. 
shopt -s expand_aliases

alias myvlog='../tools/vlog.py'

# 程序与测试代码的目录
src="../src/sat_engine/"
tb="../tb"

gfile=`find $src -name "*.gen"`
# echo $gfile
echo "gen verilog"
myvlog $gfile

vfile=`find $src -name "*.v"`
# echo $vfile
echo "vlog verilog"

svfile=`find $tb -name "*.sv"`
echo "vlog systemverilog"

# for i in $vfile
# do
# 	echo $i
# 	myvlog $i
# done ; 

# echo $vfile $svfile

if [[ ! -x "work" ]]; then
	vlib work
	vmap work work
fi

myvlog $svfile $vfile "../src/debug_define.v"
