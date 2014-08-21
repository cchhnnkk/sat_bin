`timescale 1ns/1ps

`include "../src/debug_define.v"

module bram_param #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH      = 1024
)
(
  clka,
  wea,
  addra,
  dina,
  douta,
  clkb,
  web,
  addrb,
  dinb,
  doutb
);

input clka;
input [0 : 0] wea;
input [ADDR_WIDTH-1 : 0] addra;
input [DATA_WIDTH-1 : 0] dina;
output [DATA_WIDTH-1 : 0] douta;
input clkb;
input [0 : 0] web;
input [ADDR_WIDTH-1 : 0] addrb;
input [DATA_WIDTH-1 : 0] dinb;
output [DATA_WIDTH-1 : 0] doutb;

`ifdef DEBUG_bin_manager

    reg [DATA_WIDTH-1:0] data[DEPTH];

    reg[31:0] i;

    initial
        for(i=0; i<DEPTH; i++)
            data[i] = 0;

    reg [DATA_WIDTH-1 : 0] douta_r;
    reg [DATA_WIDTH-1 : 0] doutb_r;

    assign douta = douta_r;
    assign doutb = doutb_r;

    always @(posedge clka) begin
        douta_r <= data[addra];
    end

    always @(posedge clka) begin
        if(wea==1)
            data[addra] = dina;
        if(web==1)
            data[addrb] = dinb;
    end

    always @(posedge clkb) begin
        doutb_r <= data[addrb];
    end

    int j;
    task display(int istart, int iend);
        $display("\taddr:%1d-%1d", istart, iend-1);
        for(j=istart; j<iend; j++) begin
            $display("\t%6d:%b", j, data[j]);
        end
    endtask

    reg [2:0]     var_value;
    reg [15:0]    var_lvl;
    task display_vs(int istart, int iend);
        $display("\taddr:%1d-%1d", istart, iend-1);
        $display("\t%8s : %8s %8s", "addr", "value", "level");
        for(j=istart; j<iend; j++) begin
            {var_value, var_lvl} = data[j];
            $display("\t%8d : %8b %8d", j, var_value, var_lvl);
        end
    endtask

    reg [9:0] dcd_bin;
    reg       has_bkt;
    task display_ls(int istart, int iend);
        $display("\taddr:%1d-%1d", istart, iend-1);
        $display("\t%8s : %8s %8s", "addr", "dcd_bin", "has_bkt");
        for(j=istart; j<iend; j++) begin
            {dcd_bin, has_bkt} = data[j];
            $display("\t%8d : %8d %8d", j, dcd_bin, has_bkt);
        end
    endtask

    string str_var_value = "";
    string str = "";
    int var1;
    task display_var_value(int istart, int iend);
        str_var_value = "\t";
        for(j=istart; j<iend; j++) begin
            {var_value, var_lvl} = data[j];
            if(var_value[2:1]==1)
                var1 = -j;
            else
                var1 = j;
            $sformat(str,"%1d ", var1);
            str_var_value = {str_var_value, str};
        end
        $display(str_var_value);
    endtask

`else

    bram_w30_d1024 bram(
        .clka(clka),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta),
        .clkb(clkb),
        .web(web),
        .addrb(addrb),
        .dinb(dinb),
        .doutb(doutb)
    );

`endif

endmodule
