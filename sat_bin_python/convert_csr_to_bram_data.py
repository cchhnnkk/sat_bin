import os
import argparse


def convert_csr_to_bram_data(filename, resultfilename):
    lists = [l for l in file(filename) if l[0] not in '\n']
    vbin = []
    cmax = 0
    vmax = 0
    fp_packbin = open(resultfilename, 'w')
    i = 0
    while(i < len(lists)):
        liststrip = lists[i].strip().split()
        if liststrip[0] == 'total':
            fp_packbin.write(lists[i])
        elif liststrip[0] == 'cmax':
            fp_packbin.write(lists[i])
            cmax = int(liststrip[-1])
        elif liststrip[0] == 'vmax':
            fp_packbin.write(lists[i])
            vmax = int(liststrip[-1])
        elif liststrip[0] == 'bin':
            fp_packbin.write('\n' + lists[i])
        elif liststrip[0] == 'variables':
            fp_packbin.write(lists[i])
            i += 1
            fp_packbin.write(lists[i])
            vbin = [int(l) for l in lists[i].strip().split()]
        elif liststrip[0] == 'clauses':
            fp_packbin.write(lists[i])
        else:
            c = [int(l) for l in liststrip]
            str1 = '\t\t'
            for j in xrange(vmax):
                p = '0'
                if j < len(vbin):
                    if vbin[j] in c:  # true
                        p = '2'
                        j += 1
                    elif -vbin[j] in c:  # false
                        p = '1'
                        j += 1
                str1 += p + ' '
            fp_packbin.write(str1 + '\n')

        i += 1


def argument_parse():
    parser = argparse.ArgumentParser(description="convert_csr_cnf_data")
    parser.add_argument('--i',
                        type=str,
                        help='input file',
                        default='bins_uf20-01.txt'
                        )
    parser.add_argument('--o',
                        type=str,
                        help='ouptput result',
                        default='bram_bins_uf20-01.txt'
                        )
    return parser.parse_args()

if __name__ == '__main__':
    # filename = 'bram_bins_uf20-01.txt'
    arguments = argument_parse()
    filename = arguments.i
    resultfilename = arguments.o
    convert_csr_to_bram_data(filename, resultfilename)
