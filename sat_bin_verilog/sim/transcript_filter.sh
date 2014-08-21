#!bash

cat transcript.log | grep -A1 ram_we_c_o > transcript_filter.log
echo "================================" >> transcript_filter.log
cat transcript.log | grep -A1 ram_we_vs_o >> transcript_filter.log
echo "================================" >> transcript_filter.log
cat transcript.log | grep -A1 ram_we_ls_o >> transcript_filter.log
echo "================================" >> transcript_filter.log

