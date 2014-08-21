/**
    寻找下一个决策变量:
        使用静态的赋值顺序
        lock[]，初始为00，遇到free变量变为01，后面的都为11
*/

module decision #(
        parameter NUM_VARS = 8,
        parameter WIDTH_LVL = 16
    )
    (
        input                             clk, 
        input                             rst, 

        input                             load_lvl_en,
        input      [WIDTH_LVL-1:0]        load_lvl_i,

        input                             decision_pulse,
        input      [NUM_VARS*3-1:0]       vars_value_i,
        output reg [NUM_VARS-1:0]         index_decided_o,
        output reg                        decision_done,

        input                             apply_bkt_i,
        input      [WIDTH_LVL-1:0]        bkt_lvl_i,
        output     [WIDTH_LVL-1:0]        cur_lvl_o
    );

    reg [WIDTH_LVL-1:0]                   next_lvl_r;

    always @(posedge clk) begin
        if(~rst)
            next_lvl_r <= -1;
        else if(load_lvl_en)                      //load
            next_lvl_r <= load_lvl_i+1; //load的是cur_lvl，所以要+1
        else if(decision_pulse)                   //决策
            next_lvl_r <= next_lvl_r+1;
        else if(apply_bkt_i)                      //回退
            next_lvl_r <= bkt_lvl_i;
        else
            next_lvl_r <= next_lvl_r;
    end

    assign cur_lvl_o = next_lvl_r-1;

    wire [NUM_VARS-1:0] index_w;

    dcd_in_var8 dcd_in_var8(
        .value_i   (vars_value_i),
        .lock_cnt_i(2'd0),
        .lock_cnt_o(),
        .index_o   (index_w)
    );

    always @(posedge clk)
    begin
        if(~rst)
            index_decided_o <= 0;
        else if(decision_pulse)
            index_decided_o <= index_w;
        else
            index_decided_o <= 0;
    end

    always @(posedge clk)
    begin
        if(~rst)
            decision_done <= 0;
        else if(decision_pulse)
            decision_done <= 1;
        else
            decision_done <= 0;
    end

endmodule
