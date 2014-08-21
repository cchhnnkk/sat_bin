/**
 子句阵列的实现
 主要功能：实例化clause8，以及find_learntc_inserti
 */
module max_in_8_datas #(
		parameter NUM = 8,
		parameter WIDTH = 5
		)
	(
	 input [NUM*WIDTH-1 : 0] data_i,
	 output [WIDTH-1 : 0]    data_o,
	 output [NUM-1 : 0]      index_o
	);
    parameter NUM_SUB = NUM/2;

    wire [NUM_SUB*WIDTH-1 : 0] data_i_0, data_i_1;
    wire [WIDTH-1 : 0]         data_o_0, data_o_1;
    wire [NUM/2-1 : 0]         index_o_0, index_o_1;

    assign {data_i_1, data_i_0} = data_i;
    assign data_o = data_o_0 >= data_o_1 ? data_o_0 : data_o_1;
    assign index_o = data_o_0 >= data_o_1 ? {4'd0, index_o_0} : {index_o_1, 4'd0};

	max_in_4_datas #(
			.WIDTH(WIDTH)
			)
	max_in_4_datas_inst0 (
			.data_i(data_i_0),
			.data_o(data_o_0),
			.index_o(index_o_0)
			);

	max_in_4_datas #(
			.WIDTH(WIDTH)
			)
	max_in_4_datas_inst1 (
			.data_i(data_i_1),
			.data_o(data_o_1),
			.index_o(index_o_1)
			);

endmodule

module max_in_4_datas #(
		parameter NUM = 4,
		parameter WIDTH = 5
		)
	(
	 input [NUM*WIDTH-1 : 0] data_i,
	 output [WIDTH-1 : 0]    data_o,
	 output [NUM-1 : 0]      index_o
	);
	parameter NUM_SUB = NUM/2;

	wire [NUM_SUB*WIDTH-1 : 0] data_i_0, data_i_1;
	assign {data_i_1, data_i_0} = data_i;

	wire [WIDTH-1 : 0]         data_o_0, data_o_1;
	assign data_o = data_o_0 >= data_o_1 ? data_o_0 : data_o_1;


	wire [NUM/2-1 : 0]         index_o_0, index_o_1;
	assign index_o = data_o_0 >= data_o_1 ? {2'd0, index_o_0} : {index_o_1, 2'd0};

	max_in_2_datas #(
			.WIDTH(WIDTH)
			)
	max_in_2_datas_inst0 (
			.data_i(data_i_0),
			.data_o(data_o_0),
			.index_o(index_o_0)
			);

	max_in_2_datas #(
			.WIDTH(WIDTH)
			)
	max_in_2_datas_inst1 (
			.data_i(data_i_1),
			.data_o(data_o_1),
			.index_o(index_o_1)
			);

	endmodule


module max_in_2_datas #(
		parameter NUM = 2,
		parameter WIDTH = 5
		)
	(
	 input [NUM*WIDTH-1 : 0] data_i,
	 output [WIDTH-1 : 0]    data_o,
	 output [NUM-1 : 0]      index_o
	);
	parameter NUM_SUB = NUM;

	wire [NUM_SUB*WIDTH/2-1 : 0] data_i_0, data_i_1;
	assign {data_i_1, data_i_0} = data_i;

	assign data_o = data_i_0 >= data_i_1 ? data_i_0 : data_i_1;
	assign index_o = data_i_0 >= data_i_1 ? 2'b01 : 2'b10;

	endmodule

