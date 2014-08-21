`include "../tb/class_clause_data.sv";

class class_clause_array #(int nc = 8, int nv = 8);

	class_clause_data #(nv) cdatas[nc];

	function new();
		for (int i = 0; i < nc; ++i)
		begin
			cdatas[i] = new();
		end
	endfunction

	function void reset();
		for (int i = 0; i < nc; ++i)
		begin
			cdatas[i].reset();
		end
	endfunction

	function int get_len(int index);
		get_len = cdatas[index].get_len();
	endfunction

	function void get(int index, output [3*nc-1:0]  data);
		cdatas[index].get(data);
	endfunction

	function void set(int index, input [3*nc-1:0] value);
		cdatas[index].set(value);
	endfunction

	function void get_clause(int index, output [2*nc-1:0]  data);
		cdatas[index].get_clause(data);
	endfunction

	function void set_clause(int index, input [2*nc-1:0] value);
		cdatas[index].set_clause(value);
	endfunction

	function void set_array(int bin1[nc][nv]);
		for (int i = 0; i < nc; ++i)
		begin
			cdatas[i].reset();
			cdatas[i].set_lits(bin1[i]);
		end
	endfunction

	function void get_learntc_inserti(output [nc-1:0] inserti);
		int max = 0;
		int index = 0;
		for (int i = nc/2; i < nc; ++i)
		begin
			int len = cdatas[i].get_len();
			$display("i=%d\tlen=%d", i, len);
			if(len > max) begin
				max = len;
				index = i;
			end
		end

		for (int i = 0; i < nc; ++i)
		begin
			if(i == index)
				inserti[i] = 1;
			else
				inserti[i] = 0;
		end
		$display("index=%d\t%b", index, inserti);
	endfunction


endclass
