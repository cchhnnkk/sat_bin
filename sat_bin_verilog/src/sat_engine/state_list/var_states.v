
/**
 *  该文件是使用gen_num_verilog.py生成的
 *  gen_num_verilog ../src/sat_engine/state_list/var_states.gen 8
 */
/**
 维护Sat Engine中两个变量的状态，每个变量的状态包括： reg [2:0] var_value_r; reg [15:0] var_lvl_r;
 生成学习子句：
     value为11的变量，而且该变量:
     非当前层 or 当前层决策 or 当前层没有原因子句的
 */
module var_state8 #(
        parameter NUM_VARS         = 8,
        parameter WIDTH_C_LEN      = 4,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_VAR_STATES = 19
    )
    (
        input                                    clk, 
        input                                    rst, 

        // data I/O
        input [NUM_VARS*3-1:0]                   var_value_i,
        output [NUM_VARS*3-1:0]                  var_value_o,
        input [NUM_VARS*WIDTH_LVL-1:0]           var_lvl_i,
        output [NUM_VARS*WIDTH_LVL-1:0]          var_lvl_o,
        output [NUM_VARS*2-1:0]                  learnt_lit_o,

        //decide
        input [NUM_VARS-1:0]                     valid_from_decision_i,
        input [WIDTH_LVL-1:0]                    cur_lvl_i,

        //imply
        input                                    apply_imply_i,
        output [NUM_VARS-1:0]                    find_imply_o,
        output [NUM_VARS-1:0]                    find_conflict_o,

        //conflict
        input                                    apply_analyze_i,
        output [WIDTH_LVL-1:0]                   max_lvl_o,

        //backtrack
        input                                    apply_bkt_i,
        input [WIDTH_LVL-1:0]                    bkt_lvl_i,

        //load update var states
        input [NUM_VARS-1:0]                     wr_states,
        input [WIDTH_VAR_STATES*NUM_VARS-1 : 0]  var_states_i,
        output [WIDTH_VAR_STATES*NUM_VARS-1 : 0] var_states_o,

        //用于调试的信号
        input  [31 : 0]                          debug_vid_next_i,
        output [31 : 0]                          debug_vid_next_o
    );

    wire [NUM_VARS*3/2-1 : 0]         var_value_i_0,            var_value_i_1;
    wire [NUM_VARS*3/2-1 : 0]         var_value_o_0,            var_value_o_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,              var_lvl_i_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_o_0,              var_lvl_o_1;
    wire [NUM_VARS*2/2-1 : 0]         learnt_lit_o_0,           learnt_lit_o_1;
    wire [NUM_VARS/2-1:0]             valid_from_decision_i_0,  valid_from_decision_i_1;
    wire [NUM_VARS/2-1:0]             find_imply_o_0,           find_imply_o_1;
    wire [NUM_VARS/2-1:0]             find_conflict_o_0,        find_conflict_o_1;
    wire [WIDTH_LVL-1:0]              max_lvl_o_0,              max_lvl_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign var_value_o = {var_value_o_1, var_value_o_0};
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign var_lvl_o = {var_lvl_o_1, var_lvl_o_0};
    assign learnt_lit_o = {learnt_lit_o_1, learnt_lit_o_0};
    assign {valid_from_decision_i_1, valid_from_decision_i_0} = valid_from_decision_i;

    assign find_imply_o = {find_imply_o_1, find_imply_o_0};
    assign find_conflict_o = {find_conflict_o_1, find_conflict_o_0};

    assign max_lvl_o = max_lvl_o_1 > max_lvl_o_0 ? max_lvl_o_1 : max_lvl_o_0;

    wire [NUM_VARS/2-1:0]                    wr_states_0, wr_states_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_i_0, var_states_i_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_o_0, var_states_o_1;

    assign {wr_states_1, wr_states_0} = wr_states;
    assign {var_states_i_1, var_states_i_0} = var_states_i;
    assign var_states_o = {var_states_o_1, var_states_o_0};

    var_state4 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state4_0(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_0),
        .var_value_o          (var_value_o_0),
        .var_lvl_i            (var_lvl_i_0),
        .var_lvl_o            (var_lvl_o_0),
        .learnt_lit_o         (learnt_lit_o_0),
        .valid_from_decision_i(valid_from_decision_i_0),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_0),
        .find_conflict_o      (find_conflict_o_0),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_0),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_0),
        .var_states_i        (var_states_i_0),
        .var_states_o        (var_states_o_0),

        .debug_vid_next_i     (debug_vid_next_i),
        .debug_vid_next_o     (debug_vid_temp)
    );

    var_state4 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state4_1(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_1),
        .var_value_o          (var_value_o_1),
        .var_lvl_i            (var_lvl_i_1),
        .var_lvl_o            (var_lvl_o_1),
        .learnt_lit_o         (learnt_lit_o_1),
        .valid_from_decision_i(valid_from_decision_i_1),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_1),
        .find_conflict_o      (find_conflict_o_1),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_1),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_1),
        .var_states_i        (var_states_i_1),
        .var_states_o        (var_states_o_1),

        .debug_vid_next_i     (debug_vid_temp),
        .debug_vid_next_o     (debug_vid_next_o)
    );

endmodule

/**
 维护Sat Engine中两个变量的状态，每个变量的状态包括： reg [2:0] var_value_r; reg [15:0] var_lvl_r;
 生成学习子句：
     value为11的变量，而且该变量:
     非当前层 or 当前层决策 or 当前层没有原因子句的
 */
module var_state4 #(
        parameter NUM_VARS         = 4,
        parameter WIDTH_C_LEN      = 4,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_VAR_STATES = 19
    )
    (
        input                                    clk, 
        input                                    rst, 

        // data I/O
        input [NUM_VARS*3-1:0]                   var_value_i,
        output [NUM_VARS*3-1:0]                  var_value_o,
        input [NUM_VARS*WIDTH_LVL-1:0]           var_lvl_i,
        output [NUM_VARS*WIDTH_LVL-1:0]          var_lvl_o,
        output [NUM_VARS*2-1:0]                  learnt_lit_o,

        //decide
        input [NUM_VARS-1:0]                     valid_from_decision_i,
        input [WIDTH_LVL-1:0]                    cur_lvl_i,

        //imply
        input                                    apply_imply_i,
        output [NUM_VARS-1:0]                    find_imply_o,
        output [NUM_VARS-1:0]                    find_conflict_o,

        //conflict
        input                                    apply_analyze_i,
        output [WIDTH_LVL-1:0]                   max_lvl_o,

        //backtrack
        input                                    apply_bkt_i,
        input [WIDTH_LVL-1:0]                    bkt_lvl_i,

        //load update var states
        input [NUM_VARS-1:0]                     wr_states,
        input [WIDTH_VAR_STATES*NUM_VARS-1 : 0]  var_states_i,
        output [WIDTH_VAR_STATES*NUM_VARS-1 : 0] var_states_o,

        //用于调试的信号
        input  [31 : 0]                          debug_vid_next_i,
        output [31 : 0]                          debug_vid_next_o
    );

    wire [NUM_VARS*3/2-1 : 0]         var_value_i_0,            var_value_i_1;
    wire [NUM_VARS*3/2-1 : 0]         var_value_o_0,            var_value_o_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,              var_lvl_i_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_o_0,              var_lvl_o_1;
    wire [NUM_VARS*2/2-1 : 0]         learnt_lit_o_0,           learnt_lit_o_1;
    wire [NUM_VARS/2-1:0]             valid_from_decision_i_0,  valid_from_decision_i_1;
    wire [NUM_VARS/2-1:0]             find_imply_o_0,           find_imply_o_1;
    wire [NUM_VARS/2-1:0]             find_conflict_o_0,        find_conflict_o_1;
    wire [WIDTH_LVL-1:0]              max_lvl_o_0,              max_lvl_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign var_value_o = {var_value_o_1, var_value_o_0};
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign var_lvl_o = {var_lvl_o_1, var_lvl_o_0};
    assign learnt_lit_o = {learnt_lit_o_1, learnt_lit_o_0};
    assign {valid_from_decision_i_1, valid_from_decision_i_0} = valid_from_decision_i;

    assign find_imply_o = {find_imply_o_1, find_imply_o_0};
    assign find_conflict_o = {find_conflict_o_1, find_conflict_o_0};

    assign max_lvl_o = max_lvl_o_1 > max_lvl_o_0 ? max_lvl_o_1 : max_lvl_o_0;

    wire [NUM_VARS/2-1:0]                    wr_states_0, wr_states_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_i_0, var_states_i_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_o_0, var_states_o_1;

    assign {wr_states_1, wr_states_0} = wr_states;
    assign {var_states_i_1, var_states_i_0} = var_states_i;
    assign var_states_o = {var_states_o_1, var_states_o_0};

    var_state2 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state2_0(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_0),
        .var_value_o          (var_value_o_0),
        .var_lvl_i            (var_lvl_i_0),
        .var_lvl_o            (var_lvl_o_0),
        .learnt_lit_o         (learnt_lit_o_0),
        .valid_from_decision_i(valid_from_decision_i_0),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_0),
        .find_conflict_o      (find_conflict_o_0),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_0),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_0),
        .var_states_i        (var_states_i_0),
        .var_states_o        (var_states_o_0),

        .debug_vid_next_i     (debug_vid_next_i),
        .debug_vid_next_o     (debug_vid_temp)
    );

    var_state2 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state2_1(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_1),
        .var_value_o          (var_value_o_1),
        .var_lvl_i            (var_lvl_i_1),
        .var_lvl_o            (var_lvl_o_1),
        .learnt_lit_o         (learnt_lit_o_1),
        .valid_from_decision_i(valid_from_decision_i_1),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_1),
        .find_conflict_o      (find_conflict_o_1),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_1),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_1),
        .var_states_i        (var_states_i_1),
        .var_states_o        (var_states_o_1),

        .debug_vid_next_i     (debug_vid_temp),
        .debug_vid_next_o     (debug_vid_next_o)
    );

endmodule

/**
 维护Sat Engine中两个变量的状态，每个变量的状态包括： reg [2:0] var_value_r; reg [15:0] var_lvl_r;
 生成学习子句：
     value为11的变量，而且该变量:
     非当前层 or 当前层决策 or 当前层没有原因子句的
 */
module var_state2 #(
        parameter NUM_VARS         = 2,
        parameter WIDTH_C_LEN      = 4,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_VAR_STATES = 19
    )
    (
        input                                    clk, 
        input                                    rst, 

        // data I/O
        input [NUM_VARS*3-1:0]                   var_value_i,
        output [NUM_VARS*3-1:0]                  var_value_o,
        input [NUM_VARS*WIDTH_LVL-1:0]           var_lvl_i,
        output [NUM_VARS*WIDTH_LVL-1:0]          var_lvl_o,
        output [NUM_VARS*2-1:0]                  learnt_lit_o,

        //decide
        input [NUM_VARS-1:0]                     valid_from_decision_i,
        input [WIDTH_LVL-1:0]                    cur_lvl_i,

        //imply
        input                                    apply_imply_i,
        output [NUM_VARS-1:0]                    find_imply_o,
        output [NUM_VARS-1:0]                    find_conflict_o,

        //conflict
        input                                    apply_analyze_i,
        output [WIDTH_LVL-1:0]                   max_lvl_o,

        //backtrack
        input                                    apply_bkt_i,
        input [WIDTH_LVL-1:0]                    bkt_lvl_i,

        //load update var states
        input [NUM_VARS-1:0]                     wr_states,
        input [WIDTH_VAR_STATES*NUM_VARS-1 : 0]  var_states_i,
        output [WIDTH_VAR_STATES*NUM_VARS-1 : 0] var_states_o,

        //用于调试的信号
        input  [31 : 0]                          debug_vid_next_i,
        output [31 : 0]                          debug_vid_next_o
    );

    wire [NUM_VARS*3/2-1 : 0]         var_value_i_0,            var_value_i_1;
    wire [NUM_VARS*3/2-1 : 0]         var_value_o_0,            var_value_o_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,              var_lvl_i_1;
    wire [NUM_VARS*WIDTH_LVL/2-1 : 0] var_lvl_o_0,              var_lvl_o_1;
    wire [NUM_VARS*2/2-1 : 0]         learnt_lit_o_0,           learnt_lit_o_1;
    wire [NUM_VARS/2-1:0]             valid_from_decision_i_0,  valid_from_decision_i_1;
    wire [NUM_VARS/2-1:0]             find_imply_o_0,           find_imply_o_1;
    wire [NUM_VARS/2-1:0]             find_conflict_o_0,        find_conflict_o_1;
    wire [WIDTH_LVL-1:0]              max_lvl_o_0,              max_lvl_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign var_value_o = {var_value_o_1, var_value_o_0};
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign var_lvl_o = {var_lvl_o_1, var_lvl_o_0};
    assign learnt_lit_o = {learnt_lit_o_1, learnt_lit_o_0};
    assign {valid_from_decision_i_1, valid_from_decision_i_0} = valid_from_decision_i;

    assign find_imply_o = {find_imply_o_1, find_imply_o_0};
    assign find_conflict_o = {find_conflict_o_1, find_conflict_o_0};

    assign max_lvl_o = max_lvl_o_1 > max_lvl_o_0 ? max_lvl_o_1 : max_lvl_o_0;

    wire [NUM_VARS/2-1:0]                    wr_states_0, wr_states_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_i_0, var_states_i_1;
    wire [WIDTH_VAR_STATES*NUM_VARS/2-1 : 0] var_states_o_0, var_states_o_1;

    assign {wr_states_1, wr_states_0} = wr_states;
    assign {var_states_i_1, var_states_i_0} = var_states_i;
    assign var_states_o = {var_states_o_1, var_states_o_0};

    var_state1 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state1_0(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_0),
        .var_value_o          (var_value_o_0),
        .var_lvl_i            (var_lvl_i_0),
        .var_lvl_o            (var_lvl_o_0),
        .learnt_lit_o         (learnt_lit_o_0),
        .valid_from_decision_i(valid_from_decision_i_0),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_0),
        .find_conflict_o      (find_conflict_o_0),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_0),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_0),
        .var_states_i        (var_states_i_0),
        .var_states_o        (var_states_o_0),

        .debug_vid_next_i     (debug_vid_next_i),
        .debug_vid_next_o     (debug_vid_temp)
    );

    var_state1 #(
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_C_LEN     (WIDTH_C_LEN)
    )
    var_state1_1(
        .clk                  (clk),
        .rst                  (rst),
        .var_value_i          (var_value_i_1),
        .var_value_o          (var_value_o_1),
        .var_lvl_i            (var_lvl_i_1),
        .var_lvl_o            (var_lvl_o_1),
        .learnt_lit_o         (learnt_lit_o_1),
        .valid_from_decision_i(valid_from_decision_i_1),
        .cur_lvl_i            (cur_lvl_i),
        .apply_imply_i        (apply_imply_i),
        .find_imply_o         (find_imply_o_1),
        .find_conflict_o      (find_conflict_o_1),
        .apply_analyze_i      (apply_analyze_i),
        .max_lvl_o            (max_lvl_o_1),
        .apply_bkt_i          (apply_bkt_i),
        .bkt_lvl_i            (bkt_lvl_i),
        .wr_states            (wr_states_1),
        .var_states_i        (var_states_i_1),
        .var_states_o        (var_states_o_1),

        .debug_vid_next_i     (debug_vid_temp),
        .debug_vid_next_o     (debug_vid_next_o)
    );

endmodule

