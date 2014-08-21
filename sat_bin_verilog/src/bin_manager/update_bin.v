/**
*   更新bin，包括：
*       learntc[]
*       var_states[]
*       lvl_states[]
*/

`include "../src/debug_define.v"

module update_bin #(
        parameter NUM_CLAUSES_A_BIN      = 8,
        parameter NUM_VARS_A_BIN         = 8,
        parameter NUM_LVLS_A_BIN         = 8,
        parameter WIDTH_CLAUSES          = NUM_VARS_A_BIN*2,
        parameter WIDTH_VAR              = 12,
        parameter WIDTH_LVL              = 16,
        parameter WIDTH_BIN_ID           = 10,
        parameter WIDTH_VAR_STATES       = 30,
        parameter WIDTH_LVL_STATES       = 30,
        parameter ADDR_WIDTH_CLAUSES     = 9,
        parameter ADDR_WIDTH_VAR         = 9,
        parameter ADDR_WIDTH_VAR_STATES = 9,
        parameter ADDR_WIDTH_LVL_STATES = 9
    )
    (
        input                                       clk,
        input                                       rst,

        //update control
        input                                       start_update,
        input [WIDTH_BIN_ID-1 : 0]                  update_bin_num_i,
        input                                       local_sat_i,
        output reg                                  apply_update_o,
        output                                      done_update,

        //update clause from sat engine
        output reg [NUM_CLAUSES_A_BIN-1:0]          rd_carray_o,
        input [NUM_VARS_A_BIN*2-1 : 0]              clause_i,

        //update var state from sat engine
        input [WIDTH_VAR_STATES*NUM_VARS_A_BIN-1:0] var_state_i,

        //update lvl state from sat engine
        input [WIDTH_LVL_STATES*NUM_LVLS_A_BIN-1:0] lvl_states_i,
        input [WIDTH_LVL-1:0]                       base_lvl_i,

        //clauses bins
        output reg                                  ram_we_c_o,
        output reg [WIDTH_CLAUSES-1:0]              ram_data_c_o,
        output reg [ADDR_WIDTH_CLAUSES-1:0]         ram_addr_c_o,

        //vars bins
        input [WIDTH_VAR-1 : 0]                     ram_data_v_i,
        output reg [ADDR_WIDTH_VAR-1:0]             ram_addr_v_o,

        //vars states
        output reg                                  ram_we_vs_o,
        output reg [WIDTH_VAR_STATES-1 : 0]         ram_data_vs_o,
        output reg [ADDR_WIDTH_VAR_STATES-1:0]      ram_addr_vs_o,

        //lvls states
        output reg                                  ram_we_ls_o,
        output reg [WIDTH_LVL_STATES-1 : 0]         ram_data_ls_o,
        output reg [ADDR_WIDTH_LVL_STATES-1:0]      ram_addr_ls_o
    );

    reg [NUM_VARS_A_BIN-1 : 0]              rd_var_states;
    reg [NUM_LVLS_A_BIN-1:0]                rd_lvl_states;

    //子句bin的基址，加载NUM_C个子句
    reg [ADDR_WIDTH_CLAUSES-1 : 0]        learntc_base_addr;
    wire [ADDR_WIDTH_VAR-1 : 0]           var_bin_i_base_addr;

    //从地址1开始
    wire [ADDR_WIDTH_CLAUSES-1 : 0]       clauses_bin_baseaddr = (update_bin_num_i-1)*NUM_CLAUSES_A_BIN+1;//i*8

    always @(posedge clk)
    begin
        if(~rst)
            learntc_base_addr <= 0;
        else if(start_update)
            learntc_base_addr <= clauses_bin_baseaddr + NUM_CLAUSES_A_BIN/2; //i*8+4
        else
            learntc_base_addr <= learntc_base_addr;
    end
    assign var_bin_i_base_addr = clauses_bin_baseaddr; //i*8

    parameter   IDLE = 0,
                UPDATE = 1,
                DONE = 2;

    reg [1:0] c_state, n_state;
    reg [5:0] vars_cnt, clauses_cnt, l_state_cnt;

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
                    if(start_update)
                        n_state = UPDATE;
                    else
                        n_state = IDLE;
                UPDATE:
                    if(vars_cnt==NUM_VARS_A_BIN && clauses_cnt==NUM_CLAUSES_A_BIN/2 && l_state_cnt==NUM_LVLS_A_BIN)
                        n_state = DONE;
                    else
                        n_state = UPDATE;
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
        else if (c_state==UPDATE && vars_cnt<NUM_VARS_A_BIN)
            vars_cnt <= vars_cnt+1;
        else if (c_state==UPDATE)
            vars_cnt <= vars_cnt;
        else
            vars_cnt <= 0;
    end

    always @(posedge clk)
    begin
        if (~rst)
            clauses_cnt <= 0;
        else if (c_state==UPDATE && clauses_cnt<NUM_CLAUSES_A_BIN/2)
            clauses_cnt <= clauses_cnt+1;
        else if (c_state==UPDATE)
            clauses_cnt <= clauses_cnt;
        else
            clauses_cnt <= 0;
    end

    always @(posedge clk)
    begin
        if (~rst)
            l_state_cnt <= 0;
        else if (c_state==UPDATE && l_state_cnt<NUM_CLAUSES_A_BIN)
            l_state_cnt <= l_state_cnt+1;
        else if (c_state==UPDATE)
            l_state_cnt <= l_state_cnt;
        else
            l_state_cnt <= 0;
    end


    /**
     *  更新子句
     */
    //子句的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            rd_carray_o <= 0;
        else if(rd_carray_o!=0) //移位
            rd_carray_o <= rd_carray_o<<1;
        else if(c_state==UPDATE)
            rd_carray_o <= 1;
        else
            rd_carray_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst) begin
            ram_we_c_o <= 0;
            ram_data_c_o <= 0;
            ram_addr_c_o <= 0;
        end else if(rd_carray_o==1) begin
            ram_we_c_o <= 1;
            ram_data_c_o <= clause_i;
            ram_addr_c_o <= clauses_bin_baseaddr;
        end else if(rd_carray_o!=0) begin
            ram_we_c_o <= 1;
            ram_data_c_o <= clause_i;
            ram_addr_c_o <= ram_addr_c_o+1;
        end else begin
            ram_we_c_o <= 0;
            ram_data_c_o <= 0;
            ram_addr_c_o <= 0;
        end
    end

    reg c_valid_delay;
    always @(posedge clk)
    begin
        if(~rst)
            c_valid_delay <= 0;
        else if(c_state==UPDATE)
            c_valid_delay <= 1;
        else
            c_valid_delay <= 0;
    end


    /**
     *  更新var state
     */
    //需要读取var_bin来获取变量的编号
    always @(posedge clk)
    begin
        if (~rst)
            ram_addr_v_o <= 0;
        else if (c_state==UPDATE)
            ram_addr_v_o <= var_bin_i_base_addr + vars_cnt;
        else
            ram_addr_v_o <= 0;
    end

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

    //var state的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            rd_var_states <= 0;
        else if(rd_var_states!=0) //移位
            rd_var_states <= rd_var_states<<1;
        else if(vs_valid_delay)
            rd_var_states <= 1;
        else
            rd_var_states <= 0;
    end


    wire [WIDTH_VAR_STATES-1:0] var_state_reduced;

    reduce_in_8_datas #(
        .WIDTH(WIDTH_VAR_STATES)
    )
    reduce_vs_inst (
        .data_i(var_state_i),
        .data_o(var_state_reduced),
        .rd_i(rd_var_states)
    );

    always @(posedge clk)
    begin
        if(~rst) begin
            ram_we_vs_o <= 0;
            ram_data_vs_o <= 0;
            ram_addr_vs_o <= 0;
        end else if(rd_var_states!=0 && local_sat_i) begin
            ram_we_vs_o <= 1;
            ram_data_vs_o <= var_state_reduced;
            ram_addr_vs_o <= ram_data_v_i;
        end else begin
            ram_we_vs_o <= 0;
            ram_data_vs_o <= 0;
            ram_addr_vs_o <= 0;
        end
    end

    /**
     *  更新lvl state
     */
    //有效信号延时一拍
    wire ls_valid_delay;
    assign ls_valid_delay = c_valid_delay;

    //lvl state的写入信号，需要移位
    always @(posedge clk)
    begin
        if(~rst)
            rd_lvl_states <= 0;
        else if(rd_lvl_states!=0) //移位
            rd_lvl_states <= rd_lvl_states<<1;
        else if(ls_valid_delay)
            rd_lvl_states <= 1;
        else
            rd_lvl_states <= 0;
    end

    wire [WIDTH_LVL_STATES-1:0] lvl_state_reduced;

    reduce_in_8_datas #(
        .WIDTH(WIDTH_LVL_STATES)
    )
    reduce_ls_inst (
        .data_i(lvl_states_i),
        .data_o(lvl_state_reduced),
        .rd_i(rd_lvl_states)
    );

    always @(posedge clk)
    begin
        if(~rst) begin
            ram_we_ls_o <= 0;
            ram_data_ls_o <= 0;
            ram_addr_ls_o <= 0;
        end else if(start_update) begin
            ram_we_ls_o <= 0;
            ram_data_ls_o <= 0;
            ram_addr_ls_o <= base_lvl_i;
        end else if(rd_lvl_states!=0 && local_sat_i) begin
            ram_we_ls_o <= 1;
            ram_data_ls_o <= lvl_state_reduced;
            ram_addr_ls_o <= ram_addr_ls_o + 1;
        end else begin
            ram_we_ls_o <= 0;
            ram_data_ls_o <= ram_data_ls_o;
            ram_addr_ls_o <= ram_addr_ls_o;
        end
    end

    // done_update信号，由于var state，要比计数器的完成延时两个周期
    reg [1:0] done_update_r;
    assign done_update = done_update_r[0];

    always @(posedge clk)
    begin
        if(~rst)
            done_update_r <= 0;
        else if(c_state==DONE)
            done_update_r <= {1'b1, done_update_r[1]};
        else
            done_update_r <= {1'b0, done_update_r[1]};
    end

    //持续信号，用于bram的mux
    always @(posedge clk)
    begin
        if(~rst)
            apply_update_o <= 0;
        else if(c_state!=IDLE)
            apply_update_o <= 1;
        else
            apply_update_o <= 0;
    end

`ifdef DEBUG_update_bin_time
    always @(posedge clk) begin
        if($time/1000 >= `T_START && $time/1000 <= `T_END) begin
            display_state();
            display_write_info();
        end
    end

    string str = "";
    string str_name = "";
    string str_value = "";

    task display_state();
        str = "";
        str_name = "\t";
        str_value = "\t";
        $display("%1tns update_bin", $time/1000);
        //                    01234567890123456789
        $sformat(str,"%16s", "start_update");   str_name = {str_name, str};
        $sformat(str,"%16s", "done_update");    str_name = {str_name, str};
        $sformat(str,"%16s", "done_update_r");  str_name = {str_name, str};
        $sformat(str,"%16s", "c_state");        str_name = {str_name, str};
        $sformat(str,"%16s", "base_lvl_i");     str_name = {str_name, str};
        //$sformat(str,"%16s", "ram_we_ls_o");    str_name = {str_name, str};
        //$sformat(str,"%16s", "ram_data_ls_o");  str_name = {str_name, str};
        $sformat(str,"%16s", "ram_addr_ls_o");  str_name = {str_name, str};

        $sformat(str,"%16d", start_update);     str_value = {str_value, str};
        $sformat(str,"%16d", done_update);      str_value = {str_value, str};
        $sformat(str,"%16d", done_update_r);    str_value = {str_value, str};
        $sformat(str,"%16d", c_state);          str_value = {str_value, str};
        $sformat(str,"%16d", base_lvl_i);       str_value = {str_value, str};
        //$sformat(str,"%16d", ram_we_ls_o);      str_value = {str_value, str};
        //$sformat(str,"%16d", ram_data_ls_o);    str_value = {str_value, str};
        $sformat(str,"%16d", ram_addr_ls_o);    str_value = {str_value, str};

        $display(str_name);
        $display(str_value);
    endtask

    `include "../tb/class_clause_data.sv";
    `include "../tb/class_vs_list.sv";
    `include "../tb/class_ls_list.sv";
    class_clause_data #(8) cdata = new;
    class_vs_list #(8, WIDTH_LVL) vs_list = new();
    class_ls_list #(8, WIDTH_LVL) ls_list = new();

    task display_write_info();
        if(rd_carray_o!=0) begin
            cdata.set_clause(clause_i);
            $display("%1tns rd_carray_o = %b", $time/1000, rd_carray_o);
            cdata.display_lits();
        end
        if(start_update!=0) begin
            //vs
            vs_list.set(var_state_i);
            $display("%1tns rd_var_state_list", $time/1000);
            vs_list.display();
            //ls
            ls_list.set(lvl_states_i);
            $display("%1tns rd_lvl_state_list", $time/1000);
            ls_list.display();
        end
        if(ram_we_c_o!=0) begin
            $display("%1tns ram_we_c_o", $time/1000);
            $display("\t%4d:%b", ram_addr_c_o, ram_data_c_o);
        end
        if(ram_we_vs_o!=0) begin
            $display("%1tns ram_we_vs_o", $time/1000);
            $display("\t%4d:%b", ram_addr_vs_o, ram_data_vs_o);
        end
        if(ram_we_ls_o!=0) begin
            $display("%1tns ram_we_ls_o", $time/1000);
            $display("\t%4d:%b", ram_addr_ls_o, ram_data_ls_o);
        end
    endtask

    /*
    always @(*) begin
        $display("%1tns ram_addr_v_o=%1d; vars_cnt=%1d", $time/1000, ram_addr_v_o, vars_cnt);
    end
    always @(ram_addr_v_o) begin
        @(posedge clk);
        $display("%1tns ram_data_v_i=%1d", $time/1000, ram_data_v_i);
    end
    */

`endif

endmodule
