#!python
# -*- coding: utf-8 -*-

import sys


def gen_inst(filename):
    name = ''
    exittag = 0
    str_inst = ''
    str_stmt = ''
    first = False
    for l in file(filename):
        liststrip = l.strip(' |\t|,|\n').split()
        stmt = l.strip(' |\t|,|\n')
        # print liststrip
        if len(liststrip) == 0:
            continue

        for i, l in enumerate(liststrip):
            if l == '':
                del liststrip[i]

        # module name
        if liststrip[0] == 'module':
            name = liststrip[1]
            str_inst += '%s ' % (name)
            exittag = 1
            if '#' in l:
                exittag = 2
                str_inst += '#'
                first = True
            str_inst += '('

        # comment
        elif '//' in liststrip[0]:
            str_inst += ',\n\t%s' % stmt

        # parameters
        elif exittag == 2:
            if l[0] == ')':
                str_inst += '\n)\n%s(' % name
                first = True
                exittag = 1
            elif first:
                str_inst += '\n\t.%s(%s)' % (liststrip[1], liststrip[1])
                first = False
            else:
                str_inst += ',\n\t.%s(%s)' % (liststrip[1], liststrip[1])

        # ports
        elif exittag == 1:
            if l[0] == ')':
                str_inst += '\n);\n'
                exittag = 0
                break
            elif l[0] != '(' and first:
                str_inst += '\n\t.%s(%s)' % (liststrip[-1], liststrip[-1])
                stmt = stmt.replace('reg ', '')
                stmt = stmt.replace('input', 'reg')
                stmt = stmt.replace('output', 'wire')
                str_stmt += stmt + ';\n'
                first = False
            elif l[0] != '(':
                str_inst += ',\n\t.%s(%s)' % (liststrip[-1], liststrip[-1])
                stmt = stmt.replace('reg ', '')
                stmt = stmt.replace('input', 'reg')
                stmt = stmt.replace('output', 'wire')
                str_stmt += stmt + ';\n'

    return str_stmt + str_inst


def fix_comment(str_1):
    str_2 = ''
    lines = str_1.split('\n')
    for l in lines:
        if '//' in l:
            l = l.strip(',')
        str_2 += l + '\n'
        
    return str_2


if __name__ == '__main__':
    if len(sys.argv) == 2:
        filename = sys.argv[1]
    else:
        filename = 'var1.v'

    str_1 = gen_inst(filename)
    str_2 = fix_comment(str_1)
    print str_2
