cd ..
python -m cProfile -o profile/output.pstats run_all.py
cd profile
python gprof2dot.py -f pstats output.pstats | dot -Tpng -o output.png
output.png