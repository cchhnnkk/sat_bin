`timescale 1ns/1ps

module test_sat_bin(input clk, input rst);

    /* --- 测试free_lit_count --- */
    task run();
        begin
            @(posedge clk);
                test_sat_bin_task();
        end
    endtask

    parameter NUM_CLAUSES_A_BIN     = 8;
    parameter NUM_VARS_A_BIN        = 8;
    parameter NUM_LVLS_A_BIN        = 8;
    parameter WIDTH_BIN_ID          = 10;
    parameter WIDTH_CLAUSES         = NUM_VARS_A_BIN*2;
    parameter WIDTH_VAR             = 12;
    parameter WIDTH_LVL             = 16;
    parameter WIDTH_VAR_STATES      = 19;
    parameter WIDTH_LVL_STATES      = 11;
    parameter ADDR_WIDTH_CLAUSES    = 9;
    parameter ADDR_WIDTH_VAR        = 9;
    parameter ADDR_WIDTH_VAR_STATES = 9;
    parameter ADDR_WIDTH_LVL_STATES = 9;

    reg           sb_rst;
    reg           start_i;
    wire          done_o;
    wire          global_sat_o;
    wire          global_unsat_o;
    reg                              bin_info_en;
    reg  [WIDTH_VAR-1:0]             nv_all_i;
    reg  [WIDTH_CLAUSES-1:0]         nb_all_i;
    reg                              apply_ex_i;
    reg                              ram_we_v_ex_i;
    reg [WIDTH_VAR-1 : 0]            ram_din_v_ex_i;
    reg [ADDR_WIDTH_VAR-1:0]         ram_addr_v_ex_i;
    reg                              ram_we_c_ex_i;
    reg [WIDTH_CLAUSES-1 : 0]        ram_din_c_ex_i;
    reg [ADDR_WIDTH_CLAUSES-1:0]     ram_addr_c_ex_i;
    reg                              ram_we_vs_ex_i;
    reg [WIDTH_VAR_STATES-1 : 0]     ram_din_vs_ex_i;
    reg [ADDR_WIDTH_VAR_STATES-1:0]  ram_addr_vs_ex_i;
    reg                              ram_we_ls_ex_i;
    reg [WIDTH_LVL_STATES-1 : 0]     ram_din_ls_ex_i;
    reg [ADDR_WIDTH_LVL_STATES-1:0]  ram_addr_ls_ex_i;

    sat_bin #(
        .NUM_CLAUSES_A_BIN    (NUM_CLAUSES_A_BIN),
        .NUM_VARS_A_BIN       (NUM_VARS_A_BIN),
        .NUM_LVLS_A_BIN       (NUM_LVLS_A_BIN),
        .WIDTH_BIN_ID         (WIDTH_BIN_ID),
        .WIDTH_CLAUSES        (WIDTH_CLAUSES),
        .WIDTH_VAR            (WIDTH_VAR),
        .WIDTH_LVL            (WIDTH_LVL),
        .WIDTH_VAR_STATES     (WIDTH_VAR_STATES),
        .WIDTH_LVL_STATES     (WIDTH_LVL_STATES),
        .ADDR_WIDTH_CLAUSES   (ADDR_WIDTH_CLAUSES),
        .ADDR_WIDTH_VAR       (ADDR_WIDTH_VAR),
        .ADDR_WIDTH_VAR_STATES(ADDR_WIDTH_VAR_STATES),
        .ADDR_WIDTH_LVL_STATES(ADDR_WIDTH_LVL_STATES)
    )
    sat_bin(
        .clk             (clk),
        .rst             (rst & sb_rst),
        .start_i         (start_i),
        .done_o          (done_o),
        //结果
        .global_sat_o    (global_sat_o),
        .global_unsat_o  (global_unsat_o),
        //rd bin info
        .bin_info_en     (bin_info_en),
        .nv_all_i        (nv_all_i),
        .nb_all_i        (nb_all_i),
        //外部输入端口
        .apply_ex_i      (apply_ex_i),
        //vars bins
        .ram_we_v_ex_i   (ram_we_v_ex_i),
        .ram_din_v_ex_i  (ram_din_v_ex_i),
        .ram_addr_v_ex_i (ram_addr_v_ex_i),
        //clauses bins
        .ram_we_c_ex_i   (ram_we_c_ex_i),
        .ram_din_c_ex_i  (ram_din_c_ex_i),
        .ram_addr_c_ex_i (ram_addr_c_ex_i),
        //vars states
        .ram_we_vs_ex_i  (ram_we_vs_ex_i),
        .ram_din_vs_ex_i (ram_din_vs_ex_i),
        .ram_addr_vs_ex_i(ram_addr_vs_ex_i),
        //lvls states
        .ram_we_ls_ex_i  (ram_we_ls_ex_i),
        .ram_din_ls_ex_i (ram_din_ls_ex_i),
        .ram_addr_ls_ex_i(ram_addr_ls_ex_i)
    );

    //load
    int nb;
    int nv;
    int cmax;
    int vmax;
    int cbin[][];
    int vbin[];
    //update
    int bin_updated[][];
    //var state list:
    int value_updated[];
    int implied_updated[];
    int level_updated[];
    //lvl state list:
    int dcd_bin_updated[];
    int has_bkt_updated[];
    //ctrl
    int cur_bin_num_updated;
    int cur_lvl_updated;
    int base_lvl_updated;

    /*** load ***/
    `include "../tb/class_clause_array.sv";
    `include "../tb/class_vs_list.sv";
    `include "../tb/class_ls_list.sv";
    `include "../tb/sb_test_case1.sv"
    `include "../tb/sb_test_case2.sv"

    class_clause_data #(8) cdata = new();

    task wr_bram_bin();
        begin
            for (int i = 0; i < nb*cmax || i < nb*vmax; ++i)
            begin
                @ (posedge clk);
                if(i < nb*cmax) begin
                    //wr_clauses
                    cdata.set_lits(cbin[i]);
                    //$display("%1tns wr bram clause addr = %1d", $time/1000.0, i);
                    //cdata.display_lits();
                    ram_we_c_ex_i = 1;
                    cdata.get_clause(ram_din_c_ex_i);
                    ram_addr_c_ex_i = i+1;
                end
                if(i < nb*vmax) begin
                    //vars
                    ram_we_v_ex_i = 1;
                    ram_din_v_ex_i = vbin[i];
                    ram_addr_v_ex_i = i+1;
                    //var_state
                    ram_we_vs_ex_i = 1;
                    ram_din_vs_ex_i = 0;
                    ram_addr_vs_ex_i = i+1;
                    //lvl_state
                    ram_we_ls_ex_i = 1;
                    ram_din_ls_ex_i = 0;
                    ram_addr_ls_ex_i = i+1;
                end
            end
            @ (posedge clk);
                ram_we_c_ex_i = 0;
                ram_we_v_ex_i = 0;
                ram_we_vs_ex_i = 0;
                ram_we_ls_ex_i = 0;
            @ (posedge clk);
                //$display("%1tns bram clause", $time/1000.0);
                //sat_bin.bin_manager.bram_clauses_bins_inst.display(1, nb*cmax+1);
        end
    endtask

    task reset_all_signal();
        begin
            start_i             = 0;
            bin_info_en         = 0;
            nb_all_i            = 0;
            nv_all_i            = 0;
            apply_ex_i          = 0;
            ram_addr_c_ex_i     = 0;
            ram_addr_ls_ex_i    = 0;
            ram_addr_v_ex_i     = 0;
            ram_addr_vs_ex_i    = 0;
            ram_din_c_ex_i      = 0;
            ram_din_ls_ex_i     = 0;
            ram_din_v_ex_i      = 0;
            ram_din_vs_ex_i     = 0;
            ram_we_c_ex_i       = 0;
            ram_we_ls_ex_i      = 0;
            ram_we_v_ex_i       = 0;
            ram_we_vs_ex_i      = 0;
        end
    endtask

    /*** 测试用例集 ***/

    task test_sat_bin_task();
        $display("%1tns test_sat_bin_task", $time/1000.0);

        //test_case1
        sb_rst = 0;
        @(posedge clk);
        sb_rst = 1;

        $display("%1tns ###############################################", $time/1000.0);
        $display("%1tns test_case 1", $time/1000.0);
        reset_all_signal();
        sb_test_case1();
        while(done_o!=1)
            @ (posedge clk);
        repeat (10) @(posedge clk);

        //test_case2
        sb_rst = 0;
        @(posedge clk);
        sb_rst = 1;
        $display("%1tns ###############################################", $time/1000.0);
        $display("%1tns test_case 2", $time/1000.0);
        reset_all_signal();
        sb_test_case2();
        while(done_o!=1)
            @ (posedge clk);
        repeat (10) @(posedge clk);
    endtask

    task run_sb_load();
        @(posedge clk);
            apply_ex_i = 1;
            wr_bram_bin();
            apply_ex_i = 0;
        @(posedge clk);
            start_i     = 1;
            bin_info_en = 1;
            nb_all_i    = nb;
            nv_all_i    = nv;
        @(posedge clk);
            start_i     = 0;
            bin_info_en = 0;
    endtask

endmodule


module test_sat_bin_top;
    reg  clk;
    reg  rst;

    always #5 clk<=~clk;

    initial begin: init
        clk = 0;
        rst=0;
    end

    // initial begin
    //  $fsdbDumpfile("wave_test_sat_engine.fsdb");
    //  $fsdbDumpvars;
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

    test_sat_bin test_sat_bin(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        reset();
        $display("start sim");
        test_sat_bin.run();
        $display("done sim");
        $finish();
    end
endmodule
