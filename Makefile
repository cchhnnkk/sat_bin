
all: test_case1 test_case2 test_case3

test_case1:
	cp sat_bin_python/testdata/uf20-91/uf20-01.cnf sat_bin_python/input.cnf
	make run_verilog

test_case2:
	cp sat_bin_python/testdata/uf20-91/uf20-02.cnf sat_bin_python/input.cnf
	make run_verilog

test_case3:
	cp sat_bin_python/testdata/uf20-91/uf20-03.cnf sat_bin_python/input.cnf
	make run_verilog

test_case4:
	# cnt_load 1303
	cp sat_bin_python/testdata/uf20-91/uf20-05.cnf sat_bin_python/input.cnf
	make run_verilog

test_case5:
	# cnt_load 
	cp sat_bin_python/testdata/uf20-91/uf20-07.cnf sat_bin_python/input.cnf
	make run_verilog

test_case6:
	# cnt_load 93
	cp sat_bin_python/testdata/uf20-91/uf20-015.cnf sat_bin_python/input.cnf
	make run_verilog

test_case7:
	# cnt_load 37
	cp sat_bin_python/testdata/uf20-91/uf20-029.cnf sat_bin_python/input.cnf
	make run_verilog

test_case8:
	# cnt_load 407
	cp sat_bin_python/testdata/uf20-91/uf20-044.cnf sat_bin_python/input.cnf
	make run_verilog

run_verilog: run_python
	cd sat_bin_python && make gen_vtb
	mv sat_bin_python/sb_test_case.sv sat_bin_verilog/tb/
	cd sat_bin_verilog/sim && make all

run_python:
	cd sat_bin_python && make partition
	cd sat_bin_python && make lvl_10

run_minisat:
	cd sat_bin_python && minisat/minisat.exe input.cnf

init:
	cd sat_bin_verilog/sim && make clean
	cd sat_bin_verilog/sim && make init_ref_all

