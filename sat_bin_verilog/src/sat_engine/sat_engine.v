/**
*   求解bin的可满足性
*/

`include "../src/debug_define.v"

module sat_engine #(
        parameter NUM_CLAUSES      = 8,
        parameter NUM_VARS         = 8,
        parameter NUM_LVLS         = 8,
        parameter WIDTH_BIN_ID     = 10,
        parameter WIDTH_C_LEN      = 4,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_LVL_STATES = 11,
        parameter WIDTH_VAR_STATES = 19
    )
    (
        input                                     clk,
        input                                     rst,

        // ctrl_core
        input                                     start_core_i,
        output                                    done_core_o,

        input [WIDTH_BIN_ID-1:0]                  cur_bin_num_i,
        output                                    sat_o,
        output [WIDTH_LVL-1:0]                    cur_lvl_o,
        output                                    unsat_o,
        output [WIDTH_LVL-1:0]                    bkt_lvl_o,
        output [WIDTH_BIN_ID-1:0]                 bkt_bin_o,

        input [WIDTH_LVL-1:0]                     load_lvl_i,

        //load update clause
        input [NUM_CLAUSES-1:0]                   rd_carray_i,
        output [NUM_VARS*2-1 : 0]                 clause_o,
        input [NUM_CLAUSES-1:0]                   wr_carray_i,
        input [NUM_VARS*2-1 : 0]                  clause_i,

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

    wire                 apply_imply;
    wire                 done_imply;
    wire                 find_conflict;
    wire                 start_decision;
    wire                 done_decision;
    wire                 all_c_is_sat;
    wire                 apply_analyze;
    wire                 done_analyze;
    wire                 apply_bkt_cur_bin;
    wire                 done_bkt_cur_bin;

    ctrl_core #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    ctrl_core(
        .clk                (clk),
        .rst                (rst),
        .start_core_i       (start_core_i),
        .done_core_o        (done_core_o),
        //推理
        .apply_imply_o      (apply_imply),
        .done_imply_i       (done_imply),
        .conflict_i         (find_conflict),
        //决策
        .start_decision_o   (start_decision),
        .done_decision_i    (done_decision),
        .cur_lvl_i          (cur_lvl_o),
        .all_c_is_sat_i     (all_c_is_sat),
        //冲突分析
        .apply_analyze_o    (apply_analyze),
        .done_analyze_i     (done_analyze),
        .bkt_bin_num_i      (bkt_bin_o),
        //回退
        .apply_bkt_cur_bin_o(apply_bkt_cur_bin),
        .done_bkt_cur_bin_i (done_bkt_cur_bin),

        .cur_bin_num_i      (cur_bin_num_i),
        .sat_o              (sat_o),
        .unsat_o            (unsat_o)
    );

    wire [NUM_VARS*3-1:0]         var_value_from_stlist;
    wire [NUM_VARS*3-1:0]         var_value_from_carray;
    wire [NUM_VARS*WIDTH_LVL-1:0] var_lvl_from_stlist;
    wire [NUM_VARS*WIDTH_LVL-1:0] var_lvl_from_carray;
    wire                          add_learntc_en;
    wire [NUM_VARS*2-1:0]         learnt_lit;
    wire [WIDTH_C_LEN-1 : 0]      clause_len;

    state_list #(
        .NUM_VARS        (NUM_VARS),
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL_STATES(WIDTH_LVL_STATES),
        .WIDTH_C_LEN     (WIDTH_C_LEN),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_BIN_ID    (WIDTH_BIN_ID)
    )
    state_list(
        .clk                (clk),
        .rst                (rst),
        // var value I/O
        .var_value_i        (var_value_from_carray),
        .var_value_o        (var_value_from_stlist),
        .var_lvl_i          (var_lvl_from_carray),
        .var_lvl_o          (var_lvl_from_stlist),
        .learnt_lit_o       (learnt_lit),
        //decide
        .load_lvl_en        (start_core_i),
        .load_lvl_i         (load_lvl_i),
        .start_decision_i   (start_decision),
        .cur_bin_num_i      (cur_bin_num_i),
        .cur_lvl_o          (cur_lvl_o),
        .done_decision_o    (done_decision),
        //imply
        .apply_imply_i      (apply_imply),
        .done_imply_o       (done_imply),
        .find_conflict_o    (find_conflict),
        //conflict
        .apply_analyze_i    (apply_analyze),
        .add_learntc_en_o   (add_learntc_en),
        .done_analyze_o     (done_analyze),
        .bkt_bin_o          (bkt_bin_o),
        .bkt_lvl_o          (bkt_lvl_o),
        //backtrack cur bin
        .apply_bkt_cur_bin_i(apply_bkt_cur_bin),
        .done_bkt_cur_bin_o (done_bkt_cur_bin),
        //load update var states
        .wr_var_states      (wr_var_states),
        .var_states_i      (var_states_i),
        .var_states_o      (var_states_o),
        .wr_lvl_states      (wr_lvl_states),
        .lvl_states_i       (lvl_states_i),
        .lvl_states_o       (lvl_states_o),
        .base_lvl_en        (base_lvl_en),
        .base_lvl_i         (base_lvl_i)
    );

    wire [NUM_VARS*2-1:0]  clause_to_carray;
    assign clause_to_carray = wr_carray_i!=0? clause_i : learnt_lit;

    clause_array #(
        .NUM_CLAUSES     (NUM_CLAUSES),
        .NUM_VARS        (NUM_VARS),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    clause_array(
        .clk             (clk),
        .rst             (rst),

        .var_value_i     (var_value_from_stlist),
        .var_value_o     (var_value_from_carray),
        .var_lvl_i       (var_lvl_from_stlist),
        .var_lvl_o       (var_lvl_from_carray),
        .participate_o   (),

        .wr_i            (wr_carray_i),
        .rd_i            (rd_carray_i),
        .clause_i        (clause_i),
        .clause_o        (clause_o),
        .clause_len_i    (clause_len),

        .add_learntc_en_i(add_learntc_en),
        .all_c_sat_o     (all_c_is_sat),
        .apply_imply_i   (apply_imply),
        .apply_analyze_i (apply_analyze),
        .apply_bkt_i     (apply_bkt_cur_bin)
    );

    wire [NUM_VARS*2-1:0]  clause_to_len;
    assign clause_to_len = clause_to_carray;

    c_len8 #(
        .WIDTH(WIDTH_C_LEN)
    )
    c_len8(
        .clause_i(clause_to_len),
        .len_o(clause_len)
    );

    /***  输出load的信息 ***/
    `ifdef DEBUG_sat_engine
        `include "../tb/class_clause_data.sv";
        `include "../tb/class_vs_list.sv";
        `include "../tb/class_ls_list.sv";
        class_clause_data #(8) cdata = new;
        class_vs_list #(8, WIDTH_LVL) vs_list = new();
        class_ls_list #(8, WIDTH_BIN_ID) ls_list = new();

        always @(posedge clk) begin
            if(wr_carray_i!=0) begin
                cdata.set_clause(clause_i);
                //$display("sim time %4tns", $time/1000);
                //$display("%1tns wr clause array", $time/1000);
                $display("\t%1tns wr_carray_i = %b", $time/1000, wr_carray_i);
                //$display("\tclause_i = %b", clause_i);
                cdata.display_lits();
                $display("\tclause_len = %1d", clause_len);
            end
            if(wr_var_states!=0) begin
                vs_list.set(var_states_i);
                //$display("sim time %4tns", $time/1000);
                $display("%1tns wr_var_states = %b", $time/1000, wr_var_states);
                vs_list.display();
            end
            if(wr_lvl_states!=0) begin
                ls_list.set(lvl_states_i);
                $display("%1tns wr_lvl_states = %b", $time/1000, wr_lvl_states);
                ls_list.display();
            end
            if(start_core_i==1) begin
                $display("\tbase_lvl_i = %1d", base_lvl_i);
            end
        end
    `endif

    /***  输出update的信息 ***/
    `ifdef DEBUG_sat_engine
        initial begin
            @(posedge clk);
            while(~rst)
                @(posedge clk);

            while(1) begin
                while(start_core_i!=1)
                    @(posedge clk);

                @(posedge clk);
                //$display("sim time %4tns", $time/1000);
                $display("%1tns start_core_i", $time/1000);
                $display("\tcur_bin_num_i = %1d", cur_bin_num_i);
                $display("\tload_lvl_i    = %1d", load_lvl_i);

                while(done_core_o!=1)
                    @(posedge clk);

                //$display("sim time %4tns", $time/1000);
                $display("%1tns done_core_i", $time/1000);

                vs_list.set(lvl_states_o);
                $display("%1tns var_state_list", $time/1000);
                vs_list.display();

                ls_list.set(lvl_states_o);
                $display("%1tns lvl_state_list", $time/1000);
                ls_list.display();
            end
        end

        always @(posedge clk) begin
            if(rd_carray_i!=0) begin
                cdata.set_clause(clause_o);
                //$display("sim time %4tns", $time/1000);
                $display("%1tns rd_carray_i = %b", $time/1000, rd_carray_i);
                //$display("\tclause_i = %b", clause_i);
                cdata.display_lits();
            end
        end

    `endif
endmodule
