#!/bin/bash 

# compute_sum_std.sh temp.log

echo "average"
cat $1 | grep cnt_load          | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_update        | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_across_bkt    | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_gbkt_visit_vs | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_gbkt_clear_vs | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_decision      | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_bcp           | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_cur_bkt       | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_analysis      | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cnt_learntc       | awk '{a+=$3}END{print a/NR}'
cat $1 | grep num_bins          | awk '{a+=$3}END{print a/NR}'
cat $1 | grep num_clauses       | awk '{a+=$3}END{print a/NR}'
cat $1 | grep num_vars          | awk '{a+=$3}END{print a/NR}'
cat $1 | grep cmax              | awk '{a+=$3}END{print a/NR}'
cat $1 | grep vmax              | awk '{a+=$3}END{print a/NR}'

# echo "stdev"
# cat $1  | grep cnt_load          | tr '\n' ' ' | \
#    awk '{for(i=1;i<=NF;i++) total+=$i;ave=total/NF;for(i=1;i<=NF;i++) tmp+=(($i-ave)*($i-ave)); print sqrt(tmp/NF)}'
