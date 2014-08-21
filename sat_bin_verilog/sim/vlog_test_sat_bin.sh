#!bash

# 必须设置这个选项, 否则脚本不会打开别名功能. 
shopt -s expand_aliases

alias myvlog='../tools/vlog.py'

# 程序与测试代码的目录
src="../src"
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

if [[ ! -x "work" ]]; then
	vlib work
	vmap work work
fi

myvlog $svfile $vfile "../src/debug_define.v" > vlog_out.txt
sed -i -e "s/^.*Error: \(.*):\)/\1 Error/g" vlog_out.txt
sed -i -e "s/^.*Warning: \(.*):\)/\1 Warning/g" vlog_out.txt
cat vlog_out.txt
rm vlog_out.txt

