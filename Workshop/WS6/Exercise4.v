module Exercise4(input CLOCK_50, input [3:3] KEY, output [9:0] LEDR);
	wire c = CLOCK_50; 
	assign LEDR[9:4] = 0;
	wire in; 
	
	Synchroniser sync(.clk(c), .in(!KEY[3]), .out(in));

	wire [1:0] mode; 
	
	ModeSelector ms(.clk(c), .in(in), .mode(mode));

	genvar i; 
	generate 
		for(i=0; i<=3; i=i+1) begin :leds 
			assign LEDR[i] = (mode == i); 
		end 
	endgenerate 
endmodule

module ModeSelector(input clk, in, output reg [1:0] mode); 
	localparam millisecond = 50; 
	localparam half_second = 500*millisecond; 
	localparam two_seconds = 4*half_second; 
	localparam size = $clog2(two_seconds);  
	
	reg [size-1:0] cnt = 0, next_cnt; 
	reg [1:0] next_mode; 
	
	always @(posedge clk) {mode, cnt} <= {next_mode, next_cnt}; 

	always @(*) begin 
		next_cnt = cnt+1'b1; 
		next_mode = mode; 
		if (in) begin 
			if (cnt == millisecond) next_mode = (mode == 2'd0) ? 2'd1 : 2'd0; 
			if (cnt == half_second) next_mode = 2'd2; 
			if (cnt >= two_seconds) begin 
				next_cnt = cnt; 
				next_mode = 2'd3; 
			end 
		end 
		else begin 
			next_cnt = 0; 
			if (cnt >= two_seconds) next_mode = 2'd0; 
		end 
	end 
endmodule



