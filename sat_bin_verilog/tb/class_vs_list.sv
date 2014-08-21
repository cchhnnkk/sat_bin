/**
*	变量状态列表类
*	提供一些var state相关的数据转换的功能
*/
class class_vs_list #(int nv = 8, int width_lvl = 16, int width_vs = width_lvl+3);

	int value[nv];
	int implied[nv];
	int level[nv];

	function new();
		reset();
	endfunction

	function void reset();
		for (int i = 0; i < nv; ++i)
		begin
			value[i] = 0;
			implied[i] = 0;
			level[i] = 0;
		end
	endfunction

	function int get_len();
		int len = 0;
		for (int i = 0; i < nv; ++i)
		begin
			if(value[i]!=0) begin
				len += 1;
			end
		end
		get_len = len;
	endfunction

	function void get(output [nv*width_vs-1:0]  data);
		bit [2:0] v;
		bit [width_lvl-1:0] l;
        bit [nv-1:0][width_vs-1:0] data2; //合并数据
		for (int i = 0; i < nv; ++i)
		begin
			v[2:1] = value[i];
			v[0] = implied[i];
			l = level[i];
			data2[i] = {v, l};
		end
        data = data2;
	endfunction

	function void set(input [nv*width_vs-1:0] data);
		bit [2:0] v;
		bit [width_lvl-1:0] l;
        bit [nv-1:0][width_vs-1:0] data2; //合并数据
        data2 = data;
		for (int i = 0; i < nv; ++i)
		begin
			{v, l} = data2[i];
			value[i] = v[2:1];
			implied[i] = v[0];
			level[i] = l;
		end
	endfunction

	function void set_separate(int value1[nv], int implied1[nv], int level1[nv]);
		for (int i = 0; i < nv; ++i)
		begin
			value[i] = value1[i];
			implied[i] = implied1[i];
			level[i] = level1[i];
		end
	endfunction

	function void display();
        string str_all = "";
        string str;
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", value[i]);
			// str.itoa(value[i]);
            str_all = {str_all, str, " "};
		end
        $display("\tvalue = %s", str_all);

        str_all = "";
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", implied[i]);
			// str.itoa(implied[i]);
            str_all = {str_all, str, " "};
		end
        $display("\timply = %s", str_all);

        str_all = "";
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", level[i]);
			// str.itoa(level[i]);
            str_all = {str_all, str, " "};
		end
        $display("\tlevel = %s", str_all);

	endfunction

	function void display_index(bit [nv-1:0] index);
		for (int i = 0; i < nv; ++i)
		begin
			if(index[i]!=0) begin
				$display("\tvar id=%1d, value=%1d, implied=%1d, level=%1d",
					i, value[i], implied[i], level[i]);
			end
		end
	endfunction

endclass
