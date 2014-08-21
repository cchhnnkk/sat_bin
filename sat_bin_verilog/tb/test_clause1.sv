`timescale 1ns/1ps

module test_clause1(input clk, input rst);

    /* --- 测试free_lit_count --- */
    task run();
        begin
            @(posedge clk);
                test_clause1_task();
        end
    endtask

    parameter NUM_VARS  = 8;
    parameter WIDTH_LVL = 16;

    reg                           wr_i;
    reg  [NUM_VARS*3-1:0]         var_value_i;
    wire [NUM_VARS*3-1:0]         var_value_o;
    reg  [NUM_VARS*2-1:0]         clause_i;
    wire [NUM_VARS*2-1:0]         clause_o;
    reg  [4:0]                    clause_len_i;
    wire [4:0]                    clause_len_o;
    reg                           apply_bkt_i;

    reg  [NUM_VARS*WIDTH_LVL-1:0] var_lvl_i;
    reg  [NUM_VARS*WIDTH_LVL-1:0] var_lvl_down_i;
    wire [NUM_VARS*WIDTH_LVL-1:0] var_lvl_down_o;

    clause1 #(
        .NUM_VARS(NUM_VARS)
    )
    clause1
    (
        .clk             (clk),
        .rst             (rst),
        .var_value_i     (var_value_i),
        .var_value_down_i(0),
        .var_value_down_o(var_value_o),

        .var_lvl_i       (var_lvl_i),
        .var_lvl_down_i  (var_lvl_down_i),
        .var_lvl_down_o  (var_lvl_temp),

        .wr_i            (wr_i),
        .clause_i        (clause_i),
        .clause_o        (clause_o),
        .clause_len_i    (clause_len_i),
        .clause_len_o    (clause_len_o),

        .apply_bkt_i     (apply_bkt_i)
    );

    `include "../tb/class_clause_data.sv";
    `include "../tb/class_lvl_data.sv";
    class_clause_data #(8) cdata_i = new;
    class_clause_data #(8) cdata_o = new;
    class_lvl_data #(8,16) ldata   = new;

    /* --- 测试free_lit_count --- */
    task test_clause1_task();
        begin
            $display("test_clause1_task");
            var_value_i = 0;
            cdata_i.reset();

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                cdata_i.set_lits('{0, 1, 0, 2, 0, 2, 0, 0});
                cdata_i.set_imps('{0, 0, 0, 0, 0, 0, 0, 0});
                cdata_i.display();
                cdata_i.get(var_value_i);
                cdata_i.get_clause(clause_i);

                ldata.set_lvls('{1, 2, 3, 4, 5, 6, 7, 8});
                ldata.get(var_lvl_i);
                ldata.display();
                $display("var_value_i = %b", var_value_i);
                $display("clause_i    = %b", clause_i);
                $display("level       = %b", var_lvl_i);
                wr_i = 1;

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                wr_i = 0;
                #1
                assert(clause1.all_c_sat_o == 1);
                $display("clause1.all_c_sat_o = %1d", clause1.all_c_sat_o);
                assert(clause1.cmax_lvl_from_lits == 6);
                $display("clause1.cmax_lvl_from_lits = %1d", clause1.cmax_lvl_from_lits);

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                cdata_i.reset();
                cdata_i.get(var_value_i);
                #1
                assert(clause1.freelitcnt == 3);
                $display("clause1.freelitcnt = %1d", clause1.freelitcnt);
                assert(clause1.cmax_lvl_from_lits == 0);
                $display("clause1.cmax_lvl_from_lits = %1d", clause1.cmax_lvl_from_lits);

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                cdata_i.set_lits('{0, 2, 0, 0, 0, 1, 0, 0});
                cdata_i.set_imps('{0, 0, 0, 0, 0, 0, 0, 0});
                cdata_i.display();
                cdata_i.get(var_value_i);
                cdata_i.get_clause(clause_i);
                $display("var_value_i = %b", var_value_i);
                $display("clause_i    = %b", clause_i);
                #1
                assert(clause1.freelitcnt == 1);
                $display("clause1.freelitcnt = %1d", clause1.freelitcnt);
                assert(clause1.imp_drv == 1);
                $display("clause1.imp_drv = %1d", clause1.imp_drv);
                assert(clause1.cmax_lvl_from_lits == 6);
                $display("clause1.cmax_lvl_from_lits = %1d", clause1.cmax_lvl_from_lits);
                cdata_o.set(var_value_o);
                cdata_o.assert_index(3, 3'b101);

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                cdata_i.set_index(3, 3'b111);
                cdata_i.get(var_value_i);
                cdata_i.display();
                #1
                assert(clause1.conflict_c_drv == 1);
                $display("clause1.conflict_c_drv = %1d", clause1.conflict_c_drv);
                cdata_o.set(var_value_o);
                cdata_o.display();
                cdata_o.assert_index(1, 3'b110);
                cdata_o.assert_index(3, 3'b110);
                cdata_o.assert_index(5, 3'b110);

            @ (posedge clk);
                $display("%1tns", $time/1000.0);
                $display("write clause");
                cdata_i.set_lits('{0, 2, 0, 2, 0, 1, 0, 0});
                cdata_i.display_lits();
                cdata_i.get_clause(clause_i);
                cdata_i.set_lits('{0, 1, 0, 1, 0, 2, 0, 0});
                cdata_i.get(var_value_i);
                #1
                assert(clause1.conflict_c_drv == 1);
                $display("clause1.conflict_c_drv = %1d", clause1.conflict_c_drv);
                cdata_o.set(var_value_o);
                cdata_o.display();
        end
    endtask

endmodule


module test_clause1_top;
    reg  clk;
    reg  rst;

    always #5 clk<=~clk;

    initial begin: init
        clk = 0;
        rst=0;
    end

    task reset();
        begin
            @(posedge clk);
                rst=0;
                clk=0;

            @(posedge clk);
                rst=1;
        end
    endtask

    test_clause1 test_clause1(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        reset();
        $display("start sim");
        test_clause1.run();
        $display("done sim");
        $finish();
    end
endmodule
