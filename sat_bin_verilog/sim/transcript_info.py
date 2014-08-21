#!python
# coding:utf-8


def repeat_space(n):
    s = ''
    for i in xrange(n):
        s += ' '
    return s


def filter1(data):
    data_filter = []

    start_tag = 0
    for i, l in enumerate(data):
        if "start sim" in l:
            start_tag = i

    info_data = []
    tab_len = 4
    for i in xrange(start_tag, len(data)):
        if "# " in data[i]:
            line = data[i][2:]
            # print line
            if 'ns ' in line:
                l = line.strip().split()
                if tab_len < len(l[0]):
                    tab_len = len(l[0])
                    # print l[0], tab_len
            info_data += [line]

    print "    tab_len=" + str(tab_len)
    cur_time = 0
    for line in info_data:
        if line[0] == '=':
            pass
        elif line[0] not in ' \t':
            l = line.strip().split()
            if len(l) == 0:
                continue
            n = tab_len - len(l[0])
            index1 = line.find(' ')
            index2 = line.find('\t')
            index = index1
            if index == -1 or index > index2:
                index = index2
            # print index
            if index != -1:
                line = l[0] + repeat_space(n + 1) + line[index + 1:]

            if len(l[0]) >= 3 and l[0][-2:]=='ns':
                next_time = int(l[0][:-2])
                if cur_time < next_time:
                    cur_time = next_time
                    data_filter += ['----------------------------------\n\n']

        elif line[0] == '\t':
            line = repeat_space(tab_len + 1) + line[1:]
        else:
            line = repeat_space(tab_len) + line[:]
        data_filter += [line]
        
    return data_filter


def filter2(data):
    data_filter = []
    for i in xrange(len(data) - 1, 0, -1):
        line = data[i]
        if 'ns info ' in line:
            if data[i + 1] == data[i - 2]:
                # print data[i + 1]
                del data[i + 1]

    return data


if __name__ == '__main__':
    f = open("transcript")
    data = f.readlines()
    f.close()

    data1 = filter1(data)
    data2 = filter2(data1)


    f = open("transcript.log", "w")
    for l in data2:
        f.write(l)
    f.close()

    print 'please view transcript.log'
