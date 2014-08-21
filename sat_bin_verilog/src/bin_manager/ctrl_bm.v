/**
    控制Bin_Manager的执行
  */

`include "../src/debug_define.v"

module ctrl_bm #(
        parameter WIDTH_BIN_ID  = 10,
        parameter WIDTH_CLAUSES = 8*2,
        parameter WIDTH_LVL     = 16
    )
    (
     input 						clk,
     input 						rst,

     input 						start_bm_i,
     output reg 				done_bm_o,

     //当前状态
     output [WIDTH_BIN_ID-1:0] 	cur_bin_num_o,
     output reg [WIDTH_LVL-1:0] cur_lvl_o,
	 output reg 				global_sat_o,
	 output reg 				global_unsat_o,

     //读取基本信息
     output reg 				start_rdinfo_o,
     input 						done_rdinfo_i,
     input [WIDTH_CLAUSES-1:0] 	nb_all_i,

     //load bin
     output reg 				start_load_o,
     output [WIDTH_BIN_ID-1:0] 	request_bin_num_o,
     input 						done_load_i,

     //sat_engine core
     output reg 				start_core_o,
     input 						done_core_i,
     input 						local_sat_i,
     input [WIDTH_LVL-1:0] 		cur_lvl_from_core_i,
     input [WIDTH_BIN_ID-1:0] 	bkt_bin_from_core_i,

     //find_global_bkt_lvl
     output reg 				start_find_o,
     input 						done_find_i,
     input [WIDTH_LVL-1: 0] 	bkt_lvl_from_find_i,
     input [WIDTH_BIN_ID-1: 0] 	bkt_bin_from_find_i,

     //bkt_across_bin
     output reg 				start_bkt_across_bin_o,
     input 						done_bkt_across_bin_i,

     //update bin
     output reg 				   start_update_o,
     output reg [WIDTH_BIN_ID-1:0] update_bin_num_o,
     input 						   done_update_i
    );

    reg [WIDTH_LVL-1:0]    cur_bin_num_r;

    parameter       IDLE            =   0,
                    RD_BIN_INFO     =   1,
                    LOAD_BIN        =   2,
                    RUN_CORE        =   3,
                    FIND_BKT_LVL    =   4,
                    BKT_ACROSS_BIN  =   5,
                    UPDATE_BIN      =   6,
                    GLOBAL_SAT      =   7,
                    GLOBAL_UNSAT    =   8;

    reg [3:0]                      c_state, n_state;

    always @(posedge clk)
    begin
        if(~rst)
            c_state <= 0;
        else
            c_state <= n_state;
    end

    always @(*) begin: set_next_state
        if(~rst)
            n_state = 0;
        else
            case(c_state)
                IDLE:
                    if(start_bm_i)
                        n_state = RD_BIN_INFO;
                    else
                        n_state = IDLE;
                RD_BIN_INFO:
                    if(done_rdinfo_i)
                        n_state = LOAD_BIN;
                    else
                        n_state = RD_BIN_INFO;
                LOAD_BIN:
                    if(done_load_i)
                        n_state = RUN_CORE;
                    else
                        n_state = LOAD_BIN;
                RUN_CORE:
                    if(done_core_i) begin
						if(local_sat_i)
							n_state = UPDATE_BIN;
						else
							n_state = FIND_BKT_LVL;
					end
                    else
                        n_state = RUN_CORE;
                FIND_BKT_LVL:
                    if(done_find_i && bkt_bin_from_find_i!=0)
                        n_state = BKT_ACROSS_BIN;
                    else if(done_find_i && bkt_bin_from_find_i==0)
                        n_state = GLOBAL_UNSAT;
                    else
                        n_state = FIND_BKT_LVL;
                BKT_ACROSS_BIN:
                    if(done_bkt_across_bin_i)
                        n_state = UPDATE_BIN;
                    else
                        n_state = BKT_ACROSS_BIN;
                UPDATE_BIN:
                    if(done_update_i && cur_bin_num_r==nb_all_i)
                        n_state = GLOBAL_SAT;
                    else if(done_update_i)
                        n_state = LOAD_BIN;
                    else
                        n_state = UPDATE_BIN;
                GLOBAL_SAT:
                    n_state = GLOBAL_SAT;
                GLOBAL_UNSAT:
                    n_state = GLOBAL_UNSAT;

                default:
                    n_state = IDLE;
            endcase
    end

    always @(posedge clk)
    begin
        if(~rst)
            cur_bin_num_r <= 1;
        else if(c_state==UPDATE_BIN && done_update_i && local_sat_i)
            cur_bin_num_r <= cur_bin_num_r+1;
        else if(c_state==BKT_ACROSS_BIN)
            cur_bin_num_r <= bkt_bin_from_find_i;
        else
            cur_bin_num_r <= cur_bin_num_r;
    end

    assign cur_bin_num_o = cur_bin_num_r;

    always @(posedge clk)
    begin
        if(~rst)
            global_sat_o <= 0;
        else if(c_state==GLOBAL_SAT)
            global_sat_o <= 1;
        else
            global_sat_o <= global_sat_o;
    end

    always @(posedge clk)
    begin
        if(~rst)
            global_unsat_o <= 0;
        else if(c_state==GLOBAL_UNSAT)
            global_unsat_o <= 1;
        else
            global_unsat_o <= global_unsat_o;
    end

    always @(posedge clk)
    begin
        if(~rst)
            done_bm_o <= 0;
        else if(c_state==GLOBAL_SAT || c_state==GLOBAL_UNSAT)
            done_bm_o <= 1;
        else
            done_bm_o <= done_bm_o;
    end

    // 保证start信号是一个周期的脉冲信号
    reg [1:0] impulse_cnt;
    always @(posedge clk)
    begin
        if(~rst)
            impulse_cnt <= 0;
        else if(done_rdinfo_i | done_load_i | done_core_i | done_find_i | done_bkt_across_bin_i | done_update_i)
            impulse_cnt <= 0;
        else if(c_state!=IDLE)
        begin
            if (impulse_cnt == 0)
                impulse_cnt <= 1;
            else
                impulse_cnt <= 2;
        end
        else
            impulse_cnt <= 0;
    end

     //read bin info
    always @(posedge clk)
    begin
        if(~rst)
            start_rdinfo_o <= 0;
        else if(c_state==RD_BIN_INFO && impulse_cnt==0)
            start_rdinfo_o <= 1;
        else
            start_rdinfo_o <= 0;
    end


     //load bin
    always @(posedge clk)
    begin
        if(~rst)
            start_load_o <= 0;
        else if(c_state==LOAD_BIN && impulse_cnt==0)
            start_load_o <= 1;
        else
            start_load_o <= 0;
    end

    assign request_bin_num_o = cur_bin_num_r;


    always @(posedge clk)
    begin
        if(~rst)
            update_bin_num_o <= 0;
        else if(c_state==LOAD_BIN)
            update_bin_num_o <= request_bin_num_o;
        else
            update_bin_num_o <= update_bin_num_o;
    end

     //sat_engine core
    always @(posedge clk)
    begin
        if(~rst)
            start_core_o <= 0;
        else if(c_state==RUN_CORE && impulse_cnt==0)
            start_core_o <= 1;
        else
            start_core_o <= 0;
    end

     //find_global_bkt_lvl
    always @(posedge clk)
    begin
        if(~rst)
            start_find_o <= 0;
        else if(c_state==FIND_BKT_LVL && impulse_cnt==0)
            start_find_o <= 1;
        else
            start_find_o <= 0;
    end

     //bkt_across_bin
    always @(posedge clk)
    begin
        if(~rst)
            start_bkt_across_bin_o <= 0;
        else if(c_state==BKT_ACROSS_BIN && impulse_cnt==0)
            start_bkt_across_bin_o <= 1;
        else
            start_bkt_across_bin_o <= 0;
    end

     //update bin
    always @(posedge clk)
    begin
        if(~rst)
            start_update_o <= 0;
        else if(c_state==UPDATE_BIN && impulse_cnt==0)
            start_update_o <= 1;
        else
            start_update_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            cur_lvl_o <= 0;
        else if(done_core_i && local_sat_i) //局部sat时
            cur_lvl_o <= cur_lvl_from_core_i;
        else if(done_find_i) //局部unsat时
            cur_lvl_o <= bkt_lvl_from_find_i;
        else
            cur_lvl_o <= cur_lvl_o;
    end

`ifdef DEBUG_ctrl_bm
    string s[] = '{
        "IDLE",
        "RD_BIN_INFO",
        "LOAD_BIN",
        "RUN_CORE",
        "FIND_BKT_LVL",
        "BKT_ACROSS_BIN",
        "UPDATE_BIN",
        "GLOBAL_SAT",
        "GLOBAL_UNSAT"};

    int cnt[] = '{0, 0, 0, 0, 0, 0, 0, 0, 0};
    string scnt[] = '{
        "idle",
        "rd_bin_info",
        "load_bin",
        "run_core",
        "find_bkt_lvl",
        "bkt_across_bin",
        "update_bin",
        "global_sat",
        "global_unsat"};
        
    always @(posedge clk) begin
        if(~rst)
            cnt = '{0, 0, 0, 0, 0, 0, 0, 0, 0};
        else if(c_state!=n_state && n_state!=IDLE)
        begin
            @(posedge clk)
            if(c_state==LOAD_BIN)
                $display("%1tns ===============================================", $time/1000);
            cnt[c_state]++;
            $display("%1tns ctrl_bm c_state = %s ", $time/1000, s[c_state]);
            $display("\tcnt_%1s = %1d", scnt[c_state], cnt[c_state]);
        end
    end

    always @(rst, cur_bin_num_o, cur_lvl_o) begin
        if(c_state!=IDLE && c_state!=GLOBAL_SAT && c_state!=GLOBAL_UNSAT)
            $display("%1tns cur_bin_num_o=%1d; cur_lvl_o=%1d", $time/1000, cur_bin_num_o, cur_lvl_o);
    end

    always @(local_sat_i) begin
        if(c_state!=IDLE && c_state!=GLOBAL_SAT && c_state!=GLOBAL_UNSAT)
            $display("%1tns local_sat_i=%1d", $time/1000, local_sat_i);
    end

    int i;
    task display_cnt();
        $display("\tbin_manager:");
        for(i=0; i<=GLOBAL_UNSAT; i++)
            $display("\t\tcnt_%1s = %1d", scnt[i], cnt[i]);
    endtask

`endif


`ifdef DEBUG_ctrl_bm_time
    always @(posedge clk) begin
        if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
            display_state();
        end
    end

    string str = "";
    string str_name = "";
    string str_value = "";

    task display_state();
        str = "";
        str_name = "\t";
        str_value = "\t";
        $display("%1tns ctrl_bm", $time/1000);
        //                    01234567890123456789
        $sformat(str,"%16s", "impulse_cnt");                 str_name = {str_name, str};
        $sformat(str,"%16s", "start_load_o");                str_name = {str_name, str};
        $sformat(str,"%16s", "start_core_o");                str_name = {str_name, str};
        $sformat(str,"%16s", "start_find_o");                str_name = {str_name, str};
        $sformat(str,"%16s", "start_bkt");                   str_name = {str_name, str};
        $sformat(str,"%16s", "start_update_o");              str_name = {str_name, str};


        $sformat(str,"%16d", impulse_cnt);       str_value = {str_value, str};
        $sformat(str,"%16d", start_load_o);      str_value = {str_value, str};
        $sformat(str,"%16d", start_core_o);      str_value = {str_value, str};
        $sformat(str,"%16d", start_find_o);      str_value = {str_value, str};
        $sformat(str,"%16d", start_bkt_across_bin_o);      str_value = {str_value, str};
        $sformat(str,"%16d", start_update_o);              str_value = {str_value, str};

        $display(str_name);
        $display(str_value);
    endtask

`endif

endmodule
