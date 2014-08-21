

def gen_wire_stat(width, wirename):
    str1 = width + wirename + '0'
    for i in xrange(1, 24):
        str1 += ', ' + wirename + str(i)
    print str1 + ';'


def gen_clause():
    gen_wire_stat('wire [2:0] ', 'var_value_frombase_')
    gen_wire_stat('wire [2:0] ', 'var_value_tobase_')
    gen_wire_stat('wire [1:0] ', 'freelitcnt_')
    gen_wire_stat('wire [1:0] ', 'imp_drv_')
    gen_wire_stat('wire [1:0] ', 'cclause_')
    gen_wire_stat('wire [1:0] ', 'cclause_drv_')
    gen_wire_stat('wire [1:0] ', 'clausesat_')

    for i in xrange(24):
        print """
    lit1 lit1_%d
    (
        .clk(clk),
        .rst(rst),

        .wr_i(wr_i),
        .var_value_frombase_i(var_value_frombase_%d),
        .var_value_tobase_o(var_value_tobase_%d),

        .freelitcnt_pre(freelitcnt_%d),
        .freelitcnt_next(freelitcnt_%d),

        .imp_drv_i(imp_drv_%d),

        .conflict_c_o(cclause_%d),
        .conflict_c_drv_i(cclause_drv_%d),

        .clausesat_o(clausesat_%d)
    )""" % (i, i, i, i - 1, i, i, i, i, i)

# for i in xrange(24):
# print "assign lock_cnt%d = lock_cnt%d!=2'b00?2'b11:(vars_value_frombase_i[3*%d+2:3*%d+1]==00? 2'b01:2'b00);"%(i,i-1,i,i)
#   print "vars_selected_tobase_o[%d] <= lock_cnt%d!=2'b01;"%(i,i)


def gen_clause_array():
    gen_wire_stat('wire ', 'wr_')
    gen_wire_stat('wire [3*NUM_VARS_A_BIN-1:0] ', 'var_value_tobase_')

    for i in xrange(24):
        print """
    clause clause%d #(
        .NUM_VARS_A_BIN(NUM_VARS_A_BIN)
    (
        .clk(clk), 
        .rst(rst), 
        .wr_i(wr_%d),
        .var_value_frombase_i(var_value_frombase),
        .var_value_tobase_o(var_value_tobase_%d)
    )""" % (i, i, i)


def gen_base():
    gen_wire_stat('\twire [2:0] ', 'var_value_i_')
    gen_wire_stat('\twire [2:0] ', 'var_value_o_')
    gen_wire_stat('\twire ', 'vars_decided_tobase_i_')
    gen_wire_stat('\twire ', 'decide_level_i_')
    gen_wire_stat('\twire ', 'find_conflict_o_')
    gen_wire_stat('\twire ', 'find_imply_o_')
    gen_wire_stat('\twire [1:0] ', 'load_clauses_i_')
    gen_wire_stat('\twire [1:0] ', 'update_clause_o_')
    gen_wire_stat('\twire [NUM_VARS_A_BIN-1:0] ', 'var_level_o_')
    gen_wire_stat('\twire ', 'is_independent_bin_')
    gen_wire_stat('\twire ', 'wr_states_')
    gen_wire_stat('\twire [WIDTH_VAR_STATES-1:0] ', 'var_states_i_')
    gen_wire_stat('\twire [WIDTH_VAR_STATES-1:0] ', 'var_states_o_')
    gen_wire_stat('\twire [9:0] ', 'bkt_bin_num_o_')

    for i in xrange(24):
        print """
    base1 base1%d #(
        .NUM_CLAUSES_A_BIN(NUM_CLAUSES_A_BIN),
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES)
    )
    (
        .clk(clk), 
        .rst(rst), 
        .var_value_i(var_value_i_%d),
        .var_value_o(var_value_o_%d),
        .vars_decided_tobase_i(vars_decided_tobase_i_%d),
        .decide_level_i(decide_level_i_%d),
        .cur_bin_num_i(cur_bin_num_i)
        .find_conflict_o(find_conflict_o_%d),
        .find_imply_o(find_imply_o_%d),
        .is_independent_bin_o(is_independent_bin_%d)
        .apply_analyze_i(apply_analyze_i),
        .bkt_lvl_i(bkt_lvl),
        .bkt_bin_num_o(bkt_bin_num_o_%d),
        .apply_backtrack_i(apply_backtrack_r),
        .apply_load_i(apply_load_i),
        .load_clauses_i(load_clauses_i_%d),
        .apply_update_i(apply_update_i),
        .update_clause_o(update_clause_o_%d),
        .wr_states(wr_states_%d),
        .var_states_i(var_states_i_%d),
        .var_states_o(var_states_o_%d),
        .var_level_o(var_level_o_%d)
    )""" % (i, i, i, i, i, i, i, i, i, i, i, i, i, i, i)


def gen_regs_vid_state():
    # for i in xrange(24):
    #   print 'assign {value_%d, level_%d, reason_bin_%d, isbktlvl_%d} = var_state_%d;'%(i,i,i,i,i)
    # for i in xrange(24):
    #   print "wire level_0_%d = need_update[%d]? level_%d | ~16'b0;;"%(i,i,i)
    # for i in xrange(24):
    #   print "assign ptr_update[%d] = ~ptr_update[%d] && need_update && min_level==level_%d;"%(i,i-1,i)
    # for i in xrange(24):
    #   print "assign need_shift[%d] = ptr_update[%d] | need_shift[%d];"%(i,i,i)
    # for i in xrange(24):
    # print "need_update[%d] <= need_shift[%d]?
    # need_update[%d]:need_update[%d];"%(i,i,i+1,i)
    for i in xrange(24):
        print "valid_var_id_frombram_i==var_id_update_%d | " % (i)


# gen_clause()
# gen_clause_array()
# gen_base()
# for i in xrange(12): print 'wire [WIDTH_VAR_STATES-1 : 0] max_lvl_%d =
# var_level_o_%d>var_level_o_%d? var_level_o_%d:var_level_o_%d;'%(i+1,
# 2*i+1, 2*i, 2*i+1, 2*i)

gen_regs_vid_state()
