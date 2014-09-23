
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
	partitioncnf.py --i input.cnf --o bin.txt --vmax 8 --cmax 4
	convert_csr_to_bram_data.py --i bin.txt --o bram.txt

gen_vtb:
	gen_bm_tb.py bram.txt > sb_test_case.sv

cnt_load:
	run_all.py | tee temp
	cat temp | grep load | awk '{print $$3}'

test_uf20:
	cp run_all.py run_all_temp.py
	# 8
	echo 'test_uf20_91_100 vmax = 8'
	run_all_temp.py > temp_8
	# 16
	echo 'test_uf20_91_100 vmax = 16'
	sed -i 's/test_uf20_91_100(100, 8, 4)/test_uf20_91_100(100, 16, 8)/' run_all_temp.py
	run_all_temp.py > temp_16
	# 32
	echo 'test_uf20_91_100 vmax = 32'
	sed -i 's/test_uf20_91_100(100, 16, 8)/test_uf20_91_100(100, 32, 16)/' run_all_temp.py
	run_all_temp.py > temp_32
	rm run_all_temp.py
	# compute the average of load
	echo 'cnt_load'
	cat temp_8  | grep load |awk '{a+=$$3}END{print a/NR}'
	cat temp_16 | grep load |awk '{a+=$$3}END{print a/NR}'
	cat temp_32 | grep load |awk '{a+=$$3}END{print a/NR}'
	echo 'cnt_learntc'
	cat temp_8  | grep learntc |awk '{a+=$$3}END{print a/NR}'
	cat temp_16 | grep learntc |awk '{a+=$$3}END{print a/NR}'
	cat temp_32 | grep learntc |awk '{a+=$$3}END{print a/NR}'

