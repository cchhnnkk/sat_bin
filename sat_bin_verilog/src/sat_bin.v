/**
*  Bin_Manager的顶层模块
*/

`include "../src/debug_define.v"

module sat_bin #(
        parameter NUM_CLAUSES_A_BIN      = 8,
        parameter NUM_VARS_A_BIN         = 8,
        parameter NUM_LVLS_A_BIN         = 8,
        parameter WIDTH_BIN_ID           = 10,
        parameter WIDTH_CLAUSES          = NUM_VARS_A_BIN*2,
        parameter WIDTH_VAR              = 12,
        parameter WIDTH_LVL              = 16,
        parameter WIDTH_VAR_STATES       = 19,
        parameter WIDTH_LVL_STATES       = 11,
        parameter WIDTH_C_LEN            = 4,
        parameter ADDR_WIDTH_CLAUSES     = 10,
        parameter ADDR_WIDTH_VAR         = 10,
        parameter ADDR_WIDTH_VAR_STATES  = 10,
        parameter ADDR_WIDTH_LVL_STATES  = 10
    )
    (
        input           clk,
        input           rst,

        input           start_i,
        output          done_o,

        //结果
        output          global_sat_o,
        output          global_unsat_o,

        //rd bin info
        input                     bin_info_en,
        input [WIDTH_VAR-1:0]     nv_all_i,
        input [WIDTH_CLAUSES-1:0] nb_all_i,

        //外部输入端口
        input                              apply_ex_i,
        //vars bins
        input                              ram_we_v_ex_i,
        input [WIDTH_VAR-1 : 0]            ram_din_v_ex_i,
        input [ADDR_WIDTH_VAR-1:0]         ram_addr_v_ex_i,
        //clauses bins
        input                              ram_we_c_ex_i,
        input [WIDTH_CLAUSES-1 : 0]        ram_din_c_ex_i,
        input [ADDR_WIDTH_CLAUSES-1:0]     ram_addr_c_ex_i,
        //vars states
        input                              ram_we_vs_ex_i,
        input [WIDTH_VAR_STATES-1 : 0]     ram_din_vs_ex_i,
        input [ADDR_WIDTH_VAR_STATES-1:0]  ram_addr_vs_ex_i,
        //lvls states
        input                              ram_we_ls_ex_i,
        input [WIDTH_LVL_STATES-1 : 0]     ram_din_ls_ex_i,
        input [ADDR_WIDTH_LVL_STATES-1:0]  ram_addr_ls_ex_i
    );

    wire                     start_bm;
    wire                     done_bm;
    wire                                       start_core;
    wire                                       done_core;
    wire [WIDTH_BIN_ID-1:0]                    cur_bin_num;
    wire [WIDTH_LVL-1:0]                       load_lvl;
    wire                                       local_sat;
    wire                                       local_unsat;
    wire [WIDTH_LVL-1:0]                       cur_lvl_from_core;
    wire [WIDTH_BIN_ID-1:0]                    bkt_bin_from_core;
    wire [WIDTH_LVL-1:0]                       bkt_lvl_from_core;
    wire [NUM_CLAUSES_A_BIN-1:0]               wr_carray_from_bm;
    wire [NUM_CLAUSES_A_BIN-1:0]               rd_carray_from_bm;
    wire [NUM_VARS_A_BIN*2-1 : 0]              clause_from_bm;
    wire [NUM_VARS_A_BIN*2-1 : 0]              clause_from_core;
    wire [NUM_VARS_A_BIN-1:0]                  wr_var_states_from_bm;
    wire [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0] var_states_from_bm;
    wire [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0] var_states_from_core;
    wire [NUM_LVLS_A_BIN-1:0]                  wr_lvl_states_from_bm;
    wire [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0] lvl_states_from_bm;
    wire [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0] lvl_states_from_core;
    wire                                       base_lvl_en;
    wire [WIDTH_LVL-1:0]                       base_lvl;

	assign start_bm = start_i;
	assign done_o = done_bm;

    bin_manager #(
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
    bin_manager(
        .clk                (clk),
        .rst                (rst),
        .start_bm_i         (start_bm),
        .done_bm_o          (done_bm),
        //结果
        .global_sat_o       (global_sat_o),
        .global_unsat_o     (global_unsat_o),
        //rd bin info
        .bin_info_en        (bin_info_en),
        .nv_all_i           (nv_all_i),
        .nb_all_i           (nb_all_i),
        //sat engine core
        .start_core_o       (start_core),
        .done_core_i        (done_core),
        .cur_bin_num_o      (cur_bin_num),
        .cur_lvl_o          (load_lvl),
        .local_sat_i        (local_sat),
        .local_unsat_i      (local_unsat),
        .cur_lvl_from_core_i(cur_lvl_from_core),
        .bkt_bin_from_core_i(bkt_bin_from_core),
        .bkt_lvl_from_core_i(bkt_lvl_from_core),
        //load update clause with sat engine
        .wr_carray_o        (wr_carray_from_bm),
        .rd_carray_o        (rd_carray_from_bm),
        .clause_o           (clause_from_bm),
        .clause_i           (clause_from_core),
        //load update var states with sat engine
        .wr_var_states_o    (wr_var_states_from_bm),
        .var_states_o       (var_states_from_bm),
        .var_states_i       (var_states_from_core),
        //load update lvl states with sat engine
        .wr_lvl_states_o    (wr_lvl_states_from_bm),
        .lvl_states_o       (lvl_states_from_bm),
        .lvl_states_i       (lvl_states_from_core),
        .base_lvl_en        (base_lvl_en),
        .base_lvl_o         (base_lvl),
        //外部输入端口
        .apply_ex_i         (apply_ex_i),
        //vars bins
        .ram_we_v_ex_i      (ram_we_v_ex_i),
        .ram_din_v_ex_i     (ram_din_v_ex_i),
        .ram_addr_v_ex_i    (ram_addr_v_ex_i),
        //clauses bins
        .ram_we_c_ex_i      (ram_we_c_ex_i),
        .ram_din_c_ex_i     (ram_din_c_ex_i),
        .ram_addr_c_ex_i    (ram_addr_c_ex_i),
        //vars states
        .ram_we_vs_ex_i     (ram_we_vs_ex_i),
        .ram_din_vs_ex_i    (ram_din_vs_ex_i),
        .ram_addr_vs_ex_i   (ram_addr_vs_ex_i),
        //lvls states
        .ram_we_ls_ex_i     (ram_we_ls_ex_i),
        .ram_din_ls_ex_i    (ram_din_ls_ex_i),
        .ram_addr_ls_ex_i   (ram_addr_ls_ex_i)
    );


    sat_engine #(
        .NUM_CLAUSES     (NUM_CLAUSES_A_BIN),
        .NUM_VARS        (NUM_VARS_A_BIN),
        .NUM_LVLS        (NUM_LVLS_A_BIN),
        .WIDTH_BIN_ID    (WIDTH_BIN_ID),
        .WIDTH_C_LEN     (WIDTH_C_LEN),
        .WIDTH_LVL       (WIDTH_LVL),
        .WIDTH_LVL_STATES(WIDTH_LVL_STATES),
        .WIDTH_VAR_STATES(WIDTH_VAR_STATES)
    )
    sat_engine(
        .clk          (clk),
        .rst          (rst),
        // ctrl_core
        .start_core_i (start_core),
        .done_core_o  (done_core),
        .cur_bin_num_i(cur_bin_num),
        .cur_lvl_o    (cur_lvl_from_core),
        .sat_o        (local_sat),
        .unsat_o      (local_unsat),
        .bkt_lvl_o    (bkt_lvl_from_core),
        .bkt_bin_o    (bkt_bin_from_core),
        .load_lvl_i   (load_lvl),
        //load update clause
        .rd_carray_i  (rd_carray_from_bm),
        .clause_o     (clause_from_core),
        .wr_carray_i  (wr_carray_from_bm),
        .clause_i     (clause_from_bm),
        //load update var states
        .wr_var_states(wr_var_states_from_bm),
        .var_states_i (var_states_from_bm),
        .var_states_o (var_states_from_core),
        //load update lvl states
        .wr_lvl_states(wr_lvl_states_from_bm),
        .lvl_states_i (lvl_states_from_bm),
        .lvl_states_o (lvl_states_from_core),
        .base_lvl_en  (base_lvl_en),
        .base_lvl_i   (base_lvl)
    );

`ifdef DEBUG_sat_bin

    int tag=0;

    always @(posedge clk) begin
        if(~rst)
            tag = 0;
        else if(done_o && tag==0) begin
            tag = 1;
            $display("%1tns done_sat_bin", $time/1000);
            if(global_sat_o) begin
                $display("\tresult var value");
                bin_manager.bram_global_var_state_inst.display_var_value(1, bin_manager.nv_all+1);
            end
            $display("%1tns Debug cnt info", $time/1000);
            sat_engine.ctrl_core.display_cnt();
            bin_manager.ctrl_bm.display_cnt();
        end
    end

`endif


endmodule
