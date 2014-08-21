
/**
 *  该文件是使用gen_num_verilog.py生成的
 *  gen_num_verilog ../src/sat_engine/state_list/dcd_in_vars.gen 8
 */

/**
*   在8个变量中，根据free情况计算lock_cnt，并输出index
*/
module dcd_in_var8 #(
        parameter NUM = 8,
        parameter WIDTH = 3
    )
    (
        input [NUM*WIDTH-1 : 0] value_i,
        input [1:0]             lock_cnt_i,
        output [1:0]            lock_cnt_o,
        output [NUM-1 : 0]      index_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*WIDTH/2-1 : 0] value_i_0, value_i_1;
    wire [NUM/2-1 : 0]           index_o_0, index_o_1;
    wire [1:0]                   lock_cnt_o_0;
    assign {value_i_1, value_i_0} = value_i;
    assign index_o = {index_o_1, index_o_0};

    dcd_in_var4 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var4_0(
        .value_i(value_i_0),
        .lock_cnt_i(lock_cnt_i),
        .lock_cnt_o(lock_cnt_o_0),
        .index_o(index_o_0)
    );

    dcd_in_var4 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var4_1(
        .value_i(value_i_1),
        .lock_cnt_i(lock_cnt_o_0),
        .lock_cnt_o(lock_cnt_o),
        .index_o(index_o_1)
    );

endmodule


/**
*   在4个变量中，根据free情况计算lock_cnt，并输出index
*/
module dcd_in_var4 #(
        parameter NUM = 4,
        parameter WIDTH = 3
    )
    (
        input [NUM*WIDTH-1 : 0] value_i,
        input [1:0]             lock_cnt_i,
        output [1:0]            lock_cnt_o,
        output [NUM-1 : 0]      index_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*WIDTH/2-1 : 0] value_i_0, value_i_1;
    wire [NUM/2-1 : 0]           index_o_0, index_o_1;
    wire [1:0]                   lock_cnt_o_0;
    assign {value_i_1, value_i_0} = value_i;
    assign index_o = {index_o_1, index_o_0};

    dcd_in_var2 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var2_0(
        .value_i(value_i_0),
        .lock_cnt_i(lock_cnt_i),
        .lock_cnt_o(lock_cnt_o_0),
        .index_o(index_o_0)
    );

    dcd_in_var2 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var2_1(
        .value_i(value_i_1),
        .lock_cnt_i(lock_cnt_o_0),
        .lock_cnt_o(lock_cnt_o),
        .index_o(index_o_1)
    );

endmodule


/**
*   在2个变量中，根据free情况计算lock_cnt，并输出index
*/
module dcd_in_var2 #(
        parameter NUM = 2,
        parameter WIDTH = 3
    )
    (
        input [NUM*WIDTH-1 : 0] value_i,
        input [1:0]             lock_cnt_i,
        output [1:0]            lock_cnt_o,
        output [NUM-1 : 0]      index_o
    );

    parameter NUM_SUB = NUM;

    wire [NUM_SUB*WIDTH/2-1 : 0] value_i_0, value_i_1;
    wire [NUM/2-1 : 0]           index_o_0, index_o_1;
    wire [1:0]                   lock_cnt_o_0;
    assign {value_i_1, value_i_0} = value_i;
    assign index_o = {index_o_1, index_o_0};

    dcd_in_var1 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var1_0(
        .value_i(value_i_0),
        .lock_cnt_i(lock_cnt_i),
        .lock_cnt_o(lock_cnt_o_0),
        .index_o(index_o_0)
    );

    dcd_in_var1 #(
        .WIDTH(WIDTH)
    )
    dcd_in_var1_1(
        .value_i(value_i_1),
        .lock_cnt_i(lock_cnt_o_0),
        .lock_cnt_o(lock_cnt_o),
        .index_o(index_o_1)
    );

endmodule

