/**
    维护Sat Engine中变量及层级的状态，包括:
      var_state[]
      lvl_state[]

    协助find_bkt_lvl, 计算bkt_lvl计算:
      根据lvl_state[]得到的bkt_lvl和bkt_bin，
      得出需要返回的层级;
  */

`include "../src/debug_define.v"

module state_list #(
        parameter NUM_VARS         = 8,
        parameter NUM_LVLS         = 8,
        parameter WIDTH_VAR_STATES = 19,
        parameter WIDTH_LVL_STATES = 11,
        parameter WIDTH_C_LEN      = 4,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_BIN_ID     = 10
    )
    (
        input                                     clk,
        input                                     rst,

        // var value I/O
        input [NUM_VARS*3-1:0]                    var_value_i,
        output [NUM_VARS*3-1:0]                   var_value_o,
        input [NUM_VARS*WIDTH_LVL-1:0]            var_lvl_i,
        output [NUM_VARS*WIDTH_LVL-1:0]           var_lvl_o,
        output [NUM_VARS*2-1:0]                   learnt_lit_o,

        //decide
        input                                     load_lvl_en,
        input [WIDTH_LVL-1:0]                     load_lvl_i,
        input                                     start_decision_i,
        input [WIDTH_BIN_ID-1:0]                  cur_bin_num_i,
        output [WIDTH_LVL-1:0]                    cur_lvl_o,
        output                                    done_decision_o,

        //imply
        input                                     apply_imply_i,
        output reg                                done_imply_o,
        output                                    find_conflict_o,

        //conflict
        input                                     apply_analyze_i,
        output reg                                add_learntc_en_o,
        output reg                                done_analyze_o,
        //find bkt lvl
        output reg [WIDTH_BIN_ID-1:0]             bkt_bin_o,
        output reg [WIDTH_LVL-1:0]                bkt_lvl_o,

        //backtrack cur bin
        input                                     apply_bkt_cur_bin_i,
        output                                    done_bkt_cur_bin_o,

        //load update var states
        input [NUM_VARS-1:0]                      wr_var_states,
        input [WIDTH_VAR_STATES*NUM_VARS-1 : 0]   var_states_i,
        output [WIDTH_VAR_STATES*NUM_VARS-1 : 0]  var_states_o,

        //load update lvl states
        input [NUM_LVLS-1:0]                      wr_lvl_states,
        input [WIDTH_LVL_STATES*NUM_LVLS -1 : 0]  lvl_states_i,
        output [WIDTH_LVL_STATES*NUM_LVLS -1 : 0] lvl_states_o,
        input                                     base_lvl_en,
        input [WIDTH_LVL-1:0]                     base_lvl_i
    );

    /**
    * 变量状态
    */
    reg  [WIDTH_LVL-1:0]      base_lvl_r;
    wire [WIDTH_LVL-1:0]      max_lvl;
    wire [WIDTH_LVL-1:0]      local_bkt_lvl;
    wire [NUM_VARS-1:0]       find_imply_cur, find_conflict_cur;
    reg [NUM_VARS-1:0]        find_imply_pre, find_conflict_pre;
    wire [NUM_VARS-1:0]       valid_from_decision;
    wire [WIDTH_BIN_ID-1:0]   bkt_bin_w;
    wire [WIDTH_LVL-1:0]      bkt_lvl_w;

    var_state8 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state8(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i),
        .var_value_o          (var_value_o),
        .var_lvl_i            (var_lvl_i),
        .var_lvl_o            (var_lvl_o),
        .learnt_lit_o         (learnt_lit_o),
        .valid_from_decision_i(valid_from_decision),
        .cur_lvl_i            (cur_lvl_o),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_cur),
        .find_conflict_o      (find_conflict_cur),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl),
        .apply_bkt_i          (apply_bkt_cur_bin_i),
        .bkt_lvl_i            (bkt_lvl_w),
        .wr_states            (wr_var_states),
        .var_states_i         (var_states_i),
        .var_states_o         (var_states_o),

        .debug_vid_next_i     (0),
        .debug_vid_next_o     ()
    );

    assign find_conflict_o = |find_conflict_cur;
    /**
    * 层级状态
    */

    wire [WIDTH_LVL-1:0] bkt_lvl_from_ls;
    wire [1:0] findflag_left_i;
    assign findflag_left_i = 0;

    lvl_state8 #(
        .WIDTH_LVL_STATES(WIDTH_LVL_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_BIN_ID    (WIDTH_BIN_ID)
    )
    lvl_state8(
        .clk                  (clk),
        .rst                  (rst),
        .valid_from_decision_i(valid_from_decision!=0),
        .cur_bin_num_i        (cur_bin_num_i),
        .cur_lvl_i            (cur_lvl_o),
        .lvl_next_i           (base_lvl_r + 1),
        .lvl_next_o           (),
        .findflag_left_i      (findflag_left_i),
        .findflag_left_o      (),
        .max_lvl_i            (max_lvl),
        .bkt_bin_o            (bkt_bin_w),
        .bkt_lvl_o            (bkt_lvl_from_ls),
        .apply_bkt_i          (apply_bkt_cur_bin_i),
        .wr_states            (wr_lvl_states),
        .lvl_states_i         (lvl_states_i),
        .lvl_states_o         (lvl_states_o)
    );

    assign bkt_lvl_w = max_lvl<=base_lvl_r ? max_lvl:bkt_lvl_from_ls;

    /*** 决策 ***/
    wire [WIDTH_LVL-1:0]  cur_local_lvl;

    decision #(
        .WIDTH_LVL(WIDTH_LVL),
        .NUM_VARS (NUM_VARS)
    )
    decision(
        .clk            (clk),
        .rst            (rst),
        .load_lvl_en    (load_lvl_en),
        .load_lvl_i     (load_lvl_i),
        .decision_pulse (start_decision_i),
        .vars_value_i   (var_value_o),
        .index_decided_o(valid_from_decision),
        .decision_done  (done_decision_o),
        .apply_bkt_i    (apply_bkt_cur_bin_i),
        .bkt_lvl_i      (bkt_lvl_o),
        .cur_lvl_o      (cur_lvl_o)
    );

    //assign cur_lvl_o = base_lvl_r + cur_local_lvl;

    `ifdef DEBUG_state_list
        `include "../tb/class_vs_list.sv";
        class_vs_list #(8, WIDTH_LVL) vs_list = new();

        always @(posedge clk) begin
            /*
            if(start_decision_i) begin
                $display("%1tns start_decision", $time/1000);
                vs_list.set(var_states_o);
                vs_list.display();
            end
            */
            if(done_decision_o) begin
                $display("%1tns done_decision", $time/1000);
                $display("\tindex_decided_o = %b", valid_from_decision);
                $display("\tbase_lvl_r      = %4d", base_lvl_r);
                $display("\tcur_lvl_o       = %4d", cur_lvl_o);
                @(posedge clk)
                $display("\t%1tns var states", $time/1000);
                vs_list.set(var_states_o);
                vs_list.display();
            end
        end
    `endif


    /*** 推理的控制 ***/

    always @(posedge clk)
    begin
        if(~rst)
            find_imply_pre <= 0;
        else
            find_imply_pre <= find_imply_cur;
    end

    always @(posedge clk) begin
        if(~rst)
            done_imply_o <= 0;
        else if(apply_imply_i && (find_imply_cur==find_imply_pre || find_conflict_o))
            done_imply_o <= 1;
        else
            done_imply_o <= 0;
    end

    `ifdef DEBUG_state_list
        always @(posedge clk) begin
            if(apply_imply_i && find_imply_cur!=find_imply_pre) begin
                //$display("sim time %4tns", $time/1000);
                $display("%1tns bcp", $time/1000);
                $display("\tfind_imply_cur=%08b", find_imply_cur);
                vs_list.set(var_states_o);
                vs_list.display_index(find_imply_cur^find_imply_pre);
                $display("\t%1tns var states", $time/1000);
                vs_list.set(var_states_o);
                vs_list.display();

            end
        end

        //用于testbench中的assert
        wire                                 debug_imply_valid;
        wire [NUM_VARS-1:0]                  debug_imply_index;
        wire [WIDTH_VAR_STATES*NUM_VARS-1:0] debug_var_state_o;
        assign debug_imply_valid = apply_imply_i && (find_imply_cur!=find_imply_pre);
        assign debug_imply_index = find_imply_cur^find_imply_pre;
        assign debug_var_state_o = var_states_o;

    `endif


    /*** 冲突分析的控制，冲突学习子句的查找与添加 ***/

    parameter   ANALYZE_IDLE          =  0,
                FIND_LEARNTC          =  1,
                ADD_LEARNTC           =  2,
                ANALYZE_DONE          =  3,
                ANALYZE_WAIT          =  4;

    reg [2:0] c_analyze_state, n_analyze_state;

    always @(posedge clk)
    begin
        if(~rst)
            c_analyze_state <= 0;
        else
            c_analyze_state <= n_analyze_state;
    end

    always @(*) begin
        if(~rst)
            n_analyze_state = 0;
        else
            case(c_analyze_state)
                ANALYZE_IDLE:
                    if(apply_analyze_i)
                        n_analyze_state = FIND_LEARNTC;
                    else
                        n_analyze_state = ANALYZE_IDLE;
                FIND_LEARNTC:
                    if(find_conflict_cur==find_conflict_pre)
                        n_analyze_state = ADD_LEARNTC;
                    else
                        n_analyze_state = FIND_LEARNTC;
                ADD_LEARNTC:
                    n_analyze_state = ANALYZE_DONE;
                ANALYZE_DONE:
                    n_analyze_state = ANALYZE_WAIT;
                ANALYZE_WAIT:
                    if(~apply_analyze_i)    //等待ctrl_core处理完
                        n_analyze_state = ANALYZE_IDLE;
                    else
                        n_analyze_state = ANALYZE_WAIT;
                default:
                    n_analyze_state = ANALYZE_IDLE;
            endcase
    end

    always @(posedge clk)
    begin
        if(~rst)
            find_conflict_pre <= 0;
        else
            find_conflict_pre <= find_conflict_cur;
    end

    always @(posedge clk) begin
        if(~rst)
            add_learntc_en_o <= 0;
        else if(c_analyze_state==ADD_LEARNTC)
            add_learntc_en_o <= 1;
        else
            add_learntc_en_o <= 0;
    end

    always @(posedge clk) begin
        if(~rst)
            done_analyze_o <= 0;
        else if(c_analyze_state==ANALYZE_DONE)
            done_analyze_o <= 1;
        else
            done_analyze_o <= 0;
    end

    //为判断真时bin间回退
    always@(posedge clk) begin
        if(~rst) begin
            bkt_bin_o <= 0;
            bkt_lvl_o <= 0;
        end
        else if(c_analyze_state==ANALYZE_DONE) begin
            bkt_bin_o <= bkt_bin_w;
            bkt_lvl_o <= bkt_lvl_w;
        end
        else begin
            bkt_bin_o <= bkt_bin_o;
            bkt_lvl_o <= bkt_lvl_o;
        end
    end

    wire [2:0] data_from_encode;


    /*** 计算bkt_lvl ***/

    always @(posedge clk)
    begin
        if(~rst)
            base_lvl_r <= 0;
        else if(base_lvl_en)
            base_lvl_r <= base_lvl_i;
        else
            base_lvl_r <= base_lvl_r;
    end

    `ifdef DEBUG_state_list
        string s[] = '{
            "ANALYZE_IDLE",
            "FIND_LEARNTC",
            "ADD_LEARNTC",
            "ANALYZE_DONE",
            "ANALYZE_WAIT"};

        always @(posedge clk) begin
            if(c_analyze_state!=n_analyze_state && n_analyze_state!=ANALYZE_IDLE)
            begin
                @(posedge clk)
                //$display("sim time %4tns", $time/1000);
                $display("%1tns analysis_control c_analyze_state = %s", $time/1000, s[c_analyze_state]);
            end
        end

        `include "../tb/class_clause_data.sv";
        class_clause_data #(8) cdata_learntc = new;

        always @(posedge clk)
        begin
            if(c_analyze_state==FIND_LEARNTC)
            begin
                $display("\tfind_conflict_cur = %b", find_conflict_cur);
                cdata_learntc.reset();
                cdata_learntc.set(var_value_o);
                cdata_learntc.display_lits();
            end
            else if(c_analyze_state==ADD_LEARNTC)
            begin
                $display("\tlearntc = %b", find_conflict_cur);
                cdata_learntc.reset();
                cdata_learntc.set_clause(learnt_lit_o);
                cdata_learntc.display_lits();
            end
            else if(done_analyze_o)
            begin
                //$display("sim time %4tns", $time/1000);
                $display("%1tns done_analysis", $time/1000);
                $display("\tbkt_bin %d bkt_lvl %d", bkt_bin_o, bkt_lvl_o);
            end
        end

        wire debug_conflict_valid;
        assign debug_conflict_valid = c_analyze_state!=n_analyze_state && c_analyze_state==ANALYZE_IDLE;

    `endif

    /*** 回退的控制 ***/

    //一个周期完成
    reg done_bkt_cur_bin_w;
    assign done_bkt_cur_bin_o = done_bkt_cur_bin_w;

    always @(*) begin
        if(~rst)
            done_bkt_cur_bin_w <= 0;
        else if(apply_bkt_cur_bin_i)
            done_bkt_cur_bin_w <= 1;
        else
            done_bkt_cur_bin_w <= 0;
    end

    `ifdef DEBUG_state_list
        `include "../tb/class_ls_list.sv";
        class_ls_list #(8, WIDTH_BIN_ID) ls_list = new();

        always @(posedge clk) begin
            if(apply_bkt_cur_bin_i) begin
                ls_list.set(lvl_states_o);
                //$display("sim time %4tns", $time/1000);
                $display("%1tns apply_bkt_cur_bin_i", $time/1000);
                ls_list.display();
            end
            if(done_bkt_cur_bin_o) begin
                @(posedge clk)
                ls_list.set(lvl_states_o);
                //$display("sim time %4tns", $time/1000);
                $display("%1tns done_bkt_cur_bin_o", $time/1000);
                ls_list.display();
            end
        end
    `endif


    `ifdef DEBUG_state_list_time
        always @(posedge clk) begin
            if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
                display_state();
            end
        end

        string str = "";
        string str_all = "";

        task display_state();
            str = "";
            str_all = "";
            $display("%1tns info state_list", $time/1000);
            //               01234567890123456789
            $sformat(str,"\t         max_lvl");     str_all = {str_all, str};
            $sformat(str, "        bkt_bin_o");     str_all = {str_all, str};
            $sformat(str, "        bkt_lvl_o");     str_all = {str_all, str};
            $sformat(str, "    cur_bin_num_i");     str_all = {str_all, str};
            $sformat(str, "        cur_lvl_o\n");   str_all = {str_all, str};

            $sformat(str,"\t%16d", max_lvl          );     str_all = {str_all, str};
            $sformat(str, " %16d", bkt_bin_o        );     str_all = {str_all, str};
            $sformat(str, " %16d", bkt_lvl_o        );     str_all = {str_all, str};
            $sformat(str, " %16d", cur_bin_num_i    );     str_all = {str_all, str};
            $sformat(str, " %16d", cur_lvl_o        );     str_all = {str_all, str};
            $sformat(str, str_all);

            $display(str_all);
        endtask

    `endif


endmodule
