
module scatter_to_8_datas #(
		parameter NUM = 8,
		parameter WIDTH = 5
    )
	(
        input [NUM-1 : 0]        wr_i,
        input [WIDTH-1 : 0]      data_i,
        output [NUM*WIDTH-1 : 0] data_o
	);
    parameter NUM_SUB = NUM/2;
    wire [NUM_SUB*WIDTH-1 : 0] data_o_0, data_o_1;
    wire [NUM/2-1 : 0]         wr_i_0, wr_i_1;
    assign data_o = {data_o_1, data_o_0};
    assign {wr_i_1, wr_i_0} = wr_i;

	scatter_to_4_datas #(
        .WIDTH(WIDTH)
    )
	scatter_to_4_datas_inst0 (
        .wr_i(wr_i_0),
        .data_i(data_i),
        .data_o(data_o_0)
    );

	scatter_to_4_datas #(
        .WIDTH(WIDTH)
    )
	scatter_to_4_datas_inst1 (
        .wr_i(wr_i_1),
        .data_i(data_i),
        .data_o(data_o_1)
    );

endmodule


module scatter_to_4_datas #(
		parameter NUM = 4,
		parameter WIDTH = 5
    )
	(
        input [NUM-1 : 0]        wr_i,
        input [WIDTH-1 : 0]      data_i,
        output [NUM*WIDTH-1 : 0] data_o
	);
    parameter NUM_SUB = NUM/2;
    wire [NUM_SUB*WIDTH-1 : 0] data_o_0, data_o_1;
    wire [NUM/2-1 : 0]         wr_i_0, wr_i_1;
    assign data_o = {data_o_1, data_o_0};
    assign {wr_i_1, wr_i_0} = wr_i;

	scatter_to_2_datas #(
        .WIDTH(WIDTH)
    )
	scatter_to_2_datas_inst0 (
        .wr_i(wr_i_0),
        .data_i(data_i),
        .data_o(data_o_0)
    );

	scatter_to_2_datas #(
        .WIDTH(WIDTH)
    )
	scatter_to_2_datas_inst1 (
        .wr_i(wr_i_1),
        .data_i(data_i),
        .data_o(data_o_1)
    );

endmodule


module scatter_to_2_datas #(
		parameter NUM   = 2,
		parameter WIDTH = 5
    )
	(
        input [NUM-1 : 0]        wr_i,
        input [WIDTH-1 : 0]      data_i,
        output [NUM*WIDTH-1 : 0] data_o
	);
    parameter NUM_SUB = NUM/2;
    wire [NUM_SUB*WIDTH-1 : 0] data_o_0, data_o_1;
    wire                       wr_i_0, wr_i_1;
    assign {wr_i_1, wr_i_0} = wr_i;
    assign data_o_0 = wr_i_0 ? data_i:0;
    assign data_o_1 = wr_i_1 ? data_i:0;
    assign data_o = {data_o_1, data_o_0};
endmodule

