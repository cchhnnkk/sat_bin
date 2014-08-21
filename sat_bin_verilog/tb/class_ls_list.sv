/**
*	层级状态列表类
*	提供一些lvl state相关的数据转换的功能
*/
class class_ls_list #(int nv = 8, int width_bini = 10, int width_ls = width_bini+1);

	int dcd_bin[nv];
	int has_bkt[nv];

	function new();
		reset();
	endfunction

	function void reset();
		for (int i = 0; i < nv; ++i)
		begin
			dcd_bin[i] = 0;
			has_bkt[i] = 0;
		end
	endfunction

	function void get(output [nv*width_ls-1:0]  data);
		bit [width_bini-1:0] bin;
		bit bkt;
        bit [nv-1:0][width_ls-1:0] data2; //合并数据
		for (int i = 0; i < nv; ++i)
		begin
			bin = dcd_bin[i];
			bkt = has_bkt[i];
			data2[i] = {bin, bkt};
		end
        data = data2;
	endfunction

	function void set(input [nv*width_ls-1:0] data);
		bit [width_bini-1:0] bin;
		bit bkt;
        bit [nv-1:0][width_ls-1:0] data2; //合并数据
        data2 = data;
		for (int i = 0; i < nv; ++i)
		begin
			{bin, bkt} = data2[i];
			dcd_bin[i] = bin;
			has_bkt[i] = bkt;
		end
	endfunction

	function void set_separate(int dcd_bin1[nv], int has_bkt1[nv]);
		for (int i = 0; i < nv; ++i)
		begin
			dcd_bin[i] = dcd_bin1[i];
			has_bkt[i] = has_bkt1[i];
		end
	endfunction

	function void display();
        string str_all = "";
        string str;
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", dcd_bin[i]);
			// str.itoa(dcd_bin[i]);
            str_all = {str_all, str, " "};
		end
        $display("\tdcd_bin = %s", str_all);

        str_all = "";
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", has_bkt[i]);
			// str.itoa(has_bkt[i]);
            str_all = {str_all, str, " "};
		end
        $display("\thas_bkt = %s", str_all);
	endfunction

endclass
