/*** 测试数据5，bin内回退 ***/

task se_test_case5();

    $display("===============================================");
    $display("test_case 5");

    bin = '{
        '{1, 0, 0, 1, 0, 2, 0, 0},
        '{0, 1, 2, 0, 2, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0},
        '{0, 0, 0, 0, 0, 0, 0, 0}
    };
    //var state list:
    value   = '{1, 2, 1, 2, 1, 2, 0, 0};
    implied = '{0, 0, 0, 1, 1, 1, 0, 0};
    level   = '{11, 12, 3, 10, 10, 10, 0, 0};
    //lvl state list:
    dcd_bin = '{3, 5, 5, 5, 16, 5, 0, 0};
    has_bkt = '{1, 0, 1, 0, 0, 0, 0, 0};
    //ctrl
    cur_bin_num = 5;
    load_lvl = 12;
    base_lvl = 9;

    //运算过程数据
    process_len = 3;
    process_data = '{
        '{"conflict", 0, 0, 0},
        '{"bkt_curb", 0, 0, 0},
        '{"bcp",      1, 1, 10},
        '{"psat",     0, 0, 0}
    };

    run_test_case();
endtask

/*
load_bin 5
	c1  -1 -4 6
	c2  -2 3 5
	global vars [4, 5, 7, 10, 12, 19]
	local vars  [1, 2, 3, 4, 5, 6]
	value       [1, 2, 1, 2, 1, 2]
	implied     [0, 0, 0, 1, 1, 1]
	level       [11, 12, 3, 10, 10, 10]
sat engine run_core: cur_bin == 5
--	bcp
		find conflict in c_array.init_state()
--	analysis the conflict
		conflict c2
		lits    [-2, 3, 5]
		value   [2, 1, 1]
		implied [0, 0, 1]
		level   [12, 3, 10]
		bin     [5, 1, 5]
		bkted   [0, 1, 0]
		reason  [0, 0, 0]

--	no learntc
		bkt_bin 5 bkt_lvl 11
--	backtrack_cur_bin: bkt_lvl == 11
--	bcp
		c2 var 2 gvar 5 value 1 level 10
		lits    [-2, 3, 5]
		value   [1, 1, 1]
		implied [1, 0, 1]
		level   [10, 3, 10]
		bin     [5, 1, 5]
		bkted   [1, 1, 1]
		reason  [2, 0, 0]

--	decision
----		partial sat
update_bin 5
	c1  -1 -4 6
	c2  -2 3 5
	global vars [4, 5, 7, 10, 12, 19]
	local vars  [1, 2, 3, 4, 5, 6]
	value       [2, 1, 1, 2, 1, 2]
	implied     [0, 1, 0, 1, 1, 1]
	level       [11, 10, 3, 10, 10, 10]

  level   1  2  3  4  5  6  7  8  9 10 11
  bkted   0  0  0  1  1  0  0  0  1  1  1
  d_bin   1  1  1  1  1  1  2  3  3  3  5
*/
