/**
*   求解子句的长度
*/
module c_len1 #(
        parameter NUM = 1,
        parameter WIDTH = 4
    )
    (
        input [NUM*2-1 : 0]     clause_i,
        output [WIDTH-1 : 0]    len_o
    );

    assign len_o = clause_i != 0? 1 : 0;

endmodule

