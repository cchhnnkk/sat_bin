class class_clause_data #(int size = 8);

	parameter MAX = 9;

	bit [2:0] data[size];
	int value[size];
	int implied[size];

	function void reset();
		for (int i = 0; i < size; ++i)
		begin
			data[i] = 0;
			value[i] = 0;
			implied[i] = 0;
		end
	endfunction

	function void get(output [3*size-1:0]  data);
		bit [2:0] v;
        bit [size-1:0][2:0] data2; //合并数据
		for (int i = 0; i < size; ++i)
		begin
			v[2:1] = value[i];
			v[0] = implied[i];
			data2[i] = v;
		end
        data = data2;
	endfunction

	function void set(input [3*size-1:0] data);
		bit [2:0] v;
        bit [size-1:0][2:0] data2; //合并数据
        data2 = data;
		for (int i = 0; i < size; ++i)
		begin
			v = data2[i];
			value[i] = v[2:1];
			implied[i] = v[0];
		end
	endfunction

	function void set_clause(input [2*size-1:0] data);
        bit [size-1:0][1:0] data2; //合并数据
        data2 = data;
		for (int i = 0; i < size; ++i)
		begin
			value[i] = data2[i];
		end
	endfunction

	function void get_clause(output [2*size-1:0] data);
        bit [size-1:0][1:0] data2; //合并数据
		for (int i = 0; i < size; ++i)
		begin
			data2[i] = value[i];
		end
        data = data2;
	endfunction

	function int get_len();
		int len = 0;
		for (int i = 0; i < size; ++i)
		begin
			if(value[i]!=0) begin
				len += 1;
			end
		end
		if(len == 0) begin
			len = MAX;
		end
		get_len = len;
	endfunction

	function void set_lits(int cl[size]);
		foreach (cl[i]) begin
			value[i] = cl[i];
		end
	endfunction

	function void set_lit(input int index, input [1:0] data);
		value[index] = data;
	endfunction

	function void set_index(input int index, input [2:0] data);
		value[index] = data[2:1];
		implied[index] = data[0];
	endfunction

	function void set_imps(int d[size]);
		foreach (d[i]) begin
			implied[i] = d[i];
		end
	endfunction

	function void get_lit(input int index, output [1:0] data);
		data = value[index];
	endfunction

	function void assert_index(int index, bit [2:0] data);
		bit [2:0] d;
		d[2:1] = value[index];
		d[0] = implied[index];
		assert(data == d);
	endfunction

	function void display();
		display_lits_a();
		display_implied_a();
	endfunction

	function void display_lits();
        string str;
        bit [1:0] d;
        string str_all = "";
		for (int i = 0; i < size; ++i)
		begin
			d = value[i];
			$sformat(str, "%d", d);
            str_all = {str_all, str, " "};
		end
        $display("--\tvalue = %s", str_all);
	endfunction

	function void display_lits_a();
        string str;
        bit [1:0] d;
        string str_all = "";
		for (int i = 0; i < size; ++i)
		begin
			d = value[i];
			$sformat(str, "%d", d);
            str_all = {str_all, str, " "};
		end
        $display("\tvalue = %s", str_all);
	endfunction

	function void display_implied_a();
        string str;
        bit d;
        string str_all = "";
		for (int i = 0; i < size; ++i)
		begin
			d = implied[i];
			$sformat(str, "%d", d);
			// str.itoa(data[i*3]);
            str_all = {str_all, str, " "};
		end
        $display("\timply = %s", str_all);
	endfunction

endclass
