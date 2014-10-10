#!/bin/bash
for k in $( seq 1 10 )
do
    # minisat/minisat.exe testdata/uf100-430/uf100-0${k}.cnf
    minisat/minisat.exe testdata/uf50-218/uf50-0${k}.cnf
done
