`timescale 1ns/1ps

module test_LED;
    reg gen_A, gen_B;
	 wire out_x, out_y, out_z;
	 integer i;
	 
	 Exercise1 LED(.A(gen_A), .B(gen_B), .x(out_x), .y(out_y), .z(out_z));
	 
	 initial begin
	     gen_A = 0; gen_B = 0;
		  for(i = 1; i <= 4; i = i + 1) begin
		  # 10 $display(gen_A, gen_B, , out_x, out_y ,out_z);
		  gen_B = (i % 1 == 0)? !gen_B: gen_B;
		  gen_A = (i % 2 == 0)? !gen_A: gen_A;
		end
	 end
endmodule
