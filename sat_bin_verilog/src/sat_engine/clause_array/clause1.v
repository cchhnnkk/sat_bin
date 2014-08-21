
`include "../src/debug_define.v"

module clause1 #(
        parameter NUM_VARS    = 8,
        parameter NUM_CLAUSES = 1,
        parameter WIDTH_LVL   = 16,
        parameter WIDTH_C_LEN = 4
    )
    (
        input                                  clk,
        input                                  rst,
        
        //data I/O
        input  [NUM_VARS*3-1:0]                var_value_i,
        input  [NUM_VARS*3-1:0]                var_value_down_i,
        output [NUM_VARS*3-1:0]                var_value_down_o,
        output [NUM_VARS-1:0]                  participate_o,
        
        //用于推理时求得剩余最大lvl
        input  [NUM_VARS*WIDTH_LVL-1:0]        var_lvl_i,
        input  [NUM_VARS*WIDTH_LVL-1:0]        var_lvl_down_i,
        output [NUM_VARS*WIDTH_LVL-1:0]        var_lvl_down_o,
        
        //load update
        input  [NUM_CLAUSES-1:0]               wr_i,
        input  [NUM_CLAUSES-1:0]               rd_i,
        input  [NUM_VARS*2-1 : 0]              clause_i,
        output [NUM_VARS*2-1 : 0]              clause_o,
        input  [WIDTH_C_LEN-1 : 0]             clause_len_i,
        output [WIDTH_C_LEN*NUM_CLAUSES-1 : 0] clause_len_o,
        
        //ctrl
        output                                 all_c_sat_o,
        input                                  apply_imply_i,
        input                                  apply_analyze_i,
        input                                  apply_bkt_i,

        //用于调试的信号
        input  [31 : 0]                        debug_cid_down_i,
        output [31 : 0]                        debug_cid_down_o
    );

    wire [1:0]                     freelitcnt;
    wire                           imp_drv;
    wire                           conflict_c;
    wire                           all_lit_false;
    wire                           conflict_c_drv;
    wire                           csat_from_lits, csat_from_term;
    wire [NUM_VARS*2-1 : 0]        clause_lits;
    wire [WIDTH_LVL-1:0]           cmax_lvl_from_term, cmax_lvl_from_lits;

    lit8 lit8(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i),
        .var_value_down_i(var_value_down_i),
        .var_value_down_o(var_value_down_o),
        .participate_o   (participate_o),
        
        .var_lvl_i       (var_lvl_i),
        .var_lvl_down_i  (var_lvl_down_i),
        .var_lvl_down_o  (var_lvl_down_o),
        
        .cmax_lvl_i      (cmax_lvl_from_term),
        .cmax_lvl_o      (cmax_lvl_from_lits),
        
        .wr_i            (wr_i),
        .lit_i           (clause_i),
        .lit_o           (clause_lits),
        
        .freelitcnt_pre  (2'd0),
        .freelitcnt_next (freelitcnt),
        
        .imp_drv_i       (imp_drv),
        
        .conflict_c_o    (conflict_c),
        .all_lit_false_o (all_lit_false),
        .conflict_c_drv_i(conflict_c_drv),
        
        .csat_o          (csat_from_lits),
        .csat_drv_i      (csat_from_term),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),

        .debug_cid_i     (debug_cid_down_i),
        .debug_vid_next_i(0),
        .debug_vid_next_o()
    );

    reg [WIDTH_C_LEN-1 : 0] clause_len_r;
    assign clause_o = rd_i ? clause_lits : 0;

    terminal_cell #(
        .WIDTH_LVL  (WIDTH_LVL),
        .WIDTH_C_LEN(WIDTH_C_LEN)
    )
    terminal_cell(
        .clk             (clk),
        .rst             (rst),
        .csat_i          (csat_from_lits),
        .csat_drv_o      (csat_from_term),
        .freelitcnt_i    (freelitcnt),
        .clause_len_i    (clause_len_r),
        .imp_drv_o       (imp_drv),
        .conflict_c_i    (conflict_c),
        .all_lit_false_i (all_lit_false),
        .conflict_c_drv_o(conflict_c_drv),
        .cmax_lvl_i      (cmax_lvl_from_lits),
        .cmax_lvl_o      (cmax_lvl_from_term),
        .apply_analyze_i (apply_analyze_i),
        .debug_cid_i     (debug_cid_down_i)
    );

    reg                            need_clear;
    reg                            is_reason_r;

    always @(posedge clk) begin: set_need_clear
        if(~rst)
            need_clear <= 0;
        else if(is_reason_r && conflict_c_drv)
            need_clear <= 1;
        else if(~is_reason_r)
            need_clear <= 0;
        else
            need_clear <= need_clear;
    end

    always @(posedge clk) begin: set_is_reason_r
        if(~rst)
            is_reason_r <= 0;
        else if(apply_imply_i && imp_drv)
            is_reason_r <= 1;
        else if(apply_bkt_i && need_clear)
            is_reason_r <= 0;
        else
            is_reason_r <= is_reason_r;
    end

    always @(posedge clk) begin
        if(~rst)
            clause_len_r <= 0;
        else if(wr_i)
            clause_len_r <= clause_len_i;
        else
            clause_len_r <= clause_len_r;
    end

    //当该子句不是原因子句时，才将其长度输出
    assign clause_len_o = is_reason_r? 0:clause_len_r;

    assign all_c_sat_o = csat_from_lits || clause_lits==0;


`ifdef DEBUG_clause_array_time
    assign debug_cid_down_o = debug_cid_down_i + 1;
    `include "../tb/class_clause_data.sv";
    class_clause_data #(8) cdata = new;

    always @(posedge clk) begin
        //if($time/1000 >= 1640 && $time/1000 <= 1670) begin
        if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
            $display("%1tns info c%1d", $time/1000, debug_cid_down_i);
            $display("\tvar_value_down_o");
            cdata.set(var_value_down_o);
            cdata.display();
        end
    end
`endif

endmodule
