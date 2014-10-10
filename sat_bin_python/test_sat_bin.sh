#!/bin/bash 

# compute_sum_std.sh temp.log

# test_sat_bin_dynamic_group.py 8 > temp && compute_avg_std.sh temp
# test_sat_bin_dynamic_group.py 16 > temp && compute_avg_std.sh temp
# test_sat_bin_dynamic_group.py 24 > temp && compute_avg_std.sh temp
# test_sat_bin_dynamic_group.py 32 > temp && compute_avg_std.sh temp

if [[ $# == 0 ]]; then
    let n=32
elif [[ $# == 1 ]]; then
    let n=$1
fi

for j in $( seq 8 8 $n )
do
    echo "test_sat_bin_dynamic_group.py ${j}"
    test_sat_bin_dynamic_group.py ${j} > temp && compute_avg_std.sh temp
done
