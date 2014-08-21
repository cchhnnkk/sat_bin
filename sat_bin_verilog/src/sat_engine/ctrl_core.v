/**
    控制Sat Engine的执行，在load bin以后，开始执行
    返回bin的sat或unsat
  */

`include "../src/debug_define.v"
module ctrl_core #(
        parameter WIDTH_BIN_ID = 10,
        parameter WIDTH_LVL    = 16
    )
    (
     input                    clk,
     input                    rst,

     input                    start_core_i,
     output reg               done_core_o,

     //推理
     output reg               apply_imply_o,
     input                    done_imply_i,
     input                    conflict_i,

     //决策
     output reg               start_decision_o,
     input                    done_decision_i,
     input [WIDTH_LVL-1:0]    cur_lvl_i,
     input                    all_c_is_sat_i,

     //冲突分析
     output reg               apply_analyze_o,
     input                    done_analyze_i,
     input [WIDTH_BIN_ID-1:0] bkt_bin_num_i,

     //回退
     output reg               apply_bkt_cur_bin_o,
     input                    done_bkt_cur_bin_i,

     //其他信号
     input [WIDTH_BIN_ID-1:0] cur_bin_num_i,
     output reg               sat_o,
     output reg			      unsat_o
    );

    parameter       IDLE          =   0,
                    BCP           =   1,
                    DECISION      =   2,
                    ANALYSIS      =   3,
                    BKT_CUR_BIN   =   4,
                    PARTIAL_SAT   =   5,
                    PARTIAL_UNSAT =   6;

    reg [3:0] 			   c_state, n_state;
    reg [31:0] 			   wait_cnt, w_cnt, r_cnt;
    reg [31:0] 			   w_clk_cnt, r_clk_cnt;

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
                    if(start_core_i)
                        n_state = BCP;
                    else
                        n_state = IDLE;
                BCP:
                    if(done_imply_i && conflict_i)
                        n_state = ANALYSIS;
                    else if(done_imply_i && ~conflict_i && all_c_is_sat_i)
                        n_state = PARTIAL_SAT;
                    else if(done_imply_i && ~conflict_i)
                        n_state = DECISION;
                    else
                        n_state = BCP;
                DECISION:
                    if(done_decision_i && all_c_is_sat_i)
                        n_state = PARTIAL_SAT;
                    else if(done_decision_i)
                        n_state = BCP;
                    else
                        n_state = DECISION;
                ANALYSIS:
                    if(done_analyze_i && bkt_bin_num_i!=cur_bin_num_i)
                        n_state = PARTIAL_UNSAT;
                    else if(done_analyze_i && bkt_bin_num_i==cur_bin_num_i)
                        n_state = BKT_CUR_BIN;
                    else
                        n_state = ANALYSIS;
                BKT_CUR_BIN:
                    if(done_bkt_cur_bin_i)
                        n_state = BCP;
                    else
                        n_state = BKT_CUR_BIN;
                PARTIAL_SAT:
                    n_state = IDLE;
                PARTIAL_UNSAT:
                    n_state = IDLE;

                default:
                    n_state = IDLE;
            endcase
    end

    always @(posedge clk)
    begin
        if(~rst)
            sat_o <= 0;
        else if(c_state==PARTIAL_SAT)
            sat_o <= 1;
        else if(c_state==PARTIAL_UNSAT)
            sat_o <= 0;
        else
            sat_o <= sat_o;
    end

    always @(posedge clk)
    begin
        if(~rst)
            unsat_o <= 0;
        else if(c_state==PARTIAL_SAT)
            unsat_o <= 0;
        else if(c_state==PARTIAL_UNSAT)
            unsat_o <= 1;
        else
            unsat_o <= unsat_o;
    end

    always @(posedge clk)
    begin
        if(~rst)
            done_core_o <= 0;
        else if(c_state==PARTIAL_SAT || c_state==PARTIAL_UNSAT)
            done_core_o <= 1;
        else if(start_core_i)
            done_core_o <= 0;
        else
            done_core_o <= 0;
    end

    // 保证start_decision_o信号是一个周期的脉冲信号
    reg [1:0] impulse_cnt;
    always @(posedge clk)
    begin
        if(~rst)
            impulse_cnt <= 0;
        else if(c_state==DECISION)
        begin
            if (impulse_cnt == 0)
                impulse_cnt <= 1;
            else
                impulse_cnt <= 2;

        end
        else
            impulse_cnt <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            start_decision_o <= 0;
        else if(c_state==DECISION && impulse_cnt==0)
            start_decision_o <= 1;
        else
            start_decision_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            apply_imply_o <= 0;
        else if(c_state==BCP)
            apply_imply_o <= 1;
        else
            apply_imply_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            start_decision_o <= 0;
        else if(c_state==DECISION && impulse_cnt==0)
            start_decision_o <= 1;
        else
            start_decision_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            apply_analyze_o <= 0;
        else if(c_state==ANALYSIS)
            apply_analyze_o <= 1;
        else
            apply_analyze_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            apply_bkt_cur_bin_o <= 0;
        else if(c_state==BKT_CUR_BIN && done_bkt_cur_bin_i==0)
            apply_bkt_cur_bin_o <= 1;
        else
            apply_bkt_cur_bin_o <= 0;
    end

`ifdef DEBUG_ctrl_core

    string s[] = '{
        "IDLE",
        "BCP",
        "DECISION",
        "ANALYSIS",
        "BKT_CUR_BIN",
        "PARTIAL_SAT",
        "PARTIAL_UNSAT"};
        
    int cnt[] = '{0, 0, 0, 0, 0, 0};
    string scnt[] = '{
        "idle",
        "bcp",
        "decision",
        "analysis",
        "bkt_cur_bin",
        "partial_sat",
        "partial_unsat"};

    reg delay_disp;

    always @(posedge clk) begin
        if(~rst)
            delay_disp <= 0;
        else if(c_state!=n_state && n_state!=IDLE)
            delay_disp <= 1;
        else
            delay_disp <= 0;
    end

    always @(posedge clk) begin
        if(delay_disp)
        begin
            @(posedge clk)
            //$display("sim time %4tns", $time/1000);
            cnt[c_state]++;
            $display("%1tns ctrl_core c_state = %s ", $time/1000, s[c_state]);
            $display("\tcnt_%1s = %1d", scnt[c_state], cnt[c_state]);
        end
    end

    /*
    always @(*) begin
        $display("%1tns sat_o=%1d, unsat_o=%1d", $time/1000, sat_o, unsat_o);
    end
    */

    int i;
    task display_cnt();
        $display("\tsat_engine:");
        for(i=0; i<=PARTIAL_UNSAT; i++)
            $display("\t\tcnt_%1s = %1d", scnt[i], cnt[i]);
    endtask

`endif

endmodule
