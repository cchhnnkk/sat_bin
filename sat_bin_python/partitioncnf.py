#!python
# -*- coding: utf-8 -*-
#
# use shareC_len shareV_len list to optimize the compute_clauses_gravity
# the time to solve 'simon-s02b-r4b1k1.1.cnf' is 43.0280668964 s
#
import argparse
import numpy as np
import matplotlib.pyplot as plt

kk_debug = False

c_rank_best = np.array([])
v_rank_best = np.array([])
cost_best = 0
cbin_best = []
vbin_best = []

shareC_len = []
shareV_len = []
varlist = []

cmax = 4
vmax = 8


def get_share_len1(a, b):
    return len(set(a) & set(b))


def get_share_len2(a, b):
    # s = set(b)
    sharelist = [item for item in a if item in b]
    return len(sharelist)


# A and B are sorted
def get_share_len3(A, B):
    s_len = 0
    j = 0
    len_B = len(B)

    for x in A:
        for i in range(j, len_B):
            y = B[i]
            if x == y:
                s_len += 1
            elif x < y:
                j = i
                break

    return s_len


def creat_varlist(clauses, c_adjacent, v_adjacent, nc, nv):
    for i in range(nc):
        for j in range(len(clauses[i])):
            v = clauses[i][j]
            v = abs(v)
            v -= 1
            clauses[i][j] = v
        clauses[i].sort()

    global varlist
    for i in xrange(nv):
        varlist += [[]]

    for i in xrange(nc):
        for v in clauses[i]:
            varlist[v] += [i]

    for i in range(nc):
        c_adjacent += [set()]
        for v in clauses[i]:
            for c in varlist[v]:
                c_adjacent[i].add(c)

    for i in range(nv):
        v_adjacent += [set()]
        for c in varlist[i]:
            for v in clauses[c]:
                v_adjacent[i].add(v)

    global shareC_len
    shareC_len = [[0] * nc] * nc
    for i in xrange(nc):
        for j in c_adjacent[i]:
            shareC_len[i][j] = get_share_len2(clauses[i], clauses[j])
            shareC_len[j][i] = shareC_len[i][j]

    global shareV_len
    shareV_len = [[0] * nv] * nv
    for i in xrange(nv):
        for j in v_adjacent[i]:
            shareV_len[i][j] = get_share_len2(varlist[i], varlist[j])
            shareV_len[j][i] = shareV_len[i][j]

    # for i in xrange(nc):
    #   print share_len[i]


def compute_cost(clauses, nc, nv, cbin, vbin):
    n_bin = len(cbin)
    # Number of bins
    cost1 = n_bin

    # The sum across all variables v in the CNF instance, of the number of
    # bins in which v occurs
    cost2 = sum([len(vset) for vset in vbin])

    # The sum across all variables v in the CNF instance, of the number of
    # bins v spans
    v_minbin = np.array(nv * [n_bin - 1])
    v_maxbin = np.array(nv * [0])
    for i in xrange(len(vbin)):
        for v in vbin[i]:
            if i < v_minbin[v]:
                v_minbin[v] = i

            if i > v_maxbin[v]:
                v_maxbin[v] = i
    v_span = v_maxbin - v_minbin
    cost3 = sum([abs(l) for l in v_span])
    cost = cost1 + cost2 + cost3
    if kk_debug:
        print cost1, cost2, cost3, cost
    return cost


def compute_clauses_gravity(clauses, c_adjacent, nc, c_rank, c_gravity):
    global share_len
    for i in xrange(nc):
        for j in c_adjacent[i]:
            c_gravity[i] += c_rank[j] * shareC_len[i][j]


def compute_vars_gravity(clauses, v_adjacent, nv, v_rank, v_gravity):
    global share_len
    for i in range(nv):
        for j in v_adjacent[i]:
            v_gravity[i] += v_rank[j] * shareV_len[i][j]


def compute_bandwidth(clauses, c_rank, v_rank):
    cbandwidth = 0
    vbandwidth = 0
    nc = len(c_rank)
    nv = len(v_rank)
    for i in range(nc):
        c = clauses[c_rank[i]]
        v_indexs = v_rank[c]
        bw = max(v_indexs) - min(v_indexs)
        if bw > cbandwidth:
            cbandwidth = bw

    for i in range(nv):
        varl = varlist[v_rank[i]]
        c_indexs = c_rank[varl]
        bw = max(c_indexs) - min(c_indexs)
        if bw > vbandwidth:
            vbandwidth = bw

    if kk_debug:
        print 'bandwidth: ', cbandwidth + vbandwidth + 1


def bin_packing(clauses, nc, c_rank, cmax, vmax):
    c_index = c_rank.argsort()
    # print c_rank
    # print c_index
    cbin = [[]]
    vbin = [set()]
    j = 0
    for i in range(nc):
        ci = int(c_index[i])
        c = clauses[ci]
        vset = set(c)
        newset = vset | vbin[j]
        if len(newset) < vmax and len(cbin[j]) < cmax:
            cbin[j] += [ci]
            vbin[j] |= vset
            # print ci, cbin[j]
        else:
            j += 1
            cbin += [[ci]]
            vbin += [vset]

    return cbin, vbin


def plot_cnf(clauses, nc, c_rank, v_rank):
    x = []
    y = []
    # print c_rank
    for i in xrange(nc):
        c_index = c_rank[i]
        for v in clauses[c_index]:
            v_index = v_rank[v]
            x += [v_index]
            y += [c_index]

    plt.scatter(x, y)
    plt.xlabel('variable')
    plt.ylabel('clause')


def min_bandwidth(clauses, c_adjacent, v_adjacent, nc, nv, times, cmax, vmax):
    global c_rank_best
    global v_rank_best
    global cost_best

    c_rank = np.array(range(nc))
    v_rank = np.array(range(nv))
    cbin, vbin = bin_packing(clauses, nc, c_rank, cmax, vmax)
    cost_best = compute_cost(clauses, nc, nv, cbin, vbin)
    cbin_best = cbin
    vbin_best = vbin

    plt.subplot(1, 2, 1)
    plot_cnf(clauses, nc, c_rank, v_rank)
    itag = 0
    for i in range(0, times):
        # Compute Gravity of all clauses
        c_gravity = np.array(nc * [0])
        compute_clauses_gravity(clauses, c_adjacent, nc, c_rank, c_gravity)
        # Rearrange Clauses in increasing order of gravity
        c_rank = c_gravity.argsort()

        # Compute Gravity of all variables
        v_gravity = np.array(nv * [0])
        compute_vars_gravity(clauses, v_adjacent, nv, v_rank, v_gravity)
        compute_bandwidth(clauses, c_rank, v_rank)
        # Rearrange Variables in increasing order of gravity
        v_rank = v_rank[v_gravity.argsort()]
        cbin, vbin = bin_packing(clauses, nc, c_rank, cmax, vmax)
        cost = compute_cost(clauses, nc, nv, cbin, vbin)
        if cost_best > cost:
            cost_best = cost
            c_rank_best = c_rank[:]
            v_rank_best = v_rank[:]
            cbin_best = cbin
            vbin_best = vbin
            itag = i

    if kk_debug:
        print itag
    plt.subplot(1, 2, 2)
    plot_cnf(clauses, nc, c_rank, v_rank)

    plt.tight_layout()

    return cbin_best, vbin_best


def print_bin_info(clauses, cbin, vbin):
    for i in xrange(len(cbin)):
        if kk_debug:
            print 'bin', i
        if kk_debug:
            print vbin[i]
        if kk_debug:
            for c in cbin[i]:
                print c, clauses[c]


def write_result(filename, resultfilename, cbin, vbin, nc, nv, cmax, vmax):
    # origin cnf file
    cnf = [l.strip().split() for l in file(filename) if l[0] not in 'c%0\n']
    clauses = [[int(x) for x in m[:-1]]
               for m in cnf if m[0] != 'p']  # result packed bin file
    fp_bin = open(resultfilename, 'w')
    Nbin = len(cbin)
    fp_bin.write('total num of bins      :  ' + str(Nbin) + '\n')
    fp_bin.write('total num of variables :  ' + str(nv) + '\n')
    fp_bin.write('total num of clauses   :  ' + str(nc) + '\n')
    fp_bin.write('cmax of each bin       :  ' + str(cmax) + '\n')
    fp_bin.write('vmax of each bin       :  ' + str(vmax) + '\n\n')

    for i in xrange(Nbin):
        fp_bin.write('bin ' + str(i + 1) + '\n')
        fp_bin.write('\t')
        fp_bin.write('variables : ' + str(len(vbin[i])) + '\n')
        fp_bin.write('\t\t')
        vlist = list(vbin[i])
        vlist.sort()
        for v in vlist:
            fp_bin.write(str(v + 1) + ' ')
        fp_bin.write('\n')
        fp_bin.write('\t')
        fp_bin.write('clauses : ' + str(len(cbin[i])) + '\n')
        # print 'cbin'+str(i)
        # print cbin[i]
        for c in cbin[i]:
            fp_bin.write('\t\t')
            for lit in clauses[c]:
                fp_bin.write(str(lit) + ' ')
            fp_bin.write('\n')
        fp_bin.write('\n')


def run(filename, resultfilename):
    times = 10
    # filename = 'uf20-01.txt'
    # filename = 'simon-s02b-r4b1k1.1.cnf'
    cnf = [l.strip().split() for l in file(filename) if l[0] not in 'c%0\n']
    clauses = [[int(x) for x in m[:-1]] for m in cnf if m[0] != 'p']
    nv = [int(n[2]) for n in cnf if n[0] == 'p'][0]
    nc = len(clauses)
    if kk_debug:
        print 'variable:    ' + str(nv)
    if kk_debug:
        print 'clauses:     ' + str(len(clauses))
    sumlen = sum([len(c) for c in clauses])
    if kk_debug:
        print 'sparse radio: ' + str(sumlen * 1.0 / nv / nc)
    c_adjacent = []
    v_adjacent = []
    creat_varlist(clauses, c_adjacent, v_adjacent, nc, nv)

    cbin, vbin = min_bandwidth(
        clauses, c_adjacent, v_adjacent, nc, nv, times, cmax, vmax)

    if kk_debug:
        print 'sparse radio of packed bin: ' \
            + str(sumlen * 1.0 / len(cbin) / cmax / vmax)

    # resultfilename = 'bins_'+filename
    write_result(filename, resultfilename, cbin, vbin, nc, nv, cmax, vmax)


def argument_parse():
    parser = argparse.ArgumentParser(description="convert_csr_cnf_data")
    parser.add_argument('--i',
                        type=str,
                        help='input file',
                        default='uf20-01.txt'
                        )
    parser.add_argument('--o',
                        type=str,
                        help='ouptput result',
                        default='bram_bins_uf20-01.txt'
                        )
    parser.add_argument('--vmax',
                        type=int,
                        help='vmax',
                        default=8
                        )
    parser.add_argument('--cmax',
                        type=int,
                        help='cmax',
                        default=4
                        )
    return parser.parse_args()


def main():
    arguments = argument_parse()
    filename = arguments.i

    resultfilename = arguments.o
    global vmax, cmax
    vmax = arguments.vmax
    cmax = arguments.cmax
    # path = "E:\\sat\\reference\\benchmarks\\satlib-benchmark\\uf20-91\\"
    # filename = "uf20-0%d.cnf" % 232
    # resultfilename = 'bram_' + filename
    # filename = path + filename
    run(filename, resultfilename)

if __name__ == '__main__':
    from time import clock
    # import profile
    start = clock()
    # profile.run("main()")
    main()
    finish = clock()
    if kk_debug:
        print 'run time', (finish - start), 's'
    # plt.show()
