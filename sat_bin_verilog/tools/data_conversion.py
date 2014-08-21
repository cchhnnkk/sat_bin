#!python
# -*- coding: utf-8 -*-

NUM_VARS = 8


def var_value_to_list(var_value, num=NUM_VARS):
    """
        input: var_value_list
        output: value_list, imply_list
    """
    value_list = []
    imply_list = []
    for i in xrange(num):
        v = var_value % 8
        var_value = var_value / 8
        imply_list += [v % 2]
        v = v / 2
        value_list += [v]
    print "value =", value_list
    print "imply =", imply_list
    return value_list, imply_list


def clause_to_list(clause, num=NUM_VARS):
    """
        input: var_value_list
        output: value_list, imply_list
    """
    value_list = []
    for i in xrange(num):
        v = clause % 4
        clause = clause / 4
        value_list += [v]
    # print "clause =", value_list
    return value_list
