
/*** 测试数据6 ***/

task se_test_case6();

    $display("===============================================");
    $display("test_case 6");

	bin = '{
		'{0, 0, 1, 1, 0, 0, 2, 0},
		'{2, 0, 0, 0, 2, 2, 0, 0},
		'{0, 2, 2, 0, 1, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0}
	};
	//var state list:
	value   = '{1, 1, 1, 0, 1, 1, 0, 0};
	implied = '{0, 0, 0, 0, 0, 1, 0, 0};
	level   = '{2, 8, 6, 0, 10, 10, 0, 0};
	//lvl state list:
	dcd_bin = '{0, 0, 0, 0, 0, 0, 0, 0};
	has_bkt = '{0, 0, 0, 0, 0, 0, 0, 0};
	//ctrl
	cur_bin_num = 9;
	load_lvl = 13;
	base_lvl = 13;

    //运算过程数据
    process_len = 2;
    process_data = '{
        '{"conflict", 0, 0, 0},
        '{"punsat",   0, 0, 0}
    };

    run_test_case();
endtask

/*
load_bin 9
	cnt_load 9
	c1  -3 -4 7 
	c2  1 5 6 
	c3  2 3 -5 
	global vars [5, 9, 15, 16, 17, 19, 20]
	local vars  [1, 2, 3, 4, 5, 6, 7]
	var_state_list:
	value       [1, 1, 1, 0, 1, 1, 0]
	implied     [0, 0, 0, 0, 0, 1, 0]
	level       [2, 8, 6, 0, 10, 10, 0]
	lvl state list:
	dcd_bin     [0, 0, 0, 0, 0, 0, 0]
	has_bkt     [0, 0, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 9
	load_lvl    : 13
	base_lvl    : 13

sat engine run_core: cur_bin == 9
--	bcp
		cnt_bcp: 21
		find conflict in c_array.init_state()
--	analysis the conflict
		conflict c2
		cnt_analysis: 1
		lits    [1, 5, 6]
		value   [1, 1, 1]
		implied [0, 0, 1]
		level   [2, 10, 10]
		bin     [1, 3, 3]
		bkted   [0, 0, 0]
		reason  [0, 0, 0]

--	no learntc
		bkt_bin 0 bkt_lvl 10
----		partial unsat
--	find_global_bkt_lvl
		bkt_bin 3 bkt_lvl 10
--	backtrack_across_bin: bkt_lvl == 10
		gvar 17 value 2 level 10
update_bin 9
	cnt_update 9
	c1  -3 -4 7 
	c2  1 5 6 
	c3  2 3 -5 
	global vars [5, 9, 15, 16, 17, 19, 20]
	local vars  [1, 2, 3, 4, 5, 6, 7]
	var_state_list:
	value       [1, 1, 1, 0, 2, 0, 0]
	implied     [0, 0, 0, 0, 0, 0, 0]
	level       [2, 8, 6, 0, 10, 0, 0]
	lvl state list:
	dcd_bin     [0, 0, 0, 0, 0, 0, 0]
	has_bkt     [0, 0, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 10
	load_lvl    : 11
	base_lvl    : 13

	int bin[8][8] = '{
		'{0, 0, 1, 1, 0, 0, 2, 0},
		'{2, 0, 0, 0, 2, 2, 0, 0},
		'{0, 2, 2, 0, 1, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0}
	};
	//var state list:
	int value[]   = '{1, 1, 1, 0, 2, 0, 0};
	int implied[] = '{0, 0, 0, 0, 0, 0, 0};
	int level[]   = '{2, 8, 6, 0, 10, 0, 0};
	//lvl state list:
	int dcd_bin[] = '{0, 0, 0, 0, 0, 0, 0};
	int has_bkt[] = '{0, 0, 0, 0, 0, 0, 0};
	//ctrl
	int cur_bin_num = 10;
	int load_lvl = 11;
	int base_lvl = 13;
*/
