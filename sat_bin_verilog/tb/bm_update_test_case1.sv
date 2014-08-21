/*
c1  1 -3 
c2  2 -4 
c3  3 5 
global vars [2, 3, 4, 5, 6]
local vars  [1, 2, 3, 4, 5]
value       [1, 1, 1, 1, 2]
implied     [0, 0, 1, 1, 1]
level       [1, 2, 1, 2, 1]
*/

task bm_update_test_case1();
    bin_updated = '{
        '{2, 0, 1, 0, 0, 0, 0, 0},
        '{0, 2, 0, 1, 0, 0, 0, 0},
        '{0, 0, 2, 0, 2, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0}
    };
    //var state list:
    value_updated   = '{1, 1, 1, 1, 2, 0, 0, 0};
    implied_updated = '{0, 0, 1, 1, 1, 0, 0, 0};
    level_updated   = '{1, 2, 1, 2, 1, 0, 0, 0};
    //lvl state list:
    dcd_bin_updated = '{2, 2, 0, 0, 0, 0, 0, 0};
    has_bkt_updated = '{0, 0, 0, 0, 0, 0, 0, 0};
    //ctrl
    cur_bin_num_updated = 3;
    cur_lvl_updated = 3;
    base_lvl_updated = 1;

    run_bm_update();
endtask

