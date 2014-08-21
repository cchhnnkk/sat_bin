
/*** 测试数据3 ***/

task se_test_case3();

    $display("===============================================");
    $display("test_case 3");

    bin = '{
        '{1, 0, 2, 0, 2, 0, 0, 0},
        '{0, 2, 0, 1, 1, 0, 0, 0},
        '{0, 2, 0, 0, 2, 0, 0, 0},
        '{0, 2, 0, 1, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0}
    };
    //var state list:
    value   = '{1, 2, 1, 2, 0, 0, 0, 0};
    implied = '{1, 0, 1, 1, 0, 0, 0, 0};
    level   = '{0, 1, 2, 3, 0, 0, 0, 0};
    //lvl state list:
    dcd_bin = '{2, 0, 0, 0, 0, 0, 0, 0};
    has_bkt = '{0, 0, 0, 0, 0, 0, 0, 0};
    //ctrl
    cur_bin_num = 2;
    load_lvl = 3;
    base_lvl = 2;

    //运算过程数据
    process_len = 1;
    process_data = '{
        '{"psat",   0, 0, 0}
    };

    run_test_case();
endtask


// todooo
/*
c1  -1 3 5
c2  2 -4 -5
c3  2 5
c4  2 -4
global vars [1, 2, 5, 6, 7]
local vars  [1, 2, 3, 4, 5]
value       [1, 2, 1, 2, 0]
implied     [1, 0, 1, 1, 0]
level       [0, 1, 2, 3, 0]

sat engine run_core: cur_bin == 3
--  bcp
--  decision
----        partial sat
*/
