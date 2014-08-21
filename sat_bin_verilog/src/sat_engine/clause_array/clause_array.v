/**
 子句阵列的实现
 主要功能：实例化clause8，以及find_learntc_inserti
 */

`include "../src/debug_define.v"

module clause_array #(
        parameter NUM_CLAUSES = 8,
        parameter NUM_VARS    = 8,
        parameter WIDTH_LVL   = 16,
        parameter WIDTH_C_LEN = 4
    )
    (
        input                           clk,
        input                           rst,
        
        //data I/O
        input  [NUM_VARS*3-1:0]         var_value_i,
        output [NUM_VARS*3-1:0]         var_value_o,
        input  [NUM_VARS*WIDTH_LVL-1:0] var_lvl_i,
        output [NUM_VARS*WIDTH_LVL-1:0] var_lvl_o,
        output [NUM_VARS-1:0]           participate_o,
        
        //load update
        input  [NUM_CLAUSES-1:0]        wr_i,
        input  [NUM_CLAUSES-1:0]        rd_i,
        input  [NUM_VARS*2-1 : 0]       clause_i,
        output [NUM_VARS*2-1 : 0]       clause_o,
        input  [WIDTH_C_LEN-1 : 0]      clause_len_i,
        
        //ctrl
        input                           add_learntc_en_i,
        output                          all_c_sat_o,
        input                           apply_imply_i,
        input                           apply_analyze_i,
        input                           apply_bkt_i
    );

    wire [WIDTH_C_LEN*NUM_CLAUSES-1 : 0]    clause_len;
    wire [WIDTH_C_LEN*NUM_CLAUSES/2-1 : 0]  originc_lens, clause_lens;
    wire [NUM_CLAUSES-1:0]                  wr_clause;

    assign {clause_lens, originc_lens} = clause_len;

    wire [3*NUM_VARS-1:0]           var_value_down_start;
    wire  [NUM_VARS*WIDTH_LVL-1:0]  var_lvl_down_start;
    assign var_value_down_start = 0;
    assign var_lvl_down_start = 0;

    clause8 #(
        .WIDTH_C_LEN(WIDTH_C_LEN)
    )
    clause8(
        .clk             (clk),
        .rst             (rst),
        
        .var_value_i     (var_value_i),
        .var_value_down_i(var_value_down_start),
        .var_value_down_o(var_value_o),
        .participate_o   (participate_o),
        
        .var_lvl_i       (var_lvl_i),
        .var_lvl_down_i  (var_lvl_down_start),
        .var_lvl_down_o  (var_lvl_o),
        
        .wr_i            (wr_i),
        .rd_i            (rd_i),
        .clause_i        (clause_i),
        .clause_o        (clause_o),
        .clause_len_i    (clause_len_i),
        .clause_len_o    (clause_len),
        
        .all_c_sat_o     (all_c_sat_o),
        .apply_imply_i   (apply_imply_i),
        .apply_analyze_i (apply_analyze_i),
        .apply_bkt_i     (apply_bkt_i),

        .debug_cid_down_i(0),
        .debug_cid_down_o()
    );

    wire [WIDTH_C_LEN-1 : 0]    max_len;
    wire [NUM_CLAUSES/2-1:0]    insert_index;
    wire [NUM_CLAUSES-1:0]      learntc_insert_index;

    max_in_4_datas #(
            .WIDTH(WIDTH_C_LEN)
        )
        max_in_4_datas_inst0 (
            .data_i(clause_lens),
            .data_o(max_len),
            .index_o(insert_index)
        );
    assign learntc_insert_index = {insert_index, 4'd0};
    assign wr_clause = add_learntc_en_i? learntc_insert_index : wr_i;


    `ifdef DEBUG_clause_array_time
        `include "../tb/class_clause_data.sv";
        class_clause_data #(8) cdata = new;

        always @(posedge clk) begin
            //if($time/1000 >= 1640 && $time/1000 <= 1670) begin
            if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
                $display("%1tns var_value_i", $time/1000);
                $display("\tvar_value_i");
                cdata.set(var_value_i);
                cdata.display();
            end
        end
    `endif

endmodule
