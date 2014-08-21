`timescale 1ns/1ps

module test_lit1();

    reg  clk;
    reg  rst;

    always #5 clk<=~clk;

    initial begin: init
        clk = 0;
        rst=0;
    end

    /* --- 测试free_lit_count --- */
    task run();
        begin
            @(posedge clk);
                reset_state;
            @(posedge clk);
                test_free_lit_count;
        end
    endtask

    task reset_state();
        begin
            @(posedge clk);
                rst=0;
                clk=0;

            @(posedge clk);
                rst=1;
        end
    endtask

    reg wr_i;
    reg [2:0] var_value_i;
    wire [2:0] var_value_o;
    reg [1:0] freelitcnt_pre;
    wire [1:0] freelitcnt_next;
    reg imp_drv_i;
    wire conflict_c_o;
    reg conflict_c_drv_i;
    wire clausesat_o;

    lit1 lit1(
        .clk(clk),
        .rst(rst),
        .wr_i(wr_i),
        .var_value_i(var_value_i),
        .var_value_o(var_value_o),
        .freelitcnt_pre(freelitcnt_pre),
        .freelitcnt_next(freelitcnt_next),
        .imp_drv_i(imp_drv_i),
        .conflict_c_o(conflict_c_o),
        .conflict_c_drv_i(conflict_c_drv_i),
        .clausesat_o(clausesat_o)
    );

    reg [31:0] cnt_fail;

    /* --- 测试free_lit_count --- */
    task test_free_lit_count();
        begin
            $display("test_free_lit_count");
            var_value_i[2:1] = 0;
            var_value_i[0] = 0;
            cnt_fail = 0;
            @ (posedge clk);
                freelitcnt_pre = 0;
                write_lit_true();

            @ (posedge clk)
                assert(freelitcnt_next == 1);
                var_value_i[2:1] = 1;
                freelitcnt_pre = 1;

            @ (posedge clk)
                assert(freelitcnt_next == 1);
                var_value_i[2:1] = 0;
                freelitcnt_pre = 1;

            @ (posedge clk)
                assert(freelitcnt_next == 3);
                var_value_i[2:1] = 0;
                freelitcnt_pre = 1;

            @ (posedge clk)
                assert(freelitcnt_next == 3);
                write_lit_free();
        end
    endtask

    /* --- 写入lit --- */
    task write_lit(input [1:0] value);
        begin
            @ (posedge clk);
                wr_i = 1;
                var_value_i[2:1] = value;
            @ (posedge clk)
                wr_i = 0;
                var_value_i[2:1] = 0;
        end
    endtask

    /* --- 写入lit为free --- */
    task write_lit_free();
        begin
            //$display("\twrite_lit_free");
            write_lit(2'd0);
        end
    endtask

    /* --- 写入lit为false --- */
    task write_lit_false();
        begin
            //$display("\twrite_lit_false");
            write_lit(2'd1);
        end
    endtask

    /* --- 写入lit为true --- */
    task write_lit_true();
        begin
            //$display("\twrite_lit_true");
            write_lit(2'd2);
        end
    endtask

    /* --- 写入lit为conflict --- */
    task write_lit_conflict();
        begin
            //$display("\twrite_lit_conflict");
            write_lit(2'd3);
        end
    endtask

endmodule


module test_lit1_top;
    test_lit1 test_lit1_inst();
    initial begin
        test_lit1_inst.run;
        $display("done");
    end
endmodule