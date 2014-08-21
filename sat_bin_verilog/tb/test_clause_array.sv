`timescale 1ns/1ps

module test_clause_array(input clk, input rst);

	/* --- 测试free_lit_count --- */
	task run();
		begin
			@(posedge clk);
				test_clause_array_task();
		end
	endtask

	parameter NUM_CLAUSES = 8;
	parameter NUM_VARS = 8;
	parameter WIDTH_LVL = 16;
	parameter WIDTH_VAR_STATES = 30;
	parameter WIDTH_C_LEN = 4;

	reg [4:0] clause_len_i;
	wire [4:0] clause_len_o;
	reg apply_impl_i;
	reg apply_bkt_i;

	reg  [NUM_CLAUSES-1:0]        wr_i;
	reg  [NUM_VARS*3-1:0]         var_value_i;
	wire [NUM_VARS*3-1:0]         var_value_o;
    reg  [NUM_VARS*2-1:0]         clause_i;
    wire [NUM_VARS*2-1:0]         clause_o;
	wire [NUM_CLAUSES-1:0]        learntc_insert_index_o;
	reg  [NUM_VARS*WIDTH_LVL-1:0] var_lvl_i;
	wire [NUM_VARS*WIDTH_LVL-1:0] var_lvl_o;

	clause_array #(
		.NUM_CLAUSES(NUM_CLAUSES),
		.NUM_VARS   (NUM_VARS),
		.WIDTH_C_LEN(WIDTH_C_LEN)
	)
	clause_array(
		.clk         (clk),
		.rst         (rst),
		.wr_i        (wr_i),
        .clause_i      (clause_i),
        .clause_o      (clause_o),
		.clause_len_i(clause_len_i),

		.var_value_i (var_value_i),
		.var_value_o (var_value_o),

        .var_lvl_i   (var_lvl_i),
        .var_lvl_o   (var_lvl_o),

		.apply_imply_i(apply_imply_i),
		.apply_bkt_i (apply_bkt_i)
	);

	`include "../tb/class_clause_array.sv";
    `include "../tb/class_lvl_data.sv";
	class_clause_array #(8, 8) carray_data = new;
    class_clause_data  #(8)    cdata       = new;
	class_lvl_data     #(8,16) ldata       = new;

	int bin1[8][8] = '{
			'{2, 0, 1, 0, 0, 0, 0, 0},
			'{0, 2, 0, 1, 0, 2, 0, 0},
			'{2, 0, 0, 1, 2, 0, 0, 0},
			'{1, 1, 0, 0, 1, 0, 0, 0},

			'{0, 1, 2, 0, 2, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0}
		};

	int bin2[8][8] = '{
			'{2, 0, 1, 0, 0, 0, 0, 0},
			'{0, 2, 0, 1, 0, 2, 0, 0},
			'{2, 0, 0, 1, 2, 0, 0, 0},
			'{1, 1, 0, 0, 1, 0, 0, 0},

			'{0, 1, 2, 0, 2, 0, 0, 0},
			'{0, 0, 0, 1, 0, 0, 2, 0},
			'{2, 0, 0, 1, 0, 1, 0, 1},
			'{1, 0, 1, 0, 0, 1, 2, 0}
		};

	task wr_clause_array(input int bin_data[8][8]);
		begin
			carray_data.reset();
			carray_data.set_array(bin_data);

			for (int i = 0; i < 8; ++i)
			begin
				@ (posedge clk);
					wr_i = 0;
					wr_i[i] = 1;
					clause_len_i = carray_data.get_len(i);
					carray_data.get_clause(i, clause_i);
                	carray_data.cdatas[i].display_lits();
			end
			@ (posedge clk);
				wr_i = 0;
			@ (posedge clk);
		end
	endtask

	bit [NUM_CLAUSES-1:0] inserti;
	task test_inserti(input int bin_data[8][8]);
		begin
			@ (posedge clk);
				$display("test_inserti");
				apply_bkt_i = 0;
				apply_impl_i = 0;
			@ (posedge clk);
				wr_clause_array(bin_data);
				inserti = 0;
				carray_data.get_learntc_inserti(inserti);
				$display("inserti=%b\tlearntc_insert_index_o=%b", inserti, clause_array.learntc_insert_index);
				assert(inserti == clause_array.learntc_insert_index);
		end
	endtask

	int bin3[8][8] = '{
			'{2, 0, 1, 0, 0, 0, 0, 0},
			'{0, 2, 0, 1, 0, 2, 0, 0},
			'{2, 0, 0, 1, 2, 0, 0, 0},
			'{1, 1, 0, 0, 1, 0, 0, 0},

			'{0, 1, 2, 0, 2, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0},
			'{0, 0, 0, 0, 0, 0, 0, 0}
		};
	int level3[] = '{1, 2, 3, 4, 5, 6, 7, 8};

	task test_lvl_data(input int bin_data[8][8], level[8]);
		begin
			@ (posedge clk);
				$display("test_lvl_data");
				apply_bkt_i = 0;
				apply_impl_i = 0;
			@ (posedge clk);
				wr_clause_array(bin_data);
                ldata.set_lvls(level);
                ldata.get(var_lvl_i);
                $display("%1tns var_lvl_i", $time/1000.0);
                ldata.display();

            @ (posedge clk);
                cdata.set_lits('{0, 2, 0, 0, 0, 2, 0, 0});
                cdata.set_imps('{0, 0, 0, 0, 0, 0, 0, 0});
                cdata.get(var_value_i);
                $display("%1tns var_value_i", $time/1000.0);
                cdata.display();

                # 1
                cdata.set(var_value_o);
                $display("%1tns var_value_o", $time/1000.0);
                cdata.display();

                ldata.set(var_lvl_o);
                $display("%1tns var_lvl_o", $time/1000.0);
                ldata.display();

            @ (posedge clk);
                cdata.set_lits('{1, 1, 0, 0, 0, 0, 0, 0});
                cdata.set_imps('{0, 0, 0, 0, 0, 0, 0, 0});
                cdata.get(var_value_i);
                $display("%1tns var_value_i", $time/1000.0);
                cdata.display();

                # 1
                cdata.set(var_value_o);
                $display("%1tns var_value_o", $time/1000.0);
                cdata.display();

                ldata.set(var_lvl_o);
                $display("%1tns var_lvl_o", $time/1000.0);
                ldata.display();

		end
	endtask
	/* --- 测试free_lit_count --- */
	task test_clause_array_task();
		begin
			$display("test_clause_array_task");
			test_inserti(bin1);
			test_inserti(bin2);
			test_lvl_data(bin3, level3);
		end
	endtask
endmodule


module test_clause_array_top;
	reg  clk;
	reg  rst;

	always #5 clk<=~clk;

	initial begin: init
		clk = 0;
		rst=0;
	end

	// initial begin
	// 	$fsdbDumpfile("wave_test_clause_array.fsdb");
	// 	$fsdbDumpvars;
	// end

	task reset();
		begin
			@(posedge clk);
				rst=0;
				clk=0;

			@(posedge clk);
				rst=1;
		end
	endtask

	test_clause_array test_clause_array(
		.clk(clk),
		.rst(rst)
	);

	initial begin
		reset();
        $display("start sim");
		test_clause_array.run();
        $display("done sim");
        $finish();
	end
endmodule
