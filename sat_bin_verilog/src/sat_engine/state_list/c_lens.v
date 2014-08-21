
/**
 *  该文件是使用gen_num_verilog.py生成的
 *  gen_num_verilog ../src/sat_engine/state_list/c_lens.gen 8
 */

/**
*   在8个变量中，求解子句的长度
*/
module c_len8 #(
        parameter NUM = 8,
        parameter WIDTH = 3
    )
    (
        input [NUM*2-1 : 0]     clause_i,
        output [WIDTH-1 : 0]    len_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*2/2-1 : 0]     clause_i_0, clause_i_1;
    wire [WIDTH-1 : 0]           len_o_0, len_o_1;
    assign {clause_i_1, clause_i_0} = clause_i;
    assign len_o = len_o_1 + len_o_0;

    c_len4 #(
        .WIDTH(WIDTH)
    )
    c_len4_0(
        .clause_i(clause_i_0),
        .len_o(len_o_0)
    );

    c_len4 #(
        .WIDTH(WIDTH)
    )
    c_len4_1(
        .clause_i(clause_i_1),
        .len_o(len_o_1)
    );

endmodule


/**
*   在4个变量中，求解子句的长度
*/
module c_len4 #(
        parameter NUM = 4,
        parameter WIDTH = 3
    )
    (
        input [NUM*2-1 : 0]     clause_i,
        output [WIDTH-1 : 0]    len_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*2/2-1 : 0]     clause_i_0, clause_i_1;
    wire [WIDTH-1 : 0]           len_o_0, len_o_1;
    assign {clause_i_1, clause_i_0} = clause_i;
    assign len_o = len_o_1 + len_o_0;

    c_len2 #(
        .WIDTH(WIDTH)
    )
    c_len2_0(
        .clause_i(clause_i_0),
        .len_o(len_o_0)
    );

    c_len2 #(
        .WIDTH(WIDTH)
    )
    c_len2_1(
        .clause_i(clause_i_1),
        .len_o(len_o_1)
    );

endmodule


/**
*   在2个变量中，求解子句的长度
*/
module c_len2 #(
        parameter NUM = 2,
        parameter WIDTH = 3
    )
    (
        input [NUM*2-1 : 0]     clause_i,
        output [WIDTH-1 : 0]    len_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*2/2-1 : 0]     clause_i_0, clause_i_1;
    wire [WIDTH-1 : 0]           len_o_0, len_o_1;
    assign {clause_i_1, clause_i_0} = clause_i;
    assign len_o = len_o_1 + len_o_0;

    c_len1 #(
        .WIDTH(WIDTH)
    )
    c_len1_0(
        .clause_i(clause_i_0),
        .len_o(len_o_0)
    );

    c_len1 #(
        .WIDTH(WIDTH)
    )
    c_len1_1(
        .clause_i(clause_i_1),
        .len_o(len_o_1)
    );

endmodule

