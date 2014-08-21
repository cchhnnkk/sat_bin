import sat_bin_lvlstate as sat


def run(filename):
    print filename
    sat.control(filename)

if __name__ == '__main__':
    # path = "E:\\sat\\workspace\\partitionCNF\\cnfdata\\"
    path = "E:\\sat\\workspace\\partitionCNF\\cnfdata\\"
    run(path + 'bram_bins_uf20-02.txt')
    run(path + 'bram_bins_uf20-03.txt')
    run(path + 'bram_bins_uf20-04.txt')
    run(path + 'bram_bins_uf20-05.txt')
    run(path + 'bram_bins_uf20-06.txt')
    run(path + 'bram_bins_uf20-07.txt')
    run(path + 'bram_bins_uf20-08.txt')
    run(path + 'bram_bins_uf20-09.txt')
    run(path + 'bram_bins_uf20-10.txt')
