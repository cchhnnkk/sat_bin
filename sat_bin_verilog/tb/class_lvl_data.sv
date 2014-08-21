/**
*	变量状态列表类
*	提供一些var state相关的数据转换的功能
*/
class class_lvl_data #(int nv = 8, int width_lvl = 16);

	int level[nv];

	function new();
		reset();
	endfunction

	function void reset();
		for (int i = 0; i < nv; ++i)
			level[i] = 0;
	endfunction

	function void get(output [nv*width_lvl-1:0]  data);
        bit [nv-1:0][width_lvl-1:0] data2; //合并数据
		for (int i = 0; i < nv; ++i)
		begin
			data2[i] = level[i];
		end
        data = data2;
	endfunction

	function void set(input [nv*width_lvl-1:0] data);
        bit [nv-1:0][width_lvl-1:0] data2; //合并数据
        data2 = data;
		for (int i = 0; i < nv; ++i)
		begin
			level[i] = data2[i];
		end
	endfunction

	function void set_lvls(int l[nv]);
		foreach (l[i]) begin
			level[i] = l[i];
		end
	endfunction

	function void set_separate(int value1[nv], int implied1[nv], int level1[nv]);
		for (int i = 0; i < nv; ++i)
		begin
			level[i] = level1[i];
		end
	endfunction

	function void display();
        string str_all = "";
        string str;
        str_all = "";
		for (int i = 0; i < nv; ++i)
		begin
			$sformat(str, "%1d", level[i]);
			// str.itoa(level[i]);
            str_all = {str_all, str, " "};
		end
        $display("\tlevel = %s", str_all);

	endfunction

endclass
