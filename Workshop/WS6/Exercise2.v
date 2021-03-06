module Exercise2( 
	input CLOCK_50, 
	input [0:0] SW, 
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	
	wire c = CLOCK_50;
	reg [39:0] mem = 40'h0987654321;
	
	wire [5:0] e; 
	wire [23:0] d; 

	RollingDisplay rd(.clk(c), .mem(mem), .fast(SW[0]), .d(d), .e(e));
	
	SSegEn s0(.bin(d[3:0]), .en(e[0]), .segs(HEX0)); 
	SSegEn s1(.bin(d[7:4]), .en(e[1]), .segs(HEX1)); 
	SSegEn s2(.bin(d[11:8]), .en(e[2]), .segs(HEX2)); 
	SSegEn s3(.bin(d[15:12]), .en(e[3]), .segs(HEX3)); 
	SSegEn s4(.bin(d[19:16]), .en(e[4]), .segs(HEX4)); 
	SSegEn s5(.bin(d[23:20]), .en(e[5]), .segs(HEX5)); 
endmodule

module RollingDisplay( 
	input clk, fast, 
	input [39:0] mem, 
	output reg [5:0] e, 
	output reg [23:0] d);
	
	localparam MaxCnt = 20_000; //0.4ms
	localparam n = $clog2(MaxCnt); 
	localparam FastMC = 4_000; //0.08ms
	
	reg [3:0] pos = 0, next_pos; 
	reg [n-1:0] cnt = 0, next_cnt; 
	
	always @(posedge clk) 
		{pos, cnt} <= {next_pos, next_cnt}; 
	
	always @(*) begin 
		next_cnt = cnt+1'd1; 
		next_pos = pos; 
		if (next_cnt >= (fast ? FastMC : MaxCnt)) begin 
			next_cnt = 0; 
			next_pos = pos+1'd1; 
		end 
	end
	
	always @(*) begin :need_name_to_define_local_variable 
		integer i; 
		for(i=0; i<=5; i=i+1) begin 
			e[i] = 0; 
			d[i*4 +: 4] = 4'bxxxx; //d[i*4+3:i*4]
			if ((1+i <= pos) && (pos <= 10+i)) begin 
				e[i] = 1; 
				d[i*4 +: 4] = mem[(pos-i-1)*4 +: 4]; 
			end 
		end 
	end 
endmodule

module SSegEn(
	input [3:0] bin, 
	input en, 
	output reg [6:0] segs); 
	
	always @(*) 
		if (en) 
			case (bin) 
				0: segs = 7'b100_0000; 
				1: segs = 7'b111_1001; 
				2: segs = 7'b010_0100; 
				3: segs = 7'b011_0000; 
				4: segs = 7'b001_1001; 
				5: segs = 7'b001_0010; 
				6: segs = 7'b000_0010; 
				7: segs = 7'b111_1000; 
				8: segs = 7'b000_0000; 
				9: segs = 7'b001_1000; 
				10: segs = 7'b000_1000; 
				11: segs = 7'b000_0011; 
				12: segs = 7'b100_0110; 
				13: segs = 7'b010_0001; 
				14: segs = 7'b000_0110; 
				15: segs = 7'b000_1110; 
			endcase 
		else segs = 7'b111_1111; 
endmodule
