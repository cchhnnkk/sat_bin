/**
*   加载bin，包括：
*       clauses[]
*       vars[]
*       根据vars加载var_states[]
*       根据base_lvl加载lvlss[]
*/

`include "../src/debug_define.v"

module load_bin #(
        parameter NUM_CLAUSES_A_BIN      = 8,
        parameter NUM_VARS_A_BIN         = 8,
        parameter NUM_LVLS_A_BIN         = 8,
        parameter WIDTH_CLAUSES          = NUM_VARS_A_BIN*2,
        parameter WIDTH_VAR              = 12,
        parameter WIDTH_LVL              = 16,
        parameter WIDTH_BIN_ID           = 10,
        parameter WIDTH_VAR_STATES       = 19,
        parameter WIDTH_LVL_STATES       = 11,
        parameter ADDR_WIDTH_CLAUSES     = 9,
        parameter ADDR_WIDTH_VAR         = 9,
        parameter ADDR_WIDTH_VAR_STATES = 9,
        parameter ADDR_WIDTH_LVL_STATES = 9
    )
    (
        input                                        clk,
        input                                        rst,

        //load control
        input                                        start_load,
        input [WIDTH_BIN_ID-1 : 0]                   request_bin_num_i,
        output reg                                   apply_load_o,
        output                                       done_load,

        //load clause to sat engine
        output reg [NUM_CLAUSES_A_BIN-1:0]           wr_carray_o,
        output reg [NUM_VARS_A_BIN*2-1 : 0]          clause_o,

        //load var state to sat engine
        output reg [NUM_VARS_A_BIN-1 : 0]            wr_var_states_o,
        output [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0] var_states_o,

        //load lvl state to sat engine
        output reg [NUM_LVLS_A_BIN-1:0]              wr_lvl_states_o,
        output [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0] lvl_states_o,

        input [WIDTH_LVL-1:0]                        cur_lvl_i,
        output reg [WIDTH_LVL-1:0]                   base_lvl_o,
        output reg                                   base_lvl_en,

        //clauses bins
        input [WIDTH_CLAUSES-1 : 0]                  ram_data_c_i,
        output reg [ADDR_WIDTH_CLAUSES-1:0]          ram_addr_c_o,

        //vars bins
        input [WIDTH_VAR-1 : 0]                      ram_data_v_i,
        output reg [ADDR_WIDTH_VAR-1:0]              ram_addr_v_o,

        //vars states
        input [WIDTH_VAR_STATES-1 : 0]               ram_data_vs_i,
        output [ADDR_WIDTH_VAR_STATES-1:0]           ram_addr_vs_o,

        //lvls states
        input [WIDTH_LVL_STATES-1 : 0]               ram_data_ls_i,
        output reg [ADDR_WIDTH_LVL_STATES-1:0]       ram_addr_ls_o
    );

    //子句bin的基址，加载NUM_C个子句
    reg [ADDR_WIDTH_CLAUSES-1 : 0]        clause_bin_i_base_addr;
    wire [ADDR_WIDTH_VAR-1 : 0]           var_bin_i_base_addr;

    //从地址1开始
    wire [ADDR_WIDTH_CLAUSES-1 : 0]       clauses_bin_baseaddr = (request_bin_num_i-1)*NUM_CLAUSES_A_BIN+1;//i*8

    always @(posedge clk)
    begin
        if(~rst)
            clause_bin_i_base_addr <= 0;
        else if(start_load)
            clause_bin_i_base_addr <= clauses_bin_baseaddr;
        else
            clause_bin_i_base_addr <= clause_bin_i_base_addr;
    end
    assign var_bin_i_base_addr = clause_bin_i_base_addr; //i*8

    parameter    IDLE = 0,
                 LOAD = 1,
                 DONE = 3;

    reg [1:0] c_state, n_state;
    reg [5:0] vars_cnt, clauses_cnt, ls_cnt;

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
                    if(start_load)
                        n_state = LOAD;
                    else
                        n_state = IDLE;
                LOAD:
                    if(vars_cnt==NUM_VARS_A_BIN && clauses_cnt==NUM_CLAUSES_A_BIN && ls_cnt==NUM_LVLS_A_BIN)
                        n_state = DONE;
                    else
                        n_state = LOAD;
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
            vars_cnt <= 0;
        else if (c_state==LOAD && vars_cnt<NUM_VARS_A_BIN)
            vars_cnt <= vars_cnt+1;
        else if (c_state==LOAD)
            vars_cnt <= vars_cnt;
        else
            vars_cnt <= 0;
    end

    always @(posedge clk)
    begin
        if (~rst)
            clauses_cnt <= 0;
        else if (c_state==LOAD && clauses_cnt<NUM_CLAUSES_A_BIN)
            clauses_cnt <= clauses_cnt+1;
        else if (c_state==LOAD)
            clauses_cnt <= clauses_cnt;
        else
            clauses_cnt <= 0;
    end

    /**
     *  加载子句
     */

    always @(posedge clk)
    begin
        if (~rst)
            ram_addr_c_o <= 0;
        else if (c_state==LOAD)
            ram_addr_c_o <= clause_bin_i_base_addr + vars_cnt;
        else
            ram_addr_c_o <= 0;
    end

    //有效信号延时两拍
    reg c_valid_delay;
    always @(posedge clk)
    begin
        if(~rst)
            c_valid_delay <= 0;
        else if(c_state==LOAD && clauses_cnt==1)
            c_valid_delay <= 1;
        else
            c_valid_delay <= 0;
    end

    //输出到sat engine的子句信号
    always @(posedge clk)
    begin
        if(~rst)
            clause_o <= 0;
        else if(c_state==LOAD)
            clause_o <= ram_data_c_i;
        else
            clause_o <= 0;
    end

    //子句的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            wr_carray_o <= 0;
        else if(wr_carray_o!=0) //移位
            wr_carray_o <= wr_carray_o<<1;
        else if(c_valid_delay)
            wr_carray_o <= 1;
        else
            wr_carray_o <= 0;
    end

    /**
     *  加载var state
     */
    //需先加载var id
    always @(posedge clk)
    begin
        if (~rst)
            ram_addr_v_o <= 0;
        else if (c_state==LOAD)
            ram_addr_v_o <= var_bin_i_base_addr + vars_cnt;
        else
            ram_addr_v_o <= 0;
    end

    //根据变量id查找var state
    assign ram_addr_vs_o = ram_data_v_i;

    //var state有效信号需要再延时一拍
    reg vs_valid_delay;
    always @(posedge clk)
    begin
        if(~rst)
            vs_valid_delay <= 0;
        else if(c_valid_delay)
            vs_valid_delay <= 1;
        else
            vs_valid_delay <= 0;
    end

    //输出到sat engine
    scatter_to_8_datas #(
        .WIDTH(WIDTH_VAR_STATES)
    )
    scatter_to_vs_inst (
        .wr_i(wr_var_states_o),
        .data_i(ram_data_vs_i),
        .data_o(var_states_o)
    );

    //var state的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            wr_var_states_o <= 0;
        else if(wr_var_states_o!=0) //移位
            wr_var_states_o <= wr_var_states_o<<1;
        else if(vs_valid_delay)
            wr_var_states_o <= 1;
        else
            wr_var_states_o <= 0;
    end

    reg base_lvl_en_delay1, base_lvl_en_delay2;
    /**
     *  加载lvl state
     *  先沿着lvl state list向前找到当前bin最小的lvl
     *  再加载N_L个lvl state
     */
    always @(posedge clk)
    begin
        if (~rst)
            ls_cnt <= 0;
        else if (c_state==LOAD && base_lvl_en && ls_cnt<NUM_CLAUSES_A_BIN)
            ls_cnt <= ls_cnt+1;
        else if (c_state==LOAD)
            ls_cnt <= ls_cnt;
        else
            ls_cnt <= 0;
    end

    wire [WIDTH_BIN_ID-1:0]   dcd_bin;
    wire                   has_bkt;

    assign {dcd_bin, has_bkt} = ram_data_ls_i;

    //找到非当前bin的lvl作为base_lvl
    reg ram_data_ls_valid;
    always @(posedge clk)
    begin
        if(~rst) begin
            base_lvl_en <= 0;
            base_lvl_o <= 0;
        end else if (start_load) begin
            base_lvl_en <= 0;
            base_lvl_o <= cur_lvl_i;
        end else if(c_state==LOAD && base_lvl_en==0 && ram_data_ls_valid && request_bin_num_i==dcd_bin) begin
            base_lvl_en <= 0;
            base_lvl_o <= ram_addr_ls_o;
        end else if(c_state==LOAD && ram_data_ls_valid && request_bin_num_i!=dcd_bin) begin
            base_lvl_en <= 1;
            base_lvl_o <= base_lvl_o;
        end else begin
            base_lvl_en <= base_lvl_en;
            base_lvl_o <= base_lvl_o;
        end
    end

    always @(posedge clk)
    begin
        if(c_state==LOAD) begin
            base_lvl_en_delay1 <= base_lvl_en;
            base_lvl_en_delay2 <= base_lvl_en_delay1;
        end else begin
            base_lvl_en_delay1 <= 0;
            base_lvl_en_delay2 <= 0;
        end
    end

    always @(posedge clk)
    begin
        if (~rst)
            ram_addr_ls_o <= 0;
        else if (start_load)        //找到非当前bin的lvl作为base_lvl
            ram_addr_ls_o <= cur_lvl_i;
        else if(base_lvl_en) //load lvl state
            ram_addr_ls_o <= base_lvl_o + 1 + ls_cnt; 
        else if(c_state==LOAD && ram_data_ls_valid && request_bin_num_i==dcd_bin)
            //找到非当前bin的lvl作为base_lvl
            ram_addr_ls_o <= ram_addr_ls_o - 1;
        else
            ram_addr_ls_o <= ram_addr_ls_o;
    end

    reg ram_data_ls_delay;

    always @(posedge clk)
    begin
        if (~rst)
            ram_data_ls_delay <= 0;
        else if (c_state==LOAD)
            ram_data_ls_delay <= 1;
        else
            ram_data_ls_delay <= 0;
    end

    always @(posedge clk)
    begin
        if (~rst)
            ram_data_ls_valid <= 0;
        else
            ram_data_ls_valid <= ram_data_ls_delay;
    end

    //输出到sat engine的子句信号
    scatter_to_8_datas #(
        .WIDTH(WIDTH_LVL_STATES)
    )
    scatter_to_ls_inst (
        .wr_i(wr_lvl_states_o),
        .data_i(ram_data_ls_i),
        .data_o(lvl_states_o)
    );

    //lvl state的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            wr_lvl_states_o <= 0;
        else if(wr_lvl_states_o!=0) //移位
            wr_lvl_states_o <= wr_lvl_states_o<<1;
        else if(c_state==LOAD && base_lvl_en_delay1 && ls_cnt<NUM_CLAUSES_A_BIN)
            wr_lvl_states_o <= 1;
        else
            wr_lvl_states_o <= 0;
    end

    // done_load信号，由于var state，要比计数器的完成延时两个周期
    reg [1:0] done_load_r;
    assign done_load = done_load_r[0];

    always @(posedge clk)
    begin
        if(~rst)
            done_load_r <= 0;
        else if(c_state==DONE)
            done_load_r <= {1'b1, done_load_r[1]};
        else
            done_load_r <= {1'b0, done_load_r[1]};
    end

    //持续信号，用于bram的mux
    always @(posedge clk)
    begin
        if(~rst)
            apply_load_o <= 0;
        else if(c_state==LOAD)
            apply_load_o <= 1;
        else
            apply_load_o <= 0;
    end

    /**
    *  输出load的信息
    */
    `ifdef DEBUG_load_bin
        `include "../tb/class_clause_data.sv";
        `include "../tb/class_vs_list.sv";
        `include "../tb/class_ls_list.sv";
        class_clause_data #(8) cdata = new;
        class_vs_list #(8, WIDTH_LVL) vs_list = new();
        class_ls_list #(8, WIDTH_LVL) ls_list = new();

        always @(posedge clk) begin
            if(wr_carray_o!=0) begin
                cdata.set_clause(clause_o);
                $display("%1tns wr_carray_o = %b", $time/1000, wr_carray_o);
                cdata.display_lits();
            end
            if(wr_var_states_o!=0) begin
                vs_list.set(var_states_o);
                $display("%1tns wr_var_states_o = %b", $time/1000, wr_var_states_o);
                vs_list.display();
            end
            if(wr_lvl_states_o!=0) begin
                ls_list.set(ram_data_ls_i);
                $display("%1tns wr_lvl_states_o = %b", $time/1000, wr_lvl_states_o);
                ls_list.display();
            end
            if(done_load) begin
                $display("%1tns base_lvl_o = %1d", $time/1000, base_lvl_o);
            end
        end

        always @(posedge clk) begin
            if(start_load || apply_load_o) begin
                $display("%1tns load_bin_info c_state = %1d request_bin_num_i = %1d", $time/1000, c_state, request_bin_num_i);
                $display("\t ram_addr_ls_o = %1d", ram_addr_ls_o);
                $display("\t ram_data_ls_i = %1b", ram_data_ls_i);
                $display("\t dcd_bin = %1d, has_bkt = %1d", dcd_bin, has_bkt);
                $display("\t base_lvl_en = %1d", base_lvl_en);
                $display("\t base_lvl_en_delay1 = %1d", base_lvl_en_delay1);
                $display("\t base_lvl_o = %1d", base_lvl_o);
                $display("\t cur_lvl_i = %1d", cur_lvl_i);
                $display("\t ls_cnt = %1d", ls_cnt);
                $display("\t ram_data_ls_valid = %1d", ram_data_ls_valid);
            end
        end
    `endif

endmodule
