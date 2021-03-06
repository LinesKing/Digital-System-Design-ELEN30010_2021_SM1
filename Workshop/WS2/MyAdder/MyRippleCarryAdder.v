module MyRippleCarryAdder(
	input [3:0]a,
	input [3:0]b,
	output [3:0]sum,
	output carry);
	
	wire [2:0]c;
	
	MyHalfAdder LSB(.a(a[0]), .b(b[0]), .sum(sum[0]), .carry(c[0]));
	MyFullAdder TSB(.a(a[1]), .b(b[1]), .c_in(c[0]), .sum(sum[1]), .carry(c[1]));
	MyFullAdder SSB(.a(a[2]), .b(b[2]), .c_in(c[1]), .sum(sum[2]), .carry(c[2]));
	MyFullAdder MSB(.a(a[3]), .b(b[3]), .c_in(c[2]), .sum(sum[3]), .carry(carry));
	
endmodule	
	