
/*** 测试数据8 ***/

task se_test_case8();

    $display("===============================================");
    $display("test_case 8");

	bin = '{
		'{0, 0, 1, 0, 2, 2, 0, 0},
		'{0, 2, 0, 2, 0, 0, 2, 0},
		'{1, 0, 0, 1, 0, 1, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0}
	};
	//var state list:
	value   = '{2, 1, 2, 2, 1, 0, 0, 0};
	implied = '{0, 0, 1, 1, 1, 0, 0, 0};
	level   = '{5, 3, 3, 5, 5, 0, 0, 0};
	//lvl state list:
	dcd_bin = '{11, 14, 14, 0, 0, 0, 0, 0};
	has_bkt = '{1, 1, 0, 0, 0, 0, 0, 0};
	//ctrl
	cur_bin_num = 11;
	base_lvl = 10;
	load_lvl = 10;

    //运算过程数据
    process_len = 3;
    process_data = '{
        '{"bcp",        0, 3, 5},
        '{"conflict",   1, 1, 1},
        '{"punsat",     0, 0, 0}
    };

    run_test_case();
endtask

/*
load_bin 11
	cnt_load 344
	c1  -3 5 6 
	c2  2 4 7 
	c3  -1 -4 -6 
	global vars [6, 8, 10, 12, 13, 17, 18]
	local vars  [1, 2, 3, 4, 5, 6, 7]
	var_state_list:
	value       [2, 1, 2, 2, 1, 0, 0]
	implied     [0, 0, 1, 1, 1, 0, 0]
	level       [5, 3, 3, 5, 5, 0, 0]
	lvl state list:
	dcd_bin     [11, 14, 14, 0, 0, 0, 0]
	has_bkt     [1, 1, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 11
	base_lvl    : 10
	cur_lvl     : 10

sat engine run_core: cur_bin == 11
--	bcp
		cnt_bcp: 398
		c1 var 6 gvar 17 value 2 level 5
		lits    [-3, 5, 6]
		value   [2, 1, 2]
		implied [1, 1, 1]
		level   [3, 5, 5]
		bin     [1, 2, 2]
		bkted   [0, 1, 1]
		reason  [0, 0, 1]

--	analysis the conflict
		conflict c3
		cnt_analysis: 27
		lits    [-1, -4, -6]
		value   [2, 2, 2]
		implied [0, 1, 1]
		level   [5, 5, 5]
		bin     [2, 2, 2]
		bkted   [1, 1, 1]
		reason  [0, 0, 1]

--	the learntc c4 [-1, -3, -4, 5]
		bkt_bin 0 bkt_lvl 5
----		partial unsat
--	find_global_bkt_lvl
		bkt_bin 1 bkt_lvl 3
--	backtrack_across_bin: bkt_lvl == 3
		gvar 8 value 2 level 3
update_bin 11
	cnt_update 344
	c1  -3 5 6 
	c2  2 4 7 
	c3  -1 -4 -6 
	c4  -1 -3 -4 5 
	global vars [6, 8, 10, 12, 13, 17, 18]
	local vars  [1, 2, 3, 4, 5, 6, 7]
	var_state_list:
	value       [0, 2, 0, 0, 0, 0, 0]
	implied     [0, 0, 0, 0, 0, 0, 0]
	level       [0, 3, 0, 0, 0, 0, 0]
	lvl state list:
	dcd_bin     [11, 14, 14, 0, 0, 0, 0]
	has_bkt     [1, 1, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 12
	base_lvl    : 10
	cur_lvl     : 6

*/

