
run_all:
	run_all.py

sat_bin:
	sat_bin.py --filename bram_input.txt --log2file 1 --loglevel 20

lvl_0:
	sat_bin.py --log2file 1 --loglevel 0

lvl_10:
	sat_bin.py --log2file 1 --loglevel 10

lvl_20:
	sat_bin.py --log2file 1 --loglevel 20

partition:
	partitioncnf.py --i input.cnf --o bram_input.txt --vmax 8 --cmax 4

gen_vtb:
	gen_bm_tb.py bram.txt > sb_test_case.sv

