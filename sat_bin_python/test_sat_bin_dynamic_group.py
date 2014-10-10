#!python
# -*- coding: utf-8 -*-

import sys
# import sat_bin_dynamic_group as sat
import sat_bin_regroup_bkt_bin as sat
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
    sat.loglevel = loglevel
    sat.log2file = log2file
    sat.run(filename, cmax, vmax)


def test_uf20_91_100(n_test, vmax_i, cmax_i):
    global vmax, cmax
    vmax = vmax_i
    cmax = cmax_i
    if n_test > 100:
        n_test = 100

    path = "testdata/uf20-91/"
    for i in xrange(0, n_test, 1):
        filename = "uf20-0%d.cnf" % (i + 1)
        run_all(path + filename)


def test_batch(filenames, n_test, vmax_i, time_sec):
    global vmax, cmax
    vmax = vmax_i
    cmax = vmax_i * 2
    sat.TIME_OUT_LIMIT = time_sec
    global loglevel, log2file
    # loglevel = logging.WARNING
    loglevel = logging.CRITICAL
    log2file = False
    for f in filenames:
        run_all(f)


def test_uf20(n_test, vmax_i, time_sec):
    filenames = []
    path = "testdata/uf20-91/"
    for i in xrange(0, n_test, 1):
        filename = "uf20-0%d.cnf" % (i + 1)
        filenames += [path + filename]
    test_batch(filenames, n_test, vmax_i, time_sec)


def test_uf50(n_test, vmax_i, time_sec):
    filenames = []
    path = "testdata/uf50-218/"
    for i in xrange(0, n_test, 1):
        filename = "uf50-0%d.cnf" % (i + 1)
        filenames += [path + filename]
    test_batch(filenames, n_test, vmax_i, time_sec)


def test_uf100(n_test, vmax_i, time_sec):
    filenames = []
    path = "testdata/uf100-430/"
    for i in xrange(0, n_test, 1):
        filename = "uf100-0%d.cnf" % (i + 1)
        filenames += [path + filename]
    test_batch(filenames, n_test, vmax_i, time_sec)


def test_uuf50(n_test, vmax_i, time_sec):
    filenames = []
    path = "testdata/uuf50-218/"
    for i in xrange(0, n_test, 1):
        filename = "uuf50-0%d.cnf" % (i + 1)
        filenames += [path + filename]
    test_batch(filenames, n_test, vmax_i, time_sec)


def test_file(filename, vmax_i, cmax_i):
    global vmax, cmax
    vmax = vmax_i
    cmax = cmax_i
    global loglevel, log2file
    loglevel = logging.CRITICAL
    log2file = True
    run_all(filename)

if __name__ == '__main__':
    n = 16
    if len(sys.argv) == 2:
        n = int(sys.argv[1])
    # test_uf20_91_100(100, n, n)
    # n_test, vmax_i, time_sec
    # test_uf50(10, n, 1000)
    test_uf100(1, n, 1000)
    # test_uuf50(1, n, 1000)
    # test_file("testdata/uf20-91/uf20-01.cnf", 8, 8)
    # test_file("testdata/uf100-430/uf100-01.cnf", 16, 16)
    # test_file("testdata/uuf50-218/uuf50-01.cnf", 16, 32)
    # test_file("testdata/aloul-chnl11-13.cnf", 1000, 1000)
#     test_file("F:/sat/reference/benchmarks/satlib-benchmark/\
# uuf50-218/UUF50.218.1000/uuf50-09.cnf", 100, 300)
