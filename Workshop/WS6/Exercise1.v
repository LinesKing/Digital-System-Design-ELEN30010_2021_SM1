module Exercise1(
	input [0:0] SW,
	input CLOCK_50,
	output [7:0] cnt, cnt_raw,
	output [6:0] HEX5, HEX4, HEX1, HEX0);
	
	wire c = CLOCK_50;
	
	wire debounced_in, debounced_out;
	Synchroniser sync_in(.clk(c), .in(SW[0]), .out(debounced_in));
	Debouncer db(.clk(c), .in(debounced_in), .out(debounced_out));
	
	wire transDetec, transDetec_raw;
	TransitionDetector td(.clk(c), .in(debounced_out), .out(transDetec));
	TransitionDetector td_raw(.clk(c), .in(debounced_in), .out(transDetec_raw));
	
//	wire [7:0] cnt, cnt_raw;
	Counter #(8) counter(.clk(c), .in(transDetec), .out(cnt));
	Counter #(8) counter_raw(.clk(c), .in(transDetec_raw), .out(cnt_raw));
	
	SSeg ss4(.bin(cnt[3:0]), .segs(HEX4));
	SSeg ss5(.bin(cnt[7:4]), .segs(HEX5));
	SSeg ss0(.bin(cnt_raw[3:0]), .segs(HEX0));
	SSeg ss1(.bin(cnt_raw[7:4]), .segs(HEX1));
endmodule	

module Synchroniser(clk, in, out);
	parameter n = 1;
	input clk;
	input [n-1:0] in;
	output reg [n-1:0] out;
	
	reg [n-1:0] buff;
	always @(posedge clk) begin
		buff <= in;
		out <= buff;
	end
endmodule

module TransitionDetector(input clk, in, output out);
	reg prev;
	always @(posedge clk)
		prev <= in;
	assign out = prev ^ in;
endmodule

module Counter
	#(parameter n = 1)
	(input clk, 
	input in, 
	output reg [n-1:0] out = 0);
	
	always @(posedge clk)
		if(in) out <= out + 1'b1;
endmodule

module SSeg (input [3:0] bin, output reg [6:0] segs);
    always @(*)
			case(bin)
				4'b0000: segs = ~7'b0111111;
				4'b0001: segs = ~7'b0000110;
				4'b0010: segs = ~7'b1011011;
				4'b0011: segs = ~7'b1001111;
				4'b0100: segs = ~7'b1100110;
				4'b0101: segs = ~7'b1101101;
				4'b0110: segs = ~7'b1111101;
				4'b0111: segs = ~7'b0000111;
				4'b1000: segs = ~7'b1111111;
				4'b1001: segs = ~7'b1101111;
				4'b1010: segs = ~7'b1110111;
				4'b1011: segs = ~7'b1111100;
				4'b1100: segs = ~7'b0111001;
				4'b1101: segs = ~7'b1011110;
				4'b1110: segs = ~7'b1111001;
				4'b1111: segs = ~7'b1110001;
			endcase
endmodule

module Debouncer(input clk, in, output reg out = 0);
	localparam millisecond = 50000; //  1ms/(1/50M)
	localparam period = 10*millisecond;
	localparam size = $clog2(period);
	
	reg [size-1:0] cnt = 0, next_cnt;
	reg next_out;
	
	always @(posedge clk)
		{out, cnt} <= {next_out, next_cnt};
	
	always @(*) begin
		next_out = out;
		next_cnt = (in == out) ? 1'b0 : cnt + 1'b1;
		
		if (next_cnt == period) begin
			next_out = !out;
			next_cnt = 0;
		end
	end
endmodule





