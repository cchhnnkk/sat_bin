
module reduce_in_8_datas #(
		parameter NUM = 8,
		parameter WIDTH = 5
	)
	(
	 input [NUM*WIDTH-1 : 0] data_i,
	 input [NUM-1 : 0]       rd_i,
	 output [WIDTH-1 : 0]    data_o
	);
    parameter NUM_SUB = NUM/2;

    wire [NUM_SUB*WIDTH-1 : 0] data_i_0, data_i_1;
    wire [WIDTH-1 : 0]         data_o_0, data_o_1;
    wire [NUM/2-1 : 0]         rd_i_0, rd_i_1;

    assign {rd_i_1, rd_i_0} = rd_i;
    assign {data_i_1, data_i_0} = data_i;
    assign data_o = rd_i_0!=0 ? data_o_0 : data_o_1;

	reduce_in_4_datas #(
		.WIDTH(WIDTH)
	)
	reduce_in_4_datas_inst0 (
		.data_i(data_i_0),
		.data_o(data_o_0),
		.rd_i(rd_i_0)
	);

	reduce_in_4_datas #(
		.WIDTH(WIDTH)
	)
	reduce_in_4_datas_inst1 (
		.data_i(data_i_1),
		.data_o(data_o_1),
		.rd_i(rd_i_1)
	);

endmodule

module reduce_in_4_datas #(
        parameter NUM = 4,
        parameter WIDTH = 5
    )
    (
        input [NUM*WIDTH-1 : 0] data_i,
        input [NUM-1 : 0]       rd_i,
        output [WIDTH-1 : 0]    data_o
    );
    parameter NUM_SUB = NUM/2;

    wire [NUM_SUB*WIDTH-1 : 0] data_i_0, data_i_1;
    wire [WIDTH-1 : 0]         data_o_0, data_o_1;
    wire [NUM/2-1 : 0]         rd_i_0, rd_i_1;

    assign {rd_i_1, rd_i_0} = rd_i;
    assign {data_i_1, data_i_0} = data_i;
    assign data_o = rd_i_0!=0 ? data_o_0 : data_o_1;

    reduce_in_2_datas #(
        .WIDTH(WIDTH)
    )
    reduce_in_2_datas_inst0 (
        .data_i(data_i_0),
        .data_o(data_o_0),
        .rd_i(rd_i_0)
    );

    reduce_in_2_datas #(
        .WIDTH(WIDTH)
    )
    reduce_in_2_datas_inst1 (
        .data_i(data_i_1),
        .data_o(data_o_1),
        .rd_i(rd_i_1)
    );

endmodule


module reduce_in_2_datas #(
        parameter NUM = 2,
        parameter WIDTH = 5
    )
    (
        input [NUM*WIDTH-1 : 0] data_i,
        input [NUM-1 : 0]       rd_i,
        output [WIDTH-1 : 0]    data_o
    );
    parameter NUM_SUB = NUM/2;

    wire [NUM_SUB*WIDTH-1 : 0] data_i_0, data_i_1;
    wire [NUM/2-1 : 0]         rd_i_0, rd_i_1;

    assign {rd_i_1, rd_i_0} = rd_i;
    assign {data_i_1, data_i_0} = data_i;
    assign data_o = rd_i_0!=0 ? data_i_0 : data_i_1;

endmodule

