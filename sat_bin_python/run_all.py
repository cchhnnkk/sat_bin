#!python

import sys
import partitioncnf as pcnf
import convert_csr_to_bram_data as cvt_bram
# import sat_bin_static_decision as sat
import sat_bin as sat
import logging

vmax = 8
cmax = 4
loglevel = logging.CRITICAL
# loglevel = logging.WARNING
# loglevel = logging.DEBUG
# loglevel = logging.INFO
# log2file = False
log2file = True


def run_all(filename):
    print filename
    binfile = 'bin.txt'
    print '\tpartition the CNF'
    pcnf.vmax = vmax
    pcnf.cmax = cmax
    pcnf.run(filename, binfile)
    bramfile = 'bram.txt'
    cvt_bram.convert_csr_to_bram_data(binfile, bramfile)
    print '\tsolve the sat'
    sat.loglevel = loglevel
    sat.log2file = log2file
    sat.run(bramfile)


def test_uf20_91_100(n_test, vmax_i, cmax_i):
    global vmax, cmax
    vmax = vmax_i
    cmax = cmax_i
    if n_test > 100:
        n_test = 100

    path = "testdata/uf20-91/"
    if len(sys.argv) == 2:
        start = int(sys.argv[1])
    else:
        start = 0

    for i in xrange(start, n_test, 1):
        filename = "uf20-0%d.cnf" % (i + 1)
        run_all(path + filename)


def test_uf50(n_test, vmax_i, time_sec):
    global vmax, cmax
    vmax = vmax_i
    cmax = vmax_i

    # sat.TIME_OUT_LIMIT = 10     # 10s
    sat.TIME_OUT_LIMIT = time_sec
    global loglevel, log2file
    # loglevel = logging.WARNING
    loglevel = logging.CRITICAL
    log2file = False

    path = "testdata/uf50-91/"
    if len(sys.argv) == 2:
        start = int(sys.argv[1])
    else:
        start = 0

    for i in xrange(start, n_test, 1):
        filename = "uf50-0%d.cnf" % (i + 1)
        run_all(path + filename)


def test_file(filename, vmax_i, cmax_i, random_pcnf):
    global vmax, cmax
    vmax = vmax_i
    cmax = cmax_i
    global loglevel, log2file
    loglevel = logging.CRITICAL
    log2file = True
    pcnf.random_pcnf = random_pcnf
    run_all(filename)

if __name__ == '__main__':
    # test_uf20_91_100(100, 4, 4)
    # n_test, vmax_i, time_sec
    test_uf50(10, 16, 1000)
    # test_file("testdata/uf20-91/uf20-01.cnf", 8, 4, False)
    # for i in range(10):
    #     test_file("testdata/uf20-91/uf20-01.cnf", 8, 4, True)
    # for i in range(10):
    #     test_file("testdata/uf20-91/uf20-01.cnf", 16, 8, True)
    # for i in range(10):
    #     test_file("testdata/uf20-91/uf20-01.cnf", 32, 16, True)
    # test_file("testdata/aloul-chnl11-13.cnf", 1000, 1000)
#     test_file("F:/sat/reference/benchmarks/satlib-benchmark/\
# uuf50-218/UUF50.218.1000/uuf50-09.cnf", 100, 300)
