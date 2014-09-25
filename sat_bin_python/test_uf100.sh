#!/bin/bash 

# compute_sum_std.sh temp.log

# 8
cp test_sat_bin_dynamic_partition.py test_uf100.py
echo 'bin_vmax = 8'
test_uf100.py | tee temp_uf100_8
compute_avg_std.sh temp_uf100_8
echo ''

# 16
echo 'bin_vmax = 16'
cp test_sat_bin_dynamic_partition.py test_uf100.py
sed -i 's/test_uf100(10, 8, 1000)/test_uf100(10, 16, 1000)/' test_uf100.py
test_uf100.py | tee temp_uf100_16
compute_avg_std.sh temp_uf100_16
echo ''

# 32
echo 'bin_vmax = 32'
cp test_sat_bin_dynamic_partition.py test_uf100.py
sed -i 's/test_uf100(10, 8, 1000)/test_uf100(10, 32, 1000)/' test_uf100.py
test_uf100.py | tee temp_uf100_32
compute_avg_std.sh temp_uf100_32
echo ''

# 64
echo 'bin_vmax = 64'
cp test_sat_bin_dynamic_partition.py test_uf100.py
sed -i 's/test_uf100(10, 8, 1000)/test_uf100(10, 64, 1000)/' test_uf100.py
test_uf100.py | tee temp_uf100_64
compute_avg_std.sh temp_uf100_64
echo ''

rm test_uf100.py

compute_avg_std.sh temp_uf100_8
compute_avg_std.sh temp_uf100_16
compute_avg_std.sh temp_uf100_32
compute_avg_std.sh temp_uf100_64
