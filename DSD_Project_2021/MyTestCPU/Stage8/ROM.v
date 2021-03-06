`include "CPU.vh"

// Step 2 of Stage 5:
// 	Asynchronous ROM (Program Memory)
module AsyncROM(input [7:0] addr, output reg [34:0] data);
	always @(addr)
		case (addr)
			0: data = {`MOV, `PUR, `NUM, 8'd 0, `REG, `DOUT, `N8};
			4: data = {`ACC, `UAD, `REG, `DOUT, `NUM, 8'd15, `N8};
			8: data = {`JMP, `UNC, `N10, `N10, 8'd 4};
			default: data = 35'b0; // Default instruction is a NOP
		endcase
endmodule
