
all: test_case1 test_case2 

test_case1:
	cp sat_bin_python/testdata/uf20-91/uf20-01.cnf sat_bin_python/input.cnf
	make run_verilog

test_case2:
	cp sat_bin_python/testdata/uf20-91/uf20-02.cnf sat_bin_python/input.cnf
	make run_verilog

run_verilog: run_python
	cd sat_bin_python && make gen_vtb
	mv sat_bin_python/sb_test_case.sv sat_bin_verilog/tb/
	cd sat_bin_verilog/sim && make all

run_python:
	cd sat_bin_python && make partition
	cd sat_bin_python && make lvl_10


init:
	cd sat_bin_verilog/sim && make clean
	cd sat_bin_verilog/sim && make init_ref_all

