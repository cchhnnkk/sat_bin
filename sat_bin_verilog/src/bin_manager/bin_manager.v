/**
*  Bin_Manager的顶层模块
*/

`include "../src/debug_define.v"

module bin_manager #(
        parameter NUM_CLAUSES_A_BIN      = 8,
        parameter NUM_VARS_A_BIN         = 8,
        parameter NUM_LVLS_A_BIN         = 8,
        parameter WIDTH_BIN_ID           = 10,
        parameter WIDTH_CLAUSES          = NUM_VARS_A_BIN*2,
        parameter WIDTH_VAR              = 12,
        parameter WIDTH_LVL              = 16,
        parameter WIDTH_VAR_STATES       = 19,
        parameter WIDTH_LVL_STATES       = 11,
        parameter ADDR_WIDTH_CLAUSES     = 10,
        parameter ADDR_WIDTH_VAR         = 10,
        parameter ADDR_WIDTH_VAR_STATES  = 10,
        parameter ADDR_WIDTH_LVL_STATES  = 10
    )
    (
        input                     clk,
        input                     rst,

        input                     start_bm_i,
        output                    done_bm_o,

        //结果
        output                    global_sat_o,
        output                    global_unsat_o,

        //rd bin info
        input                     bin_info_en,
        input [WIDTH_VAR-1:0]     nv_all_i,
        input [WIDTH_CLAUSES-1:0] nb_all_i,

        //sat engine core
        output                                       start_core_o,
        input                                        done_core_i,

        output [WIDTH_BIN_ID-1:0]                    cur_bin_num_o,
        output [WIDTH_LVL-1:0]                       cur_lvl_o,
        input                                        local_sat_i,
        input                                        local_unsat_i,
        input [WIDTH_LVL-1:0]                        cur_lvl_from_core_i,
        input [WIDTH_BIN_ID-1:0]                     bkt_bin_from_core_i,
        input [WIDTH_LVL-1:0]                        bkt_lvl_from_core_i,

        //load update clause with sat engine
        output [NUM_CLAUSES_A_BIN-1:0]               wr_carray_o,
        output [NUM_CLAUSES_A_BIN-1:0]               rd_carray_o,
        output [NUM_VARS_A_BIN*2-1 : 0]              clause_o,
        input [NUM_VARS_A_BIN*2-1 : 0]               clause_i,

        //load update var states with sat engine
        output [NUM_VARS_A_BIN-1:0]                  wr_var_states_o,
        output [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0] var_states_o,
        input [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0]  var_states_i,

        //load update lvl states with sat engine
        output [NUM_LVLS_A_BIN-1:0]                  wr_lvl_states_o,
        output [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0] lvl_states_o,
        input [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0]  lvl_states_i,
        output                                       base_lvl_en,
        output [WIDTH_LVL-1:0]                       base_lvl_o,

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

    //实例化
    //ctrl_bm
    wire                       start_rdinfo;
    wire                       done_rdinfo;
    wire                       done_load;
    wire                       start_load;
    wire [WIDTH_BIN_ID-1:0]    request_bin_num;
    wire                       start_find;
    wire                       done_find;
    wire [WIDTH_BIN_ID-1:0]    bkt_bin_find;
    wire                       start_bkt_across_bin;
    wire                       done_bkt_across_bin;
    wire                       start_update;
    wire                       done_update;
    wire [WIDTH_LVL-1:0]       bkt_lvl_find;
    wire [WIDTH_VAR-1:0]       nv_all;
    wire [WIDTH_CLAUSES-1:0]   nb_all;
    wire [WIDTH_BIN_ID-1:0]    update_bin_num;

    ctrl_bm #(
        .WIDTH_BIN_ID(WIDTH_BIN_ID),
        .WIDTH_CLAUSES(WIDTH_CLAUSES),
        .WIDTH_LVL(WIDTH_LVL)
    )
    ctrl_bm(
        .clk                   (clk),
        .rst                   (rst),
        .start_bm_i            (start_bm_i),
        .done_bm_o             (done_bm_o),
         //当前状态
        .cur_bin_num_o         (cur_bin_num_o),
        .cur_lvl_o             (cur_lvl_o),
        .global_sat_o          (global_sat_o),
        .global_unsat_o        (global_unsat_o),
         //读取基本信息
        .done_rdinfo_i         (done_rdinfo),
        .nb_all_i              (nb_all),
        .start_rdinfo_o        (start_rdinfo),
         //load bin
        .done_load_i           (done_load),
        .start_load_o          (start_load),
        .request_bin_num_o     (request_bin_num),
         //sat_engine core
        .start_core_o          (start_core_o),
        .done_core_i           (done_core_i),
        .local_sat_i           (local_sat_i),
        .cur_lvl_from_core_i   (cur_lvl_from_core_i),
        .bkt_bin_from_core_i   (bkt_bin_from_core_i),
         //find_global_bkt_lvl
        .start_find_o          (start_find),
        .done_find_i           (done_find),
        .bkt_bin_from_find_i   (bkt_bin_find),
        .bkt_lvl_from_find_i   (bkt_lvl_find),
         //bkt_across_bin
        .start_bkt_across_bin_o(start_bkt_across_bin),
        .done_bkt_across_bin_i (done_bkt_across_bin),
         //update bin
        .start_update_o        (start_update),
        .update_bin_num_o      (update_bin_num),
        .done_update_i         (done_update)
    );

    //rd_bin_info

    rd_bin_info #(
        .WIDTH_CLAUSES(WIDTH_CLAUSES),
        .WIDTH_VARS(WIDTH_VAR)
        )
    rd_bin_info(
        .clk           (clk),
        .rst           (rst),
        .start_rdinfo_i(start_rdinfo),
        .done_rdinfo_o (done_rdinfo),
        .data_en       (bin_info_en),
        .nv_all_i      (nv_all_i),
        .nb_all_i      (nb_all_i),
        .nv_all_o      (nv_all),
        .nb_all_o      (nb_all)
    );
 

    //load_bin
    wire                       apply_load;
    wire [WIDTH_CLAUSES-1 : 0]               ram_douta_c;
    wire [ADDR_WIDTH_CLAUSES-1:0]            ram_addr_c_from_load;
    wire [WIDTH_VAR-1 : 0]                   ram_douta_v;
    wire [ADDR_WIDTH_VAR-1:0]                ram_addr_v_from_load;
    wire [WIDTH_VAR_STATES-1 : 0]            ram_douta_vs;
    wire [ADDR_WIDTH_VAR_STATES-1:0]         ram_addr_vs_from_load;
    wire [WIDTH_LVL_STATES-1 : 0]            ram_douta_ls;
    wire [ADDR_WIDTH_LVL_STATES-1:0]         ram_addr_ls_from_load;

    load_bin #(
        .NUM_CLAUSES_A_BIN    (NUM_CLAUSES_A_BIN),
        .NUM_VARS_A_BIN       (NUM_VARS_A_BIN),
        .NUM_LVLS_A_BIN       (NUM_LVLS_A_BIN),
        .WIDTH_CLAUSES        (WIDTH_CLAUSES),
        .WIDTH_VAR            (WIDTH_VAR),
        .WIDTH_LVL            (WIDTH_LVL),
        .WIDTH_BIN_ID         (WIDTH_BIN_ID),
        .WIDTH_VAR_STATES     (WIDTH_VAR_STATES),
        .ADDR_WIDTH_CLAUSES   (ADDR_WIDTH_CLAUSES),
        .ADDR_WIDTH_VAR       (ADDR_WIDTH_VAR),
        .ADDR_WIDTH_VAR_STATES(ADDR_WIDTH_VAR_STATES),
        .ADDR_WIDTH_LVL_STATES(ADDR_WIDTH_LVL_STATES)
    )
    load_bin(
        .clk              (clk),
        .rst              (rst),
        .start_load       (start_load),
        .request_bin_num_i(request_bin_num),
        .apply_load_o     (apply_load),
        .done_load        (done_load),
        .wr_carray_o      (wr_carray_o),
        .clause_o         (clause_o),
        .wr_var_states_o  (wr_var_states_o),
        .var_states_o    (var_states_o),
        .wr_lvl_states_o  (wr_lvl_states_o),
        .lvl_states_o     (lvl_states_o),
        .cur_lvl_i        (cur_lvl_o),
        .base_lvl_o       (base_lvl_o),
        .base_lvl_en      (base_lvl_en),
        .ram_data_c_i     (ram_douta_c),
        .ram_addr_c_o     (ram_addr_c_from_load),
        .ram_data_v_i     (ram_douta_v),
        .ram_addr_v_o     (ram_addr_v_from_load),
        .ram_data_vs_i    (ram_douta_vs),
        .ram_addr_vs_o    (ram_addr_vs_from_load),
        .ram_data_ls_i    (ram_douta_ls),
        .ram_addr_ls_o    (ram_addr_ls_from_load)
    );


    // find_global_bkt_lvl
    wire                                    apply_find;
    //rd
    wire [ADDR_WIDTH_LVL_STATES-1:0]        ram_raddr_ls_from_find;
    //wr
    wire                                    ram_we_ls_from_find;
    wire [WIDTH_LVL_STATES-1 : 0]           ram_wdata_ls_from_find;
    wire [ADDR_WIDTH_LVL_STATES-1:0]        ram_waddr_ls_from_find;

    find_global_bkt_lvl #(
        .WIDTH_LVL             (WIDTH_LVL),
        .WIDTH_BIN_ID          (WIDTH_BIN_ID),
        .WIDTH_LVL_STATES      (WIDTH_LVL_STATES),
        .ADDR_WIDTH_LVL_STATES(ADDR_WIDTH_LVL_STATES)
    )
    find_global_bkt_lvl(
        .clk           (clk),
        .rst           (rst),
        //control
        .start_find    (start_find),
        .apply_find_o  (apply_find),
        .done_find     (done_find),
        .bkt_lvl_i     (bkt_lvl_from_core_i),
        .bkt_lvl_o     (bkt_lvl_find),
        .bkt_bin_o     (bkt_bin_find),
        //lvls states bram
        //rd
        .ram_raddr_ls_o(ram_raddr_ls_from_find),
        .ram_rdata_ls_i(ram_douta_ls),
        //wr
        .ram_we_ls_o   (ram_we_ls_from_find),
        .ram_wdata_ls_o(ram_wdata_ls_from_find),
        .ram_waddr_ls_o(ram_waddr_ls_from_find)
    );


    // bkt_across_bin
    wire                             apply_bkt_across_bin;
    wire [ADDR_WIDTH_VAR_STATES-1:0] ram_raddr_vs_from_bkt;
    wire                             ram_we_vs_from_bkt;
    wire [WIDTH_VAR_STATES-1 : 0]    ram_wdata_vs_from_bkt;
    wire [ADDR_WIDTH_VAR_STATES-1:0] ram_waddr_vs_from_bkt;

    bkt_across_bin #(
        .WIDTH_VAR             (WIDTH_VAR),
        .WIDTH_LVL             (WIDTH_LVL),
        .WIDTH_VAR_STATES      (WIDTH_VAR_STATES),
        .ADDR_WIDTH_VAR_STATES(ADDR_WIDTH_VAR_STATES),
        .ADDR_WIDTH_LVL_STATES(ADDR_WIDTH_LVL_STATES)
    )
    bkt_across_bin(
        .clk           (clk),
        .rst           (rst),
        //control
        .start_bkt_i   (start_bkt_across_bin),
        .apply_bkt_o   (apply_bkt_across_bin),
        .done_bkt_o    (done_bkt_across_bin),
        .nv_all_i      (nv_all),
        .bkt_lvl_i     (bkt_lvl_find),
        .bkt_bin_i     (bkt_bin_find),
        //vars states
        //rd
        .ram_raddr_vs_o(ram_raddr_vs_from_bkt),
        .ram_rdata_vs_i(ram_douta_vs),
        //wr
        .ram_we_vs_o   (ram_we_vs_from_bkt),
        .ram_wdata_vs_o(ram_wdata_vs_from_bkt),
        .ram_waddr_vs_o(ram_waddr_vs_from_bkt)
    );


    // update_bin
    wire                                     apply_update;
    wire                                     ram_we_c_from_update;
    wire [WIDTH_CLAUSES-1:0]                 ram_data_c_from_update;
    wire [ADDR_WIDTH_CLAUSES-1:0]            ram_addr_c_from_update;
    wire [ADDR_WIDTH_VAR-1:0]                ram_addr_v_from_update;
    wire                                     ram_we_vs_from_update;
    wire [WIDTH_VAR_STATES-1 : 0]            ram_data_vs_from_update;
    wire [ADDR_WIDTH_VAR_STATES-1:0]        ram_addr_vs_from_update;
    wire                                     ram_we_ls_from_update;
    wire [WIDTH_LVL_STATES-1 : 0]            ram_data_ls_from_update;
    wire [ADDR_WIDTH_VAR_STATES-1:0]        ram_addr_ls_from_update;

    update_bin #(
        .NUM_CLAUSES_A_BIN     (NUM_CLAUSES_A_BIN),
        .NUM_VARS_A_BIN        (NUM_VARS_A_BIN),
        .NUM_LVLS_A_BIN        (NUM_LVLS_A_BIN),
        .WIDTH_CLAUSES         (WIDTH_CLAUSES),
        .WIDTH_VAR             (WIDTH_VAR),
        .WIDTH_LVL             (WIDTH_LVL),
        .WIDTH_BIN_ID          (WIDTH_BIN_ID),
        .WIDTH_VAR_STATES      (WIDTH_VAR_STATES),
        .WIDTH_LVL_STATES      (WIDTH_LVL_STATES),
        .ADDR_WIDTH_CLAUSES    (ADDR_WIDTH_CLAUSES),
        .ADDR_WIDTH_VAR        (ADDR_WIDTH_VAR),
        .ADDR_WIDTH_VAR_STATES(ADDR_WIDTH_VAR_STATES),
        .ADDR_WIDTH_LVL_STATES(ADDR_WIDTH_LVL_STATES)
    )
    update_bin(
        .clk           (clk),
        .rst           (rst),
        //update control
        .start_update  (start_update),
        .update_bin_num_i (update_bin_num),
        .local_sat_i   (local_sat_i),
        .apply_update_o(apply_update),
        .done_update   (done_update),
        //update from sat engine
        .rd_carray_o   (rd_carray_o),
        .clause_i      (clause_i),
        .var_state_i   (var_states_i),
        .lvl_states_i  (lvl_states_i),
        .base_lvl_i    (base_lvl_o),
        //clauses bins
        .ram_we_c_o    (ram_we_c_from_update),
        .ram_data_c_o  (ram_data_c_from_update),
        .ram_addr_c_o  (ram_addr_c_from_update),
        //vars bins
        .ram_data_v_i  (ram_douta_v),
        .ram_addr_v_o  (ram_addr_v_from_update),
        //vars states
        .ram_we_vs_o   (ram_we_vs_from_update),
        .ram_data_vs_o (ram_data_vs_from_update),
        .ram_addr_vs_o (ram_addr_vs_from_update),
        //lvls states
        .ram_we_ls_o   (ram_we_ls_from_update),
        .ram_data_ls_o (ram_data_ls_from_update),
        .ram_addr_ls_o (ram_addr_ls_from_update)
    );


    /*** bram 变量 **/
    //bram端口复用
    reg [ADDR_WIDTH_VAR-1:0]            ram_addra_v_w;
    reg                                 ram_web_v_w;
    reg [ADDR_WIDTH_CLAUSES-1:0]        ram_addrb_v_w;
    reg [WIDTH_VAR-1:0]                 ram_dinb_v_w;
    always @(posedge clk)
    begin
        if(~rst)
            ram_addra_v_w <= 0;
        else if(apply_load)     //加载
            ram_addra_v_w <= ram_addr_v_from_load;
        else if(apply_update)
            ram_addra_v_w <= ram_addr_v_from_update;
        else
            ram_addra_v_w <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst) begin
            ram_web_v_w <= 0;
            ram_dinb_v_w <= 0;
            ram_addrb_v_w <= 0;
        end
        else if(apply_ex_i) begin   //外部输入
            ram_web_v_w <= ram_we_v_ex_i;
            ram_dinb_v_w <= ram_din_v_ex_i;
            ram_addrb_v_w <= ram_addr_v_ex_i;
        end
        else begin
            ram_web_v_w <= 0;
            ram_dinb_v_w <= 0;
            ram_addrb_v_w <= 0;
        end
    end

    bram_param #(
        .DATA_WIDTH(WIDTH_VAR),
        .ADDR_WIDTH(ADDR_WIDTH_VAR)
    )
    bram_vars_bins_inst(
        .clka(clk),
        .wea(),
        .addra(ram_addra_v_w),
        .dina(),
        .douta(ram_douta_v),
        .clkb(clk),
        .web(ram_web_v_w),
        .addrb(ram_addrb_v_w),
        .dinb(ram_dinb_v_w),
        .doutb()
    );

    /*** bram 子句 **/
    //bram端口复用
    reg [ADDR_WIDTH_CLAUSES-1:0]        ram_addra_c_w;
    reg                                 ram_web_c_w;
    reg [ADDR_WIDTH_CLAUSES-1:0]        ram_addrb_c_w;
    reg [WIDTH_CLAUSES-1:0]             ram_dinb_c_w;

    always @(*)
    begin
        if(~rst)
            ram_addra_c_w = 0;
        else if(apply_load)     //加载
            ram_addra_c_w = ram_addr_c_from_load;
        else
            ram_addra_c_w = 0;
    end

    always @(*)
    begin
        if(~rst) begin
            ram_web_c_w = 0;
            ram_dinb_c_w = 0;
            ram_addrb_c_w = 0;
        end
        else if(apply_update) begin     //更新
            ram_web_c_w = 1;
            ram_dinb_c_w = ram_data_c_from_update;
            ram_addrb_c_w = ram_addr_c_from_update;
        end
        else if(apply_ex_i) begin   //外部输入
            ram_web_c_w = ram_we_c_ex_i;
            ram_dinb_c_w = ram_din_c_ex_i;
            ram_addrb_c_w = ram_addr_c_ex_i;
        end
        else begin
            ram_web_c_w = 0;
            ram_dinb_c_w = 0;
            ram_addrb_c_w = 0;
        end
    end

    bram_param #(
        .DATA_WIDTH(WIDTH_CLAUSES),
        .ADDR_WIDTH(ADDR_WIDTH_CLAUSES)
    )
    bram_clauses_bins_inst(
        .clka(clk),
        .wea(),
        .addra(ram_addra_c_w),
        .dina(),
        .douta(ram_douta_c),
        .clkb(clk),
        .web(ram_web_c_w),
        .addrb(ram_addrb_c_w),
        .dinb(ram_dinb_c_w),
        .doutb()
    );

    /*** bram 变量状态 **/
    //bram端口复用
    reg [ADDR_WIDTH_VAR_STATES-1:0]    ram_addra_vs_w;
    reg                                 ram_web_vs_w;
    reg [WIDTH_VAR_STATES-1:0]          ram_dinb_vs_w;
    reg [ADDR_WIDTH_VAR_STATES-1:0]     ram_addrb_vs_w;

    always @(*)
    begin
        if(~rst)
            ram_addra_vs_w = 0;
        else if(apply_load)     //加载
            ram_addra_vs_w = ram_addr_vs_from_load;
        else if(apply_bkt_across_bin)
            ram_addra_vs_w = ram_raddr_vs_from_bkt;
        else
            ram_addra_vs_w = 0;
    end

    always @(*)
    begin
        if(~rst) begin
            ram_web_vs_w = 0;
            ram_dinb_vs_w = 0;
            ram_addrb_vs_w = 0;
        end
        else if(apply_update) begin     //更新
            ram_web_vs_w = 1;
            ram_dinb_vs_w = ram_data_vs_from_update;
            ram_addrb_vs_w = ram_addr_vs_from_update;
        end
        else if(apply_bkt_across_bin) begin
            ram_web_vs_w = 1;
            ram_dinb_vs_w = ram_wdata_vs_from_bkt;
            ram_addrb_vs_w = ram_waddr_vs_from_bkt;
        end
        else if(apply_ex_i) begin   //外部输入
            ram_web_vs_w = ram_we_vs_ex_i;
            ram_dinb_vs_w = ram_din_vs_ex_i;
            ram_addrb_vs_w = ram_addr_vs_ex_i;
        end
        else begin
            ram_web_vs_w = 0;
            ram_dinb_vs_w = 0;
            ram_addrb_vs_w = 0;
        end
    end

    bram_param #(
        .DATA_WIDTH(WIDTH_VAR_STATES),
        .ADDR_WIDTH(ADDR_WIDTH_VAR_STATES)
    )
    bram_global_var_state_inst(
        .clka(clk),
        .wea(),
        .addra(ram_addra_vs_w),
        .dina(),
        .douta(ram_douta_vs),
        .clkb(clk),
        .web(ram_web_vs_w),
        .addrb(ram_addrb_vs_w),
        .dinb(ram_dinb_vs_w),
        .doutb()
    );


    /*** bram 层级状态 **/
    //bram端口复用
    reg [ADDR_WIDTH_LVL_STATES-1:0]     ram_addra_ls_w;
    reg                                 ram_web_ls_w;
    reg [WIDTH_LVL_STATES-1:0]          ram_dinb_ls_w;
    reg [ADDR_WIDTH_LVL_STATES-1:0]     ram_addrb_ls_w;

    always @(*)
    begin
        if(~rst)
            ram_addra_ls_w = 0;
        else if(apply_load)     //加载
            ram_addra_ls_w = ram_addr_ls_from_load;
        else if(apply_find)
            ram_addra_ls_w = ram_raddr_ls_from_find;
        else
            ram_addra_ls_w = 0;
    end

    always @(*)
    begin
        if(~rst) begin
            ram_web_ls_w = 0;
            ram_dinb_ls_w = 0;
            ram_addrb_ls_w = 0;
        end
        else if(apply_update) begin     //更新
            ram_web_ls_w = ram_we_ls_from_update;
            ram_dinb_ls_w = ram_data_ls_from_update;
            ram_addrb_ls_w = ram_addr_ls_from_update;
        end
        else if(apply_find) begin
            ram_web_ls_w = ram_we_ls_from_find;
            ram_dinb_ls_w = ram_wdata_ls_from_find;
            ram_addrb_ls_w = ram_waddr_ls_from_find;
        end
        else if(apply_ex_i) begin   //外部输入
            ram_web_ls_w = ram_we_ls_ex_i;
            ram_dinb_ls_w = ram_din_ls_ex_i;
            ram_addrb_ls_w = ram_addr_ls_ex_i;
        end
        else begin
            ram_web_ls_w = 0;
            ram_dinb_ls_w = 0;
            ram_addrb_ls_w = 0;
        end
    end

    bram_param #(
        .DATA_WIDTH(WIDTH_LVL_STATES),
        .ADDR_WIDTH(ADDR_WIDTH_LVL_STATES)
    )
    bram_global_lvl_state_inst(
        .clka(clk),
        .wea(),
        .addra(ram_addra_ls_w),
        .dina(),
        .douta(ram_douta_ls),
        .clkb(clk),
        .web(ram_web_ls_w),
        .addrb(ram_addrb_ls_w),
        .dinb(ram_dinb_ls_w),
        .doutb()
    );

/**
*  输出调试的信息
*/
`ifdef DEBUG_bin_manager
    reg [1023:0] sum_bkt, sum_bkt_next;
    int i=0;

    always @(posedge clk) begin
        if(~rst) begin
            sum_bkt = 0;
            sum_bkt_next = 0;
        end
        else if(done_bkt_across_bin) begin
            sum_bkt_next = 1;
            for(i=0; i<nv_all; i++) begin
                if(i<bkt_lvl_find)
                    sum_bkt_next = (sum_bkt_next<<1) + bram_global_lvl_state_inst.data[i+1][0];
                else
                    sum_bkt_next = sum_bkt_next<<1;
            end
            display_sum_bkt();
            assert(sum_bkt_next > sum_bkt)
            else begin
                $display("%1tns error assert(sum_bkt_next > sum_bkt)", $time/1000);
                $finish();
            end
            sum_bkt = sum_bkt_next;
        end
    end

    string str, str_dcd, str_bkt;

    reg [WIDTH_BIN_ID-1:0] dcd_bin;
    reg                    has_bkt;

    task display_sum_bkt();
        str = "";
        str_dcd = "";
        str_bkt = "";
        $display("%1tns sum_bkt %1b", $time/1000, sum_bkt_next);
        str_dcd = "\tdcd_bin";
        str_bkt = "\thas_bkt";
        for(i=0; i<nv_all; i++) begin
            if(i<bkt_lvl_find) begin
                {dcd_bin, has_bkt} = bram_global_lvl_state_inst.data[i+1];
                $sformat(str," %4d", dcd_bin);     str_dcd = {str_dcd, str};
                $sformat(str," %4d", has_bkt);     str_bkt = {str_bkt, str};
            end
        end
        $display(str_dcd);
        $display(str_bkt);
    endtask

    always @(posedge clk) begin
        if(done_rdinfo) begin
            $display("%1tns nv_all=%1d nb_all=%1d", $time/1000, nv_all, nb_all);
        end
    end

    `include "../tb/class_clause_array.sv";
    `include "../tb/class_vs_list.sv";
    `include "../tb/class_ls_list.sv";
    class_clause_data #(8) cdata = new();
    class_vs_list #(8, WIDTH_LVL) vs_list = new();
    class_ls_list #(8, WIDTH_BIN_ID) ls_list = new();

    always @(posedge clk) begin
        if(done_load) begin
            $display("%1tns done_load_cbin = %1d", $time/1000, cur_bin_num_o);
            for(i=0; i<8; i++) begin
                cdata.set_clause(bram_clauses_bins_inst.data[i+1+(cur_bin_num_o-1)*8]);
                cdata.display_lits();
            end
            $display("%1tns done_load_vs = %1d", $time/1000, cur_bin_num_o);
            vs_list.set(var_states_i);
            vs_list.display();
            $display("%1tns done_load_ls = %1d", $time/1000, cur_bin_num_o);
            ls_list.set(lvl_states_i);
            ls_list.display();
            $display("%1tns base_lvl_o = %1d", $time/1000, base_lvl_o);
            $display("%1tns cur_lvl_o = %1d", $time/1000, cur_lvl_o);
        end
    end

    always @(posedge clk) begin
        if(done_update) begin
            $display("%1tns done_update_cbin = %1d", $time/1000, update_bin_num);
            for(i=0; i<8; i++) begin
                cdata.set_clause(bram_clauses_bins_inst.data[i+1+(update_bin_num-1)*8]);
                cdata.display_lits();
            end
            if(local_sat_i) begin
                $display("%1tns done_update_vs = %1d", $time/1000, update_bin_num);
                vs_list.set(var_states_i);
                vs_list.display();
                $display("%1tns done_update_ls = %1d", $time/1000, update_bin_num);
                ls_list.set(lvl_states_i);
                ls_list.display();
                $display("%1tns base_lvl_o = %1d", $time/1000, base_lvl_o);
                $display("%1tns cur_lvl_o = %1d", $time/1000, cur_lvl_o);
            end
            display_bram();
        end
    end

    task display_bram();
        //$display("%1tns bram_clause", $time/1000.0);
        //bram_clauses_bins_inst.display(1, nb_all*8+1);
        //$display("%1tns bram_var", $time/1000.0);
        //bram_vars_bins_inst.display(1, nb_all*8+1);
        $display("%1tns bram_vs", $time/1000.0);
        bram_global_var_state_inst.display_vs(1, nv_all+1);
        $display("%1tns bram_ls", $time/1000.0);
        bram_global_lvl_state_inst.display_ls(1, nv_all+1);
    endtask

    /*
    always @(*) begin
        $display("%1tns bin_manager", $time/1000);
        $display("\t apply_find = %1d", apply_find);
        $display("\t ram_addra_ls_w = %1d", ram_addra_ls_w);
        $display("\t ram_douta_ls = %b", ram_douta_ls);
        $display("\t ram_raddr_ls_from_find = %1d", ram_raddr_ls_from_find);
    end
    */

    always @(posedge clk) begin
        if(done_find) begin
            $display("%1tns done_find", $time/1000);
            $display("\t bkt_bin_find = %1d, bkt_lvl_find = %1d", bkt_bin_find, bkt_lvl_find);
            //$display("%1tns bram_ls", $time/1000.0);
            //bram_global_lvl_state_inst.display(1, nv_all+1);
        end
    end

`endif


`ifdef DEBUG_bkt_across_bin
    reg [2:0] vs_value;
    reg [WIDTH_LVL-1:0] vs_lvl;

    always @(posedge clk) begin
        if(done_bkt_across_bin) begin
            $display("%1tns done_bkt_across_bin", $time/1000);
            disp_bkt();
        end
        if(start_bkt_across_bin) begin
            $display("%1tns start_bkt_across_bin", $time/1000);
            disp_bkt();
        end
    end

    task disp_bkt();
        $display("%1tns bram_vs", $time/1000.0);
        $display("\t%8s : %8s %8s", "addr", "vs_value", "vs_lvl");
        for(i=0; i<nv_all; i++) begin
            {vs_value, vs_lvl} = bram_global_var_state_inst.data[i+1];
            $display("\t%8d : %8b %8d", i+1, vs_value, vs_lvl);
        end
    endtask
`endif

endmodule
