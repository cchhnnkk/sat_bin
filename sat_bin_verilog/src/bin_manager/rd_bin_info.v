/**
*   读取子句信息
*/
module rd_bin_info #(
        parameter WIDTH_CLAUSES = 8*2,
        parameter WIDTH_VARS = 12
    )
    (
        input                             clk,
        input                             rst,

        //control
        input                             start_rdinfo_i,
        output                            done_rdinfo_o,

        input                             data_en,
        input [WIDTH_VARS-1:0]            nv_all_i,
        input [WIDTH_CLAUSES-1:0]         nb_all_i,

        output reg [WIDTH_VARS-1:0]       nv_all_o,
        output reg [WIDTH_CLAUSES-1:0]    nb_all_o
    );

    //保存在寄存器中
    always @(posedge clk)
    begin
        if(~rst)
            nv_all_o <= 0;
        else if(data_en)
            nv_all_o <= nv_all_i;
        else
            nv_all_o <= nv_all_o;
    end

    always @(posedge clk)
    begin
        if(~rst)
            nb_all_o <= 0;
        else if(data_en)
            nb_all_o <= nb_all_i;
        else
            nb_all_o <= nb_all_o;
    end

    assign done_rdinfo_o = start_rdinfo_i;

endmodule
