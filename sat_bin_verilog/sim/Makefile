
all: vlog sim cmp_log

vlog: vlog_sb

sim: sim_sb

init: init_ref_all

# sat_bin
vlog_sb:
	vlog_test_sat_bin.sh
# bin_manager
vlog_bm:
	vlog_test_bin_manager.sh
# sat engine
vlog_se:
	vlog_test_sat_engine.sh

# 模拟
sim_sb:
	cp test_se_console.do test_console.do
	sed -i "s/test_sat_engine_top/test_sat_bin_top/g" test_console.do
	sed -i "s/4us/1024us/g" test_console.do
	cat test_console.do
	vsim -c -do test_console.do | \
		sed -e "s/^.*Error: (vsim-[0-9]*) \(.*):\)/\1 Error/g" \
			-e "s/^.*Warning: (vsim-[0-9]*) \(.*):\)/\1 Warning/g"
	rm test_console.do
	python transcript_info.py
	sed -i "s/\n/\r/g" transcript.log
	sed -i "s/cnt_update_bin =/cnt_update/g" transcript.log
sim_bm:
	sed "s/test_sat_engine_top/test_bin_manager_top/g" test_se_console.do > test_console.do
	vsim -c -do test_console.do | \
		sed -e "s/^.*Error: (vsim-[0-9]*) \(.*):\)/\1 Error/g" \
			-e "s/^.*Warning: (vsim-[0-9]*) \(.*):\)/\1 Warning/g"
	rm test_console.do
	python transcript_info.py
	sed -i "s/\n/\r/g" transcript.log
sim_se:
	vsim -c -do test_se_console.do
	python transcript_info.py
	sed -i "s/\n/\r/g" transcript.log
sim_ca:
	sed "s/test_sat_engine_top/test_clause_array_top/g" test_se_console.do > test_console.do
	vsim -c -do test_console.do
	rm test_console.do
	python transcript_info.py
	sed -i "s/--//g" transcript.log
sim_c1:
	sed "s/test_sat_engine_top/test_clause1_top/g" test_se_console.do > test_console.do
	vsim -c -do test_console.do
	rm test_console.do
	python transcript_info.py
	sed -i "s/--//g" transcript.log

# 波形文件
wave_sb: hielist
	cd ../tools && ../tools/gen_wave.sh test_sat_bin_top 3
wave_bm: hielist
	cd ../tools && ../tools/gen_wave.sh test_bin_manager_top 3
wave_se: hielist
	cd ../tools && ../tools/gen_wave.sh test_sat_engine_top 3
wave_exlist_se:
	cd ../tools && ../tools/gen_wave.sh test_sat_engine_top 3 wave_exlist_sat_engine.txt
wave_clause1: hielist
	cd ../tools && ../tools/gen_wave.sh test_clause1_top 3


#文件中的include引用，当增加include时，在vlog前使用
init_ref_se:
	../tools/find_verilog_file.py ../src/sat_engine ../tb > filelist.txt
	echo "../src/debug_define.v" >> filelist.txt
	cat filelist.txt | ../tools/gen_include_ref.py > vlog_include_ref.db
	rm filelist.txt
init_ref_all:
	../tools/find_verilog_file.py ../src ../tb > filelist.txt
	cat filelist.txt | ../tools/gen_include_ref.py > vlog_include_ref.db
	rm filelist.txt

# 生成module的层级关系hielist.json
hielist:
	cd ../tools && gen_all_hielist.sh

cmp_log:
	../tools/cmp_log.py transcript.log ../../sat_bin_python/debug.info.log 2

py_sat:
	cd ../../sat_bin_python && make lvl_10

xilinx:
	cp -r ../src ../xilinx
	../tools/gen_xilinx_file.py

view:
	start vsim -view vsim.wlf

clean:
	rm -rf work
	rm vlog_mtime.db
	rm wlf*
	rm -f sed*
	vlib work
	vmap work work
	#\rm -rf $(CLEAN_THESE)  
