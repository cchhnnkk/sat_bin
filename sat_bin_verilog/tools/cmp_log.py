#!python
# -*- coding: utf-8 -*-

# cmp_log.py sb_verilog.log sb_python.log 1

import sys

vmax = 8
cmax = 8


def get_strls(dcd_bin, has_bkt, cur_lvl_o):
    str_ls = ''
    str_d = 'dcd_bin = '
    for l in dcd_bin:
        str_d += str(l) + ' '
    str_ls += str_d[:-1] + '\n'

    str_d = 'has_bkt = '
    for l in has_bkt:
        str_d += str(l) + ' '
    str_ls += str_d[:-1] + '\n'
    return str_ls


def find_v_log_update_bin(starti, vlines):
    strc = ''
    strvs = ''
    strls = ''
    str_var_value = ''
    while starti < len(vlines):
        line = vlines[starti].strip()
        if 'result var value' in line:       # result var value
            str_var_value += line
            str_var_value += '\n'
            starti += 1
            line = vlines[starti].strip()
            str_var_value += line
            str_var_value += '\n'
            starti = len(vlines)
            break
        index = line.find('cnt_update_bin', 0)
        starti += 1
        if index == -1:
            continue

        index += len('cnt_update_bin = ')
        cnt_up = int(line[index:])

        starti += 2
        line = vlines[starti].strip()
        starti += 1
        index = line.find('done_update_cbin', 0)
        index += len('done_update_cbin = ')
        num_bin = int(line[index:])

        strc += 'update_bin %d\n' % num_bin
        strc += 'cnt_update %d\n' % cnt_up

        ci = 1
        for i in xrange(cmax):
            line = vlines[starti].strip()
            starti += 1
            index = line.find('=', 0)
            index += len('= ')
            str1 = 'c%d  ' % ci
            tag = 0
            i = 0
            for c in line[index:]:
                var = i + 1
                if c in '012':
                    i += 1
                if c == '1':
                    str1 += str(-var) + ' '
                    tag = 1
                elif c == '2':
                    str1 += str(var) + ' '
                    tag = 1

            if tag == 1:
                strc += str1 + '\n'
                ci += 1

        line = vlines[starti].strip()
        starti += 1   # done_update_vs
        if 'done_update_vs' not in line:
            break
        line = vlines[starti].strip()
        starti += 1
        index = line.find('value =', 0)
        strvs += line[index:]
        strvs += '\n'

        line = vlines[starti].strip()
        starti += 1
        index = line.find('imply =', 0)
        strvs += line[index:]
        strvs += '\n'

        line = vlines[starti].strip()
        starti += 1
        index = line.find('level =', 0)
        strvs += line[index:]
        strvs += '\n'

        line = vlines[starti].strip()
        starti += 1   # done_update_ls
        line = vlines[starti].strip()
        starti += 1
        index = line.find('dcd_bin =', 0)
        index += len('dcd_bin = ')
        dcd_bin = line[index:].split(' ')

        line = vlines[starti].strip()
        starti += 1
        index = line.find('has_bkt =', 0)
        index += len('has_bkt = ')
        has_bkt = line[index:].split(' ')

        strlvl = ''
        line = vlines[starti].strip()
        starti += 1
        index = line.find('base_lvl_o =', 0)
        strlvl += line[index:]
        strlvl += '\n'

        line = vlines[starti].strip()
        index = line.find('cur_lvl_o =', 0)
        strlvl += line[index:]
        strlvl += '\n'

        index += len('cur_lvl_o = ')
        cur_lvl_o = int(line[index:])

        strls += get_strls(dcd_bin, has_bkt, cur_lvl_o)
        strvs += strlvl

        break

    return strc, strvs, strls, str_var_value, starti


def complement(strp):
    i = 0
    strv = ''
    for c in strp:
        if c in ',':
            i += 1
        if c not in '[],':
            strv += c

    for j in xrange(i + 1, vmax):
        strv += ' 0'

    return strv


def find_p_log_update_bin(starti, plines):
    strc = ''
    strvs = ''
    strls = ''
    str_var_value = ''
    while starti < len(plines):
        line = plines[starti].strip()
        if 'result var value' in line:       # result var value
            str_var_value += line
            str_var_value += '\n'
            starti += 1
            line = plines[starti].strip()
            str_var_value += line
            str_var_value += '\n'
            starti = len(plines)
            break
        starti += 1
        index = line.find('update_bin', 0)
        if index == -1:
            continue

        partial_sat = False
        if 'partial sat' in plines[starti - 2]:
            partial_sat = True

        # cnt_update
        strc += line + '\n'
        line = plines[starti].strip()
        starti += 1

        while 'global vars' not in line:
            strc += line + '\n'
            line = plines[starti].strip() + ' '
            starti += 1

        if partial_sat is False:
            break

        starti += 2
        line = plines[starti].strip()
        starti += 1
        index = line.find('[', 0)   # value
        strvs += 'value = ' + complement(line[index:])
        strvs += '\n'

        line = plines[starti].strip()
        starti += 1
        index = line.find('[', 0)
        strvs += 'imply = ' + complement(line[index:])
        strvs += '\n'

        line = plines[starti].strip()
        starti += 1
        index = line.find('[', 0)
        strvs += 'level = ' + complement(line[index:])
        strvs += '\n'

        line = plines[starti].strip()
        starti += 1   # lvl state list:
        line = plines[starti].strip()
        starti += 1
        index = line.find('[', 0)
        strls += 'dcd_bin = ' + complement(line[index:])
        strls += '\n'

        line = plines[starti].strip()
        starti += 1
        index = line.find('[', 0)
        strls += 'has_bkt = ' + complement(line[index:])
        strls += '\n'

        starti += 2
        line = plines[starti].strip()
        starti += 1
        index = line.find(':', 0)
        index += 2
        strvs += 'base_lvl_o = ' + str(int(line[index:])-1)
        strvs += '\n'

        line = plines[starti].strip()
        starti += 1
        index = line.find(':', 0)
        index += 2
        strvs += 'cur_lvl_o = ' + str(int(line[index:])-1)
        strvs += '\n'

        break

    return strc, strvs, strls, str_var_value, starti


def print_diff(strv, strp):
    print '======================== verilog log ========================'
    print strv
    print '======================== python log  ========================'
    print strp
    print '------------------------ compare log ------------------------'
    str1 = ''
    for i in xrange(len(strv)):
        str1 += strv[i]
        if strv[i] != strp[i]:
            print str1
            break
    print ''
    print 'len_strv %d' % len(strv)
    print 'len_strp %d' % len(strp)


if __name__ == '__main__':

    test_case = 1
    if(len(sys.argv) == 4):
        vfilename = sys.argv[1]
        pfilename = sys.argv[2]
        test_case = int(sys.argv[3])

    vfp = open(vfilename)
    pfp = open(pfilename)

    vlines = vfp.readlines()
    plines = pfp.readlines()

    vindex = 0
    pindex = 0
    for i, line in enumerate(vlines):
        if 'test_case' in line:
            if ' ' + str(test_case) in line:
                vindex = i
                break
    error = False
    while vindex < len(vlines) and pindex < len(plines):
        v_c, v_vs, v_ls, v_var_value, vindex = find_v_log_update_bin(vindex, vlines)
        p_c, p_vs, p_ls, p_var_value, pindex = find_p_log_update_bin(pindex, plines)
        strv = v_c + v_vs
        strp = p_c + p_vs
        if strv != strp:
            error = True
            print_diff(strv, strp)
            break

    if not error:
        if v_var_value != p_var_value:
            error = True
            print_diff(v_var_value, p_var_value)
        else:
            print v_var_value

    if error:
        print 'cmp_log result is wrong!'
    else:
        print 'cmp_log result is right!'
