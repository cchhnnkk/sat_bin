
/*** 测试数据4，直接冲突 ***/

task se_test_case4();

    $display("===============================================");
    $display("test_case 4");

    bin = '{
        '{0, 2, 0, 2, 2, 0, 0, 0},
        '{1, 0, 1, 0, 2, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0}
    };
    //var state list:
    value   = '{1, 1, 1, 1, 1, 0, 0, 0};
    implied = '{0, 0, 0, 0, 1, 0, 0, 0};
    level   = '{2, 4, 11, 9, 6, 0, 0, 0};
    //lvl state list:
    dcd_bin = '{11, 0, 0, 0, 0, 0, 0, 0};
    has_bkt = '{0, 0, 0, 0, 0, 0, 0, 0};
    //ctrl
    cur_bin_num = 19;
    load_lvl = 16;
    base_lvl = 15;

    //运算过程数据
    process_len = 1;
    process_data = '{
        '{"conflict", 0, 0, 0},
        '{"punsat",   0, 0, 0}
    };

    run_test_case();
endtask

/*
load_bin 19
    c1  2 4 5
    c2  -1 -3 5
    global vars [2, 8, 15, 17, 19]
    local vars  [1, 2, 3, 4, 5]
    value       [1, 1, 1, 1, 1]
    implied     [0, 0, 0, 0, 1]
    level       [2, 4, 11, 9, 6]

    int base_lvl4 = 16;

sat engine run_core: cur_bin == 19
--  bcp
        find conflict in c_array.init_state()
--  analysis the conflict
        conflict c1
        lits    [2, 4, 5]
        value   [1, 1, 1]
        implied [0, 0, 1]
        level   [4, 9, 6]
        bin     [1, 3, 2]
        bkted   [0, 0, 0]
        reason  [0, 0, 0]
--  no learntc
        bkt_bin 0 bkt_lvl 9
----        partial unsat
--  find_global_bkt_lvl
        bkt_bin 2 bkt_lvl 9
--  backtrack_across_bin: bkt_lvl == 9
update_bin 19
    c1  2 4 5
    c2  -1 -3 5
    global vars [2, 8, 15, 17, 19]
    local vars  [1, 2, 3, 4, 5]
    value       [1, 1, 0, 2, 1]
    implied     [0, 0, 0, 0, 1]
    level       [2, 4, 0, 9, 6]
*/
