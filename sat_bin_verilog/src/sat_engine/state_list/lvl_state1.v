/**
 维护Sat Engine中单个层级的状态，在加载和决策时进行赋值，
 包括:
     reg [WIDTH_BIN_ID-1:0] dcd_bin_r;
     reg has_bkt_r;

 协助find_bkt_lvl:
     根据max_lvl -> 遍历has_bkt[]
     沿着isbkt[]从后向前查找bkted为False的层级
         <--    <--    <--
         findflag: 2 ... 2 1 0 ... 0
 */

`include "../src/debug_define.v"

module lvl_state1 #(
        parameter WIDTH_LVL_STATES = 11,
        parameter WIDTH_LVL        = 16,
        parameter WIDTH_BIN_ID     = 10
    )
    (
        input                           clk, 
        input                           rst, 

        //decide
        input                           valid_from_decision_i,
        input [WIDTH_BIN_ID-1:0]        cur_bin_num_i,
        input [WIDTH_LVL-1:0]           cur_lvl_i,
        input [WIDTH_LVL-1:0]           lvl_next_i,
        output [WIDTH_LVL-1:0]          lvl_next_o,

        //find bkt lvl
        input [1:0]                     findflag_left_i,
        output [1:0]                    findflag_left_o,
        input [WIDTH_LVL-1:0]           max_lvl_i,
        output reg [WIDTH_BIN_ID-1:0]   bkt_bin_o,
        output reg [WIDTH_LVL-1:0]      bkt_lvl_o,

        //backtrack
        input                           apply_bkt_i,

        //load update
        input                           wr_states,
        input [WIDTH_LVL_STATES-1 : 0]  lvl_states_i,
        output [WIDTH_LVL_STATES-1 : 0] lvl_states_o
    );

    //加载和更新数据
    reg [WIDTH_BIN_ID-1:0]  dcd_bin_r;
    reg                     has_bkt_r;
    wire [WIDTH_BIN_ID-1:0] dcd_bin_i;
    wire                    has_bkt_i;
    assign lvl_states_o = {dcd_bin_r, has_bkt_r};
    assign {dcd_bin_i, has_bkt_i} = lvl_states_i;

    assign lvl_next_o = lvl_next_i + 1;

    reg [WIDTH_LVL-1:0]     lvl_r;

    always @(posedge clk) begin
        if(~rst)
            lvl_r <= 0;
        else
            lvl_r <= lvl_next_i;
    end

    wire can_wr_ls;

    assign can_wr_ls = valid_from_decision_i!=0 && lvl_r==cur_lvl_i;

    always @(posedge clk) begin
        if(~rst)
            dcd_bin_r <= 0;
        else if(wr_states)             //加载
            dcd_bin_r <= dcd_bin_i;
        else if(can_wr_ls) //决策
            dcd_bin_r <= cur_bin_num_i;
        else if(apply_bkt_i && findflag_left_o==0) //清除
            dcd_bin_r <= 0;
        else
            dcd_bin_r <= dcd_bin_r;
    end

    always @(posedge clk) begin
        if(~rst)
            has_bkt_r <= 0;
        else if(wr_states)
            has_bkt_r <= has_bkt_i;
        else if(can_wr_ls)
            has_bkt_r <= 0;
        else if(apply_bkt_i && findflag_left_o==1) //翻转
            has_bkt_r <= 1;
        else if(apply_bkt_i && findflag_left_o==0) //清除
            has_bkt_r <= 0;
        else
            has_bkt_r <= has_bkt_r;
    end

    always @(posedge clk) begin
        if(~rst)
            bkt_bin_o <= 0;
        else if(findflag_left_o==1)
            bkt_bin_o <= dcd_bin_r;
        else
            bkt_bin_o <= 0;
    end

    always @(posedge clk) begin
        if(~rst)
            bkt_lvl_o <= 0;
        else if(findflag_left_o==1)
            bkt_lvl_o <= lvl_r;
        else
            bkt_lvl_o <= 0;
    end

    assign findflag_left_o = findflag_left_i != 0 ? 2 : 
        (max_lvl_i >= lvl_r && has_bkt_r == 0) ? 1:0;


    `ifdef DEBUG_lvl_state_time
        //显示所有
        int disp_all_ls = 1;
        //显示特定
        int len = 3;
        int l[] = '{1, 3, 4};
        always @(posedge clk) begin
            if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
                if(disp_all_ls)
                    display_state();
                else begin
                    for(int i=0; i<len; i++) begin
                        if(lvl_next_i==l[i]) begin
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
            $display("%1tns info ls_%1d", $time/1000, lvl_next_i);
            //               01234567890123456789
            $sformat(str,"\t           lvl_r");     str_all = {str_all, str};
            $sformat(str,"\t       dcd_bin_r");     str_all = {str_all, str};
            $sformat(str, "        has_bkt_r");     str_all = {str_all, str};
            $sformat(str, "  findflag_left_i");     str_all = {str_all, str};
            $sformat(str, "  findflag_left_o");     str_all = {str_all, str};
            $sformat(str, "        max_lvl_i");     str_all = {str_all, str};
            $sformat(str, "        bkt_bin_o");   str_all = {str_all, str};
            $sformat(str, "        bkt_lvl_o\n");   str_all = {str_all, str};

            $sformat(str,"\t%16d", lvl_r          );     str_all = {str_all, str};
            $sformat(str, " %16d", dcd_bin_r      );     str_all = {str_all, str};
            $sformat(str, " %16d", has_bkt_r      );     str_all = {str_all, str};
            $sformat(str, " %16d", findflag_left_i);     str_all = {str_all, str};
            $sformat(str, " %16d", findflag_left_o);     str_all = {str_all, str};
            $sformat(str, " %16d", max_lvl_i      );     str_all = {str_all, str};
            $sformat(str, " %16d", bkt_bin_o      );     str_all = {str_all, str};
            $sformat(str, " %16d", bkt_lvl_o      );     str_all = {str_all, str};
            $sformat(str, str_all);

            $display(str_all);
        endtask

    `endif

endmodule
