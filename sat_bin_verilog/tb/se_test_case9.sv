
/***
    测试数据9
    只有一次conflict，但不生成了learntc
***/

task se_test_case9();

    $display("===============================================");
    $display("test_case 9");

	bin = '{
		'{2, 1, 0, 1, 0, 0, 0, 0},
		'{0, 0, 0, 1, 1, 1, 0, 0},
		'{0, 0, 1, 2, 2, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0},
		'{0, 0, 0, 0, 0, 0, 0, 0}
	};
	//var state list:
	value   = '{1, 0, 0, 2, 2, 2, 0, 0};
	implied = '{0, 0, 0, 1, 1, 1, 0, 0};
	level   = '{9, 0, 0, 10, 4, 7, 0, 0};
	//lvl state list:
	dcd_bin = '{0, 0, 0, 0, 0, 0, 0, 0};
	has_bkt = '{0, 0, 0, 0, 0, 0, 0, 0};
	//ctrl
	cur_bin_num = 14;
	base_lvl = 11;
	load_lvl = 10;

    //运算过程数据
    process_len = 3;
    process_data = '{
        '{"bcp",      1, 1, 10},
        '{"conflict", 1, 1, 1},
        '{"punsat",   0, 0, 0}
    };

    run_test_case();
endtask

/*
load_bin 14
	cnt_load 14
	c1  1 -2 -4 
	c2  -4 -5 -6 
	c3  -3 4 5 
	global vars [1, 2, 13, 14, 17, 18]
	local vars  [1, 2, 3, 4, 5, 6]
	var_state_list:
	value       [1, 0, 0, 2, 2, 2]
	implied     [0, 0, 0, 1, 1, 1]
	level       [9, 0, 0, 10, 4, 7]
	lvl state list:
	dcd_bin     [0, 0, 0, 0, 0, 0]
	has_bkt     [0, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 14
	base_lvl    : 11
	cur_lvl     : 11


sat engine run_core: cur_bin == 14
--	bcp
		cnt_bcp: 24
		find conflict in c_array.init_state()
--	analysis the conflict
		conflict c2
		cnt_analysis: 1
		lits    [-4, -5, -6]
		value   [2, 2, 2]
		implied [1, 1, 1]
		level   [10, 4, 7]
		bin     [10, 2, 4]
		bkted   [0, 0, 0]
		reason  [0, 0, 0]

--	no learntc
		bkt_bin 0 bkt_lvl 10
----		partial unsat
--	find_global_bkt_lvl
		bkt_bin 10 bkt_lvl 10
--	backtrack_across_bin: bkt_lvl == 10
		gvar 9 value 2 level 10
update_bin 14
	cnt_update 14
	c1  1 -2 -4 
	c2  -4 -5 -6 
	c3  -3 4 5 
	global vars [1, 2, 13, 14, 17, 18]
	local vars  [1, 2, 3, 4, 5, 6]
	var_state_list:
	value       [1, 0, 0, 0, 2, 2]
	implied     [0, 0, 0, 0, 1, 1]
	level       [9, 0, 0, 0, 4, 7]
	lvl state list:
	dcd_bin     [0, 0, 0, 0, 0, 0]
	has_bkt     [0, 0, 0, 0, 0, 0]
	ctrl:
	cur_bin_num : 15
	base_lvl    : 11
	cur_lvl     : 11
*/
