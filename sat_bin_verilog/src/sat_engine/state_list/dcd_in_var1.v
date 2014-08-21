/**
*   在单个变量中，根据free情况计算lock_cnt，并输出index
*/
module dcd_in_var1 #(
        parameter NUM = 1,
        parameter WIDTH = 3
    )
    (
        input [NUM*WIDTH-1 : 0] value_i,
        input [1:0]             lock_cnt_i,
        output [1:0]            lock_cnt_o,
        output [NUM-1 : 0]      index_o
    );

    assign lock_cnt_o = lock_cnt_i!=0?2'b11:(value_i==0? 2'b01:2'b00);
    assign index_o = lock_cnt_o == 1? 1 : 0;

endmodule

