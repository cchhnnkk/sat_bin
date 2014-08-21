/**
*   遍历lvl state，查找全局的回退层级
*/

`include "../src/debug_define.v"

module find_global_bkt_lvl #(
        parameter WIDTH_LVL              = 16,
        parameter WIDTH_BIN_ID           = 10,
        parameter WIDTH_LVL_STATES       = 11,
        parameter ADDR_WIDTH_LVL_STATES = 9
    )
    (
        input                                         clk,
        input                                         rst,

        //control
        input                                         start_find,
        output reg                                    apply_find_o,
        output reg                                    done_find,

        input [WIDTH_LVL-1:0]                         bkt_lvl_i,
        output reg [WIDTH_LVL-1:0]                    bkt_lvl_o,
        output reg [WIDTH_BIN_ID-1 : 0]               bkt_bin_o,

        //lvls states bram
        //rd
        output reg [ADDR_WIDTH_LVL_STATES-1:0]        ram_raddr_ls_o,
        input [WIDTH_LVL_STATES-1 : 0]                ram_rdata_ls_i,
        //wr
        output reg                                    ram_we_ls_o,
        output reg [WIDTH_LVL_STATES-1 : 0]           ram_wdata_ls_o,
        output reg [ADDR_WIDTH_LVL_STATES-1:0]        ram_waddr_ls_o
    );

    wire [WIDTH_BIN_ID-1:0]   dcd_bin;
    wire                      has_bkt;
    reg                       ram_rdata_ls_valid;

    parameter   IDLE = 0,
                FIND_BKT_LVL = 1,
                WAIT = 2,
                SET_HAS_BKT = 3,
                DONE = 4;

    reg [3:0]               c_state, n_state;
    reg [WIDTH_LVL-1:0]     lvl_cnt;

    always @(posedge clk)
    begin
        if(~rst)
            c_state <= 0;
        else
            c_state <= n_state;
    end

    always @(*)
    begin
        if(~rst)
            n_state = 0;
        else
            case(c_state)
                IDLE:
                    if(start_find)
                        n_state = FIND_BKT_LVL;
                    else
                        n_state = IDLE;
                FIND_BKT_LVL:
                    if(lvl_cnt==0)
                        n_state = WAIT;
                    else if(ram_rdata_ls_valid && has_bkt==0)
                        n_state = SET_HAS_BKT;
                    else
                        n_state = FIND_BKT_LVL;
                WAIT:
                    n_state = DONE;
                SET_HAS_BKT:
                    n_state = DONE;
                DONE:
                    n_state = IDLE;
                default:
                    n_state = IDLE;
            endcase
    end

    /**
    *  计数器
    */
    always @(posedge clk)
    begin
        if (~rst)
            lvl_cnt <= 0;
        else if (start_find)
            lvl_cnt <= bkt_lvl_i;
        else if(c_state==FIND_BKT_LVL && lvl_cnt!=0)
            lvl_cnt <= lvl_cnt-1;
        else
            lvl_cnt <= 0;
    end

    always @(posedge clk)
    begin
        if (~rst) begin
            ram_raddr_ls_o <= 0;
        end
        else if(c_state==FIND_BKT_LVL) begin
            ram_raddr_ls_o <= lvl_cnt; //bram的地址从1开始
        end
        else begin
            ram_raddr_ls_o <= 0;
        end
    end

    reg ram_rdata_ls_delay;

    always @(posedge clk)
    begin
        if (~rst) begin
            ram_rdata_ls_delay <= 0;
        end
        else if(c_state==FIND_BKT_LVL) begin
            ram_rdata_ls_delay <= 1;
        end
        else begin
            ram_rdata_ls_delay <= 0;
        end
    end

    always @(posedge clk)
    begin
        ram_rdata_ls_valid <= ram_rdata_ls_delay;
    end

    reg [ADDR_WIDTH_LVL_STATES-1:0] ram_raddr_ls_delay;
    always @(posedge clk)
    begin
        ram_raddr_ls_delay <= ram_raddr_ls_o;
    end

    assign {dcd_bin, has_bkt} = ram_rdata_ls_i;

    //记录结果
    always @(posedge clk)
    begin
        if (~rst) begin
            bkt_bin_o <= 0;
            bkt_lvl_o <= 0;
        end
        else if(ram_rdata_ls_valid && has_bkt==0 && (c_state==FIND_BKT_LVL || c_state==WAIT)) begin
            bkt_bin_o <= dcd_bin;
            bkt_lvl_o <= ram_raddr_ls_delay;
        end
        else begin
            bkt_bin_o <= bkt_bin_o;
            bkt_lvl_o <= bkt_lvl_o;
        end
    end

    //持续信号，用于bram的mux
    always @(posedge clk)
    begin
        if(~rst)
            apply_find_o <= 0;
        else if(c_state!=IDLE || start_find)
            apply_find_o <= 1;
        else
            apply_find_o <= 0;
    end

    /**
    *  将回退层的has_bkt置为1
    */
    always @(posedge clk)
    begin
        if(~rst) begin
            ram_we_ls_o <= 0;
            ram_waddr_ls_o <= 0;
            ram_wdata_ls_o <= 0;
        end
        else if(c_state == SET_HAS_BKT) begin
            ram_we_ls_o <= 1;
            ram_waddr_ls_o <= bkt_lvl_o;
            ram_wdata_ls_o <= {bkt_bin_o, 1'b1};
        end
        else begin
            ram_we_ls_o <= 0;
            ram_waddr_ls_o <= 0;
            ram_wdata_ls_o <= 0;
        end
    end

    always @(posedge clk)
    begin
        if(~rst)
            done_find <= 0;
        else if(c_state==DONE)
            done_find <= 1;
        else
            done_find <= 0;
    end

    /**
    *  输出调试的信息
    */
`ifdef DEBUG_find_gbkt_lvl

    //always @(posedge clk) begin
        //if(c_state!=n_state && n_state!=IDLE)
        //    $display("%1tns find_global_bkt_lvl n_state = %1d", $time/1000, n_state);
    //end

    always @(*) begin
        if(apply_find_o) begin
            $display("%1tns find_global_bkt_lvl c_state = %1d", $time/1000, c_state);
            //$display("\t bkt_lvl_i = %1d", bkt_lvl_i);
            $display("\t lvl_cnt = %1d", lvl_cnt);
            $display("\t ram_raddr_ls_o = %1d", ram_raddr_ls_o);
            $display("\t ram_rdata_ls_i = %1d", ram_rdata_ls_i);
            $display("\t ram_rdata_ls_valid = %1d", ram_rdata_ls_valid);
            $display("\t ram_raddr_ls_delay = %1d", ram_raddr_ls_delay);
            $display("\t dcd_bin = %1d, has_bkt = %1d", dcd_bin, has_bkt);
            $display("\t bkt_bin_o = %1d, bkt_lvl_o = %1d", bkt_bin_o, bkt_lvl_o);
        end
    end

`endif

endmodule
