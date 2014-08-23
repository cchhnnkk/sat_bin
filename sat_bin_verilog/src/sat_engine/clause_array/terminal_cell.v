
`include "../src/debug_define.v"

module terminal_cell #(
        parameter WIDTH_LVL   = 16,
        parameter WIDTH_C_LEN = 4
    )
    (
        input                    clk,
        input                    rst,
        
        input                    csat_i,
        output                   csat_drv_o,
        
        input  [1:0]             freelitcnt_i,
        input  [WIDTH_C_LEN-1:0] clause_len_i,
        
        output                   imp_drv_o,
        
        input                    conflict_c_i,
        input                    all_lit_false_i,
        output                   conflict_c_drv_o,
        
        input  [WIDTH_LVL-1:0]   cmax_lvl_i,
        output [WIDTH_LVL-1:0]   cmax_lvl_o,

        input                    apply_analyze_i,

        //用于调试的信号
        input  [31:0]            debug_cid_i
     );

    assign csat_drv_o = csat_i;

    assign imp_drv_o = freelitcnt_i==2'b01;

    reg conflict_c_drv_w;
    assign conflict_c_drv_o = conflict_c_drv_w;
    always @(*) begin
        if(~rst)
            conflict_c_drv_w = 0;
        else if(apply_analyze_i)
            //conflict_c_drv_w = conflict_c_i;
            conflict_c_drv_w = conflict_c_i | (all_lit_false_i && clause_len_i!=0);
        else
            conflict_c_drv_w = conflict_c_i | (all_lit_false_i && clause_len_i!=0);
    end

    //先用组合逻辑，后优化
    reg [WIDTH_LVL-1:0] cmax_lvl_w;
    assign cmax_lvl_o = cmax_lvl_w;

    always @(*) begin
        if(~rst)
            cmax_lvl_w = 0;
        else
            cmax_lvl_w = cmax_lvl_i;
    end

    `ifdef DEBUG_clause_array_time
        //显示所有子句terminal cell
        int disp_all_c = 1;
        //显示特定子句的terminal cell
        int len = 3;
        int c[] = '{0, 1, 2};
        always @(posedge clk) begin
            if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
                if(disp_all_c)
                    display_state();
                else begin
                    for(int i=0; i<len; i++) begin
                        if(debug_cid_i==c[i]) begin
                            display_state();
                        end
                    end
                end
            end
        end

        string str = "";
        string str_all = "";

        task display_state();
            str = "";
            str_all = "";
            $display("%1tns info c%1d_term", $time/1000, debug_cid_i);
            //               01234567890123456789
            $sformat(str,"\t all_lit_false_i");      str_all = {str_all, str};
            $sformat(str, "  apply_analyze_i");   str_all = {str_all, str};
            $sformat(str, "     conflict_c_i");      str_all = {str_all, str};
            $sformat(str, " conflict_c_drv_o");      str_all = {str_all, str};
            $sformat(str, "       csat_drv_o");      str_all = {str_all, str};
            $sformat(str, "     clause_len_i");      str_all = {str_all, str};
            $sformat(str, "       cmax_lvl_o");    str_all = {str_all, str};
            $sformat(str, "        imp_drv_o\n");    str_all = {str_all, str};

            $sformat(str,"\t%16b", all_lit_false_i );      str_all = {str_all, str};
            $sformat(str, " %16b", apply_analyze_i );      str_all = {str_all, str};
            $sformat(str, " %16b", conflict_c_i    );      str_all = {str_all, str};
            $sformat(str, " %16b", conflict_c_drv_o);      str_all = {str_all, str};
            $sformat(str, " %16d", csat_drv_o      );      str_all = {str_all, str};
            $sformat(str, " %16d", clause_len_i    );      str_all = {str_all, str};
            $sformat(str, " %16d", cmax_lvl_o      );      str_all = {str_all, str};
            $sformat(str, " %16d", imp_drv_o       );      str_all = {str_all, str};

            $display(str_all);
        endtask

        //task display_state();
        //    $display("%1tns c%1d v%1d", $time/1000, debug_cid_i, debug_vid_next_i);
        //    $display("\tall_lit_false_i  = %1d", all_lit_false_i);
        //    $display("\tconflict_c_i     = %1d", conflict_c_i);
        //    $display("\tconflict_c_drv_o = %1d", conflict_c_drv_o);
        //    $display("\tcsat_drv_o       = %1d", csat_drv_o);
        //    $display("\tclause_len_i     = %1d", clause_len_i);
        //    $display("\tcmax_lvl_o       = %1d", cmax_lvl_o);
        //endtask
    `endif

endmodule
