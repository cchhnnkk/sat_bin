
/**
 *  该文件是使用gen_num_verilog.py生成的
 *  gen_num_verilog ../src/sat_engine/clause_array/lits.gen 8
 */

 
module lit8 #(
        parameter NUM_LITS = 8,
        parameter WIDTH_LVL   = 16
    )
    (
        input                           clk,
        input                           rst,
        
        input  [NUM_LITS*3-1 : 0]       var_value_i,
        input  [NUM_LITS*3-1 : 0]       var_value_down_i,
        output [NUM_LITS*3-1 : 0]       var_value_down_o,
        output [NUM_LITS-1:0]           participate_o,
        
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_i,
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_i,
        output [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_o,
        
        input                           wr_i,
        input  [NUM_LITS*2-1:0]         lit_i,
        output [NUM_LITS*2-1:0]         lit_o,
        
        input  [1 : 0]                  freelitcnt_pre,
        output [1 : 0]                  freelitcnt_next,
        
        input                           imp_drv_i,
        
        output                          conflict_c_o,
        output                          all_lit_false_o,
        input                           conflict_c_drv_i,
        
        output                          csat_o,
        input                           csat_drv_i,
        
        //连接terminal cell
        input  [WIDTH_LVL-1:0]          cmax_lvl_i,
        output [WIDTH_LVL-1:0]          cmax_lvl_o,

        //控制信号
        input                           apply_imply_i,
        input                           apply_analyze_i,
        input                           apply_bkt_i,

        //用于调试的信号
        input  [31 : 0]                 debug_cid_i,
        input  [31 : 0]                 debug_vid_next_i,
        output [31 : 0]                 debug_vid_next_o
    );

    wire [NUM_LITS/2*3-1:0]           var_value_i_0,       var_value_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_i_0,  var_value_down_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_o_0,  var_value_down_o_1;
    wire [NUM_LITS/2-1:0]             participate_o_0,     participate_o_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,         var_lvl_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_i_0,    var_lvl_down_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_o_0,    var_lvl_down_o_1;
    wire [WIDTH_LVL-1 : 0]            cmax_lvl_o_0,        cmax_lvl_o_1;
    wire [NUM_LITS/2*2-1:0]           lit_i_0,             lit_i_1;
    wire [NUM_LITS/2*2-1:0]           lit_o_0,             lit_o_1;
    wire [1:0]                        freelitcnt_0;
    wire                              imp_drv_0,           imp_drv_1;
    wire                              conflict_c_0,        conflict_c_1;
    wire                              all_lit_false_0,     all_lit_false_1;
    wire                              csat_o_0,            csat_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign {var_value_down_i_1, var_value_down_i_0} = var_value_down_i;
    assign var_value_down_o = {var_value_down_o_1, var_value_down_o_0};
    assign participate_o = {participate_o_1, participate_o_0};
    
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign {var_lvl_down_i_1, var_lvl_down_i_0} = var_lvl_down_i;
    assign var_lvl_down_o = {var_lvl_down_o_1, var_lvl_down_o_0};
    assign cmax_lvl_o = cmax_lvl_o_1 > cmax_lvl_o_0? cmax_lvl_o_1 : cmax_lvl_o_0;
    
    assign {lit_i_1, lit_i_0} = lit_i;
    assign lit_o = {lit_o_1, lit_o_0};

    assign csat_o = csat_o_1 | csat_o_0;
    assign conflict_c_o = conflict_c_1 | conflict_c_0;
    assign all_lit_false_o = all_lit_false_1 & all_lit_false_0;
    
    assign imp_drv_0 = imp_drv_i;
    assign imp_drv_1 = imp_drv_i;

    lit4 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit4_0(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_0),
        .var_value_down_i(var_value_down_i_0),
        .var_value_down_o(var_value_down_o_0),
        .participate_o   (participate_o_0),
        
        .var_lvl_i       (var_lvl_i_0),
        .var_lvl_down_i  (var_lvl_down_i_0),
        .var_lvl_down_o  (var_lvl_down_o_0),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_0),
        .lit_o           (lit_o_0),
        
        .freelitcnt_pre  (freelitcnt_pre),
        .freelitcnt_next (freelitcnt_0),
        
        .imp_drv_i       (imp_drv_0),
        
        .conflict_c_o    (conflict_c_0),
        .all_lit_false_o (all_lit_false_0),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_0),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i      (cmax_lvl_i),
        .cmax_lvl_o      (cmax_lvl_o_0),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_next_i),
        .debug_vid_next_o(debug_vid_temp)
        );

    lit4 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit4_1(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_1),
        .var_value_down_i(var_value_down_i_1),
        .var_value_down_o(var_value_down_o_1),
        .participate_o   (participate_o_1),
        
        .var_lvl_i       (var_lvl_i_1),
        .var_lvl_down_i  (var_lvl_down_i_1),
        .var_lvl_down_o  (var_lvl_down_o_1),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_1),
        .lit_o           (lit_o_1),
        
        .freelitcnt_pre  (freelitcnt_0),
        .freelitcnt_next (freelitcnt_next),
        
        .imp_drv_i       (imp_drv_1),
        
        .conflict_c_o    (conflict_c_1),
        .all_lit_false_o (all_lit_false_1),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_1),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i       (cmax_lvl_i),
        .cmax_lvl_o       (cmax_lvl_o_1),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_temp),
        .debug_vid_next_o(debug_vid_next_o)
        );
 
endmodule


 
module lit4 #(
        parameter NUM_LITS = 4,
        parameter WIDTH_LVL   = 16
    )
    (
        input                           clk,
        input                           rst,
        
        input  [NUM_LITS*3-1 : 0]       var_value_i,
        input  [NUM_LITS*3-1 : 0]       var_value_down_i,
        output [NUM_LITS*3-1 : 0]       var_value_down_o,
        output [NUM_LITS-1:0]           participate_o,
        
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_i,
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_i,
        output [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_o,
        
        input                           wr_i,
        input  [NUM_LITS*2-1:0]         lit_i,
        output [NUM_LITS*2-1:0]         lit_o,
        
        input  [1 : 0]                  freelitcnt_pre,
        output [1 : 0]                  freelitcnt_next,
        
        input                           imp_drv_i,
        
        output                          conflict_c_o,
        output                          all_lit_false_o,
        input                           conflict_c_drv_i,
        
        output                          csat_o,
        input                           csat_drv_i,
        
        //连接terminal cell
        input  [WIDTH_LVL-1:0]          cmax_lvl_i,
        output [WIDTH_LVL-1:0]          cmax_lvl_o,

        //控制信号
        input                           apply_imply_i,
        input                           apply_analyze_i,
        input                           apply_bkt_i,

        //用于调试的信号
        input  [31 : 0]                 debug_cid_i,
        input  [31 : 0]                 debug_vid_next_i,
        output [31 : 0]                 debug_vid_next_o
    );

    wire [NUM_LITS/2*3-1:0]           var_value_i_0,       var_value_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_i_0,  var_value_down_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_o_0,  var_value_down_o_1;
    wire [NUM_LITS/2-1:0]             participate_o_0,     participate_o_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,         var_lvl_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_i_0,    var_lvl_down_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_o_0,    var_lvl_down_o_1;
    wire [WIDTH_LVL-1 : 0]            cmax_lvl_o_0,        cmax_lvl_o_1;
    wire [NUM_LITS/2*2-1:0]           lit_i_0,             lit_i_1;
    wire [NUM_LITS/2*2-1:0]           lit_o_0,             lit_o_1;
    wire [1:0]                        freelitcnt_0;
    wire                              imp_drv_0,           imp_drv_1;
    wire                              conflict_c_0,        conflict_c_1;
    wire                              all_lit_false_0,     all_lit_false_1;
    wire                              csat_o_0,            csat_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign {var_value_down_i_1, var_value_down_i_0} = var_value_down_i;
    assign var_value_down_o = {var_value_down_o_1, var_value_down_o_0};
    assign participate_o = {participate_o_1, participate_o_0};
    
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign {var_lvl_down_i_1, var_lvl_down_i_0} = var_lvl_down_i;
    assign var_lvl_down_o = {var_lvl_down_o_1, var_lvl_down_o_0};
    assign cmax_lvl_o = cmax_lvl_o_1 > cmax_lvl_o_0? cmax_lvl_o_1 : cmax_lvl_o_0;
    
    assign {lit_i_1, lit_i_0} = lit_i;
    assign lit_o = {lit_o_1, lit_o_0};

    assign csat_o = csat_o_1 | csat_o_0;
    assign conflict_c_o = conflict_c_1 | conflict_c_0;
    assign all_lit_false_o = all_lit_false_1 & all_lit_false_0;
    
    assign imp_drv_0 = imp_drv_i;
    assign imp_drv_1 = imp_drv_i;

    lit2 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit2_0(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_0),
        .var_value_down_i(var_value_down_i_0),
        .var_value_down_o(var_value_down_o_0),
        .participate_o   (participate_o_0),
        
        .var_lvl_i       (var_lvl_i_0),
        .var_lvl_down_i  (var_lvl_down_i_0),
        .var_lvl_down_o  (var_lvl_down_o_0),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_0),
        .lit_o           (lit_o_0),
        
        .freelitcnt_pre  (freelitcnt_pre),
        .freelitcnt_next (freelitcnt_0),
        
        .imp_drv_i       (imp_drv_0),
        
        .conflict_c_o    (conflict_c_0),
        .all_lit_false_o (all_lit_false_0),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_0),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i      (cmax_lvl_i),
        .cmax_lvl_o      (cmax_lvl_o_0),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_next_i),
        .debug_vid_next_o(debug_vid_temp)
        );

    lit2 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit2_1(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_1),
        .var_value_down_i(var_value_down_i_1),
        .var_value_down_o(var_value_down_o_1),
        .participate_o   (participate_o_1),
        
        .var_lvl_i       (var_lvl_i_1),
        .var_lvl_down_i  (var_lvl_down_i_1),
        .var_lvl_down_o  (var_lvl_down_o_1),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_1),
        .lit_o           (lit_o_1),
        
        .freelitcnt_pre  (freelitcnt_0),
        .freelitcnt_next (freelitcnt_next),
        
        .imp_drv_i       (imp_drv_1),
        
        .conflict_c_o    (conflict_c_1),
        .all_lit_false_o (all_lit_false_1),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_1),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i       (cmax_lvl_i),
        .cmax_lvl_o       (cmax_lvl_o_1),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_temp),
        .debug_vid_next_o(debug_vid_next_o)
        );
 
endmodule


 
module lit2 #(
        parameter NUM_LITS = 2,
        parameter WIDTH_LVL   = 16
    )
    (
        input                           clk,
        input                           rst,
        
        input  [NUM_LITS*3-1 : 0]       var_value_i,
        input  [NUM_LITS*3-1 : 0]       var_value_down_i,
        output [NUM_LITS*3-1 : 0]       var_value_down_o,
        output [NUM_LITS-1:0]           participate_o,
        
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_i,
        input  [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_i,
        output [NUM_LITS*WIDTH_LVL-1:0] var_lvl_down_o,
        
        input                           wr_i,
        input  [NUM_LITS*2-1:0]         lit_i,
        output [NUM_LITS*2-1:0]         lit_o,
        
        input  [1 : 0]                  freelitcnt_pre,
        output [1 : 0]                  freelitcnt_next,
        
        input                           imp_drv_i,
        
        output                          conflict_c_o,
        output                          all_lit_false_o,
        input                           conflict_c_drv_i,
        
        output                          csat_o,
        input                           csat_drv_i,
        
        //连接terminal cell
        input  [WIDTH_LVL-1:0]          cmax_lvl_i,
        output [WIDTH_LVL-1:0]          cmax_lvl_o,

        //控制信号
        input                           apply_imply_i,
        input                           apply_analyze_i,
        input                           apply_bkt_i,

        //用于调试的信号
        input  [31 : 0]                 debug_cid_i,
        input  [31 : 0]                 debug_vid_next_i,
        output [31 : 0]                 debug_vid_next_o
    );

    wire [NUM_LITS/2*3-1:0]           var_value_i_0,       var_value_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_i_0,  var_value_down_i_1;
    wire [NUM_LITS/2*3-1:0]           var_value_down_o_0,  var_value_down_o_1;
    wire [NUM_LITS/2-1:0]             participate_o_0,     participate_o_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_i_0,         var_lvl_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_i_0,    var_lvl_down_i_1;
    wire [NUM_LITS*WIDTH_LVL/2-1 : 0] var_lvl_down_o_0,    var_lvl_down_o_1;
    wire [WIDTH_LVL-1 : 0]            cmax_lvl_o_0,        cmax_lvl_o_1;
    wire [NUM_LITS/2*2-1:0]           lit_i_0,             lit_i_1;
    wire [NUM_LITS/2*2-1:0]           lit_o_0,             lit_o_1;
    wire [1:0]                        freelitcnt_0;
    wire                              imp_drv_0,           imp_drv_1;
    wire                              conflict_c_0,        conflict_c_1;
    wire                              all_lit_false_0,     all_lit_false_1;
    wire                              csat_o_0,            csat_o_1;
    wire [31 : 0]                     debug_vid_temp;

    assign {var_value_i_1, var_value_i_0} = var_value_i;
    assign {var_value_down_i_1, var_value_down_i_0} = var_value_down_i;
    assign var_value_down_o = {var_value_down_o_1, var_value_down_o_0};
    assign participate_o = {participate_o_1, participate_o_0};
    
    assign {var_lvl_i_1, var_lvl_i_0} = var_lvl_i;
    assign {var_lvl_down_i_1, var_lvl_down_i_0} = var_lvl_down_i;
    assign var_lvl_down_o = {var_lvl_down_o_1, var_lvl_down_o_0};
    assign cmax_lvl_o = cmax_lvl_o_1 > cmax_lvl_o_0? cmax_lvl_o_1 : cmax_lvl_o_0;
    
    assign {lit_i_1, lit_i_0} = lit_i;
    assign lit_o = {lit_o_1, lit_o_0};

    assign csat_o = csat_o_1 | csat_o_0;
    assign conflict_c_o = conflict_c_1 | conflict_c_0;
    assign all_lit_false_o = all_lit_false_1 & all_lit_false_0;
    
    assign imp_drv_0 = imp_drv_i;
    assign imp_drv_1 = imp_drv_i;

    lit1 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit1_0(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_0),
        .var_value_down_i(var_value_down_i_0),
        .var_value_down_o(var_value_down_o_0),
        .participate_o   (participate_o_0),
        
        .var_lvl_i       (var_lvl_i_0),
        .var_lvl_down_i  (var_lvl_down_i_0),
        .var_lvl_down_o  (var_lvl_down_o_0),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_0),
        .lit_o           (lit_o_0),
        
        .freelitcnt_pre  (freelitcnt_pre),
        .freelitcnt_next (freelitcnt_0),
        
        .imp_drv_i       (imp_drv_0),
        
        .conflict_c_o    (conflict_c_0),
        .all_lit_false_o (all_lit_false_0),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_0),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i      (cmax_lvl_i),
        .cmax_lvl_o      (cmax_lvl_o_0),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_next_i),
        .debug_vid_next_o(debug_vid_temp)
        );

    lit1 #(
        .WIDTH_LVL(WIDTH_LVL)
    )
    lit1_1(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i_1),
        .var_value_down_i(var_value_down_i_1),
        .var_value_down_o(var_value_down_o_1),
        .participate_o   (participate_o_1),
        
        .var_lvl_i       (var_lvl_i_1),
        .var_lvl_down_i  (var_lvl_down_i_1),
        .var_lvl_down_o  (var_lvl_down_o_1),
        
        .wr_i            (wr_i),
        .lit_i           (lit_i_1),
        .lit_o           (lit_o_1),
        
        .freelitcnt_pre  (freelitcnt_0),
        .freelitcnt_next (freelitcnt_next),
        
        .imp_drv_i       (imp_drv_1),
        
        .conflict_c_o    (conflict_c_1),
        .all_lit_false_o (all_lit_false_1),
        .conflict_c_drv_i(conflict_c_drv_i),
        
        .csat_o          (csat_o_1),
        .csat_drv_i      (csat_drv_i),
        
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),
        
        .cmax_lvl_i       (cmax_lvl_i),
        .cmax_lvl_o       (cmax_lvl_o_1),

        .debug_cid_i     (debug_cid_i),
        .debug_vid_next_i(debug_vid_temp),
        .debug_vid_next_o(debug_vid_next_o)
        );
 
endmodule

