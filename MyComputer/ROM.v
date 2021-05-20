`include "CPU.vh"

//////////////////// Part 2 /////////////////////
`define STACK0 8'd0  // Stack 0
`define STACK1 8'd1  // Stack 1
`define STACK2 8'd2  // Stack 2
`define STACK3 8'd3  // Stack 3
`define STKSIZ 8'd4  // Stack size

`define STKEMP 8'd0  // Stack is empty
`define STK1EL 8'd1  // One element is on the stack
`define STK2EL 8'd2  // Two elements are on the stack
`define STK3EL 8'd3  // Three elements are on the stack
`define STK4EL 8'd4  // Four elements are on the stack

`define POP 8'd2  // Pop
`define ADD 8'd1  // Addition
`define MLT 8'd0  // Multiplication

// 	Asynchronous ROM (Program Memory)
module AsyncROM(input [7:0] addr, output reg [34:0] data);
	always @(addr)
		case (addr)
			// Reset: clear stacks elements and size, register GOUT and Dout.
			0  : data = set(`GOUT, `N8);								// Initialisation. After a Reset, the CPU Registers will be in an unknown state. 
			1  : data = set(`STACK0, `N8);  							
			2  : data = set(`STACK1, `N8);
			3  : data = set(`STACK2, `N8);
			4  : data = set(`STACK3, `N8);
			5  : data = set(`STKSIZ, `N8);  							// Set the stack size to zero, and turn off the LEDs and display. 

			6  : data = set(`DOUT, `N8);
			7  : data = jmp(10);             	 					// Jump to “wait”.
			
			// Wait
			10 : data = atc(`SMPL, 20);  								// Jump to “push” if the Push button has been released.
			11 : data = atc(`POP, 50);									// Jump to “pop” if the Pop button has been released.
			12 : data = atc(`ADD, 70);    							// Jump to “add” if the Addition button has been released.
			13 : data = atc(`MLT, 90);									// Jump to “mult” if the Multiplication button has been released.
			14 : data = jmp(10);											// Jump to “wait”.
			
			// Push
			20 : data = mov(`STACK2, `STACK3);  					// Move stack up.
			21 : data = mov(`STACK1, `STACK2);
			22 : data = mov(`STACK0, `STACK1);
			23 : data = mov(`DINP, `STACK0);  						// Move `DINP to stack[0].
			24 : data = mov(`STACK0, `DOUT);  						// Display stack[0] on 7-segment display.
			25 : data = jmp_eq(`STKSIZ, 8, 40);						// Jump to “overflow” if Register[4] equals 8.
			26 : data = clr_bit(`GOUT, `OFLW);  					// Turn Stack Overflow LED off.
			27 : data = clr_bit(`GOUT, `SHFT);  					// Turn Arithmetic Overflow LED off.
			
			28 : data = jmp_eq(`STKSIZ, 0, 31);						// Jump to “overflow” if Register[4] equals 8.
			29 : data = mov_shift(`SHL, `STKSIZ, `STKSIZ);     // Shift Register[4] to the left. (STACK SIZE >= 1)
			30 : data = jmp(110);		
			
			31 : data = mov_shift(`SHR, `STKSIZ, `STKSIZ);		// Shift Register[4] to the right.
			32 : data = set(`STKSIZ, 1);     						// Shift Register[4] to the left. (STACK SIZE = 0)
			33 : data = jmp(110);						            // Send the contents of Register[4] to the LED pins.
			
			               // Send the contents of Register[4] to the LED pins.
			
			// Overflow: stack
			40 : data = set_bit(`GOUT, `OFLW);  					// Turn Stack Overflow LED on.
			41 : data = clr_bit(`GOUT, `SHFT);  					// Turn Arithmetic Overflow LED off.
			42 : data = jmp(10);											// Jump to “wait”.
			
			// Pop
			50 : data = jmp_eq(`STKSIZ, 0, 10);						// Jump to “wait” if Register[4] equals 0.
			51 : data = clr_bit(`GOUT, `OFLW);  					// Turn Stack Overflow LED off.
			52 : data = clr_bit(`GOUT, `SHFT);  					// Turn Arithmetic Overflow LED off.
			53 : data = mov(`STACK1, `STACK0);                 // Shift the stack down.
			54 : data = mov(`STACK2, `STACK1);
			55 : data = mov(`STACK3, `STACK2);
			56 : data = mov_shift(`SHR, `STKSIZ, `STKSIZ);		// Shift Register[4] to the right.
			57 : data = set_bit(`STKSIZ, `DVAL);             	// Send the contents of Register[4] to the LED pins
			58 : data = mov(`STKSIZ, `GOUT);
			59 : data = clr_bit(`STKSIZ, `DVAL);		
			60 : data = clr_bit(`GOUT, `DVAL);						// Turn off the 7-segment display ??
			61 : data = mov(`STACK0, `DOUT);							// Display stack[0] on the display.
			62 : data = jmp_eq(`STKSIZ, 0, 10); 					// Jump to “wait” if Register[4] equals zero	.
			63 : data = set_bit(`GOUT, `DVAL);						// Turn on the 7-segment display
			64 : data = jmp(10);											// Jump to “wait”.
			
			// Add
			70 : data = clr_bit(`GOUT, `SHFT);						// Turn off Arithmetic Overflow LED.
			71 : data = jmp_eq(`STKSIZ, 0, 10);						// Jump to “wait” if Register [4] equals 0 or 1.
			72 : data = jmp_eq(`STKSIZ, 1, 10);
			73 : data = acc_reg(`SAD, `STACK0, `STACK1);			// Stack[0] = Stack[0] + Stack[1].
			74 : data = mov(`STACK0, `DOUT);							// Display Stack[0] on the display.
			75 : data = jmp_eq(`FLAG, 8'b0000_0000, 78);			// Turn on Arithmetic Overflow LED if an overflow occurred ??
			76 : data = set_bit(`GOUT, `SHFT);  					// Turn Arithmetic Overflow LED on.

			77 : data = clr_bit(`GOUT, `OFLW);  					// Turn off Stack Overflow LED. 
			78 : data = mov(`STACK2, `STACK1);						// Move rest of stack down.
			79 : data = mov(`STACK3, `STACK2);																
			80 : data = mov_shift(`SHR, `STKSIZ, `STKSIZ);		// Shift Register[4] to the right.
			81 : data = jmp_eq(`FLAG, 8'b0000_0000, 83);			// Turn on Arithmetic Overflow LED if an overflow occurred ??
			82 : data = set_bit(`STKSIZ, `SHFT); 
			83 : data = jmp(110);										// Send the contents of Register[4] to the LED pins.
			
			// Mult
			90 : data = jmp_eq(`STKSIZ, 0, 10);						// Jump to “wait” if the stack is empty.
			91 : data = clr_bit(`GOUT, `SHFT);						// Turn off Arithmetic Overflow LED.
			92 : data = jmp_eq(`STKSIZ, 2, 100);					// Jump to “normal” if the stack has two or more elements.
			93 : data = jmp_eq(`STKSIZ, 4, 100);
			94 : data = jmp_eq(`STKSIZ, 8, 100);
			95 : data = set(`STACK0, `N8); 							// Set stack[0] to 0.
			96 : data = set(`DOUT, `N8);								// Display 0 on the 7-segment display.
			97 : data = jmp(10);											// Jump to “wait”.
			
			// Normal
			100: data = acc_reg(`SMT, `STACK0, `STACK1); 		// Stack[0] = Stack[0] * Stack[1].
			101: data = jmp_eq(`FLAG, 8'b0000_0000, 104);		// Turn on Arithmetic Overflow LED if an overflow occurred ??
			102: data = set_bit(`GOUT, `SHFT);  					// Turn Arithmetic Overflow LED on.			
			103: data = clr_bit(`GOUT, `OFLW);  					// Turn off Stack Overflow LED.
			
			104: data = mov(`STACK0, `DOUT);							// Display Stack[0] on the display.
			105: data = mov(`STACK2, `STACK1);						// Move rest of stack down.
			106: data = mov(`STACK3, `STACK2);																
			107: data = mov_shift(`SHR, `STKSIZ, `STKSIZ);		// Shift Register[4] to the right.
			108: data = jmp_eq(`FLAG, 8'b0000_0000, 110);		// Turn on Arithmetic Overflow LED if an overflow occurred ??
			109: data = set_bit(`STKSIZ, `SHFT); 

			
			// Send the contents of Register[4] to the LED pins
			110: data = set_bit(`STKSIZ, `DVAL);             	
			111: data = mov(`STKSIZ, `GOUT);
			112: data = clr_bit(`STKSIZ, `DVAL);
			113: data = clr_bit(`STKSIZ, `SHFT);
			114: data = jmp(10);
			
			default: data = 35'b0;
			
			// Test manual input
			// 0 : data = set(`FLAG, 128);
			// 1 : data = mov(`FLAG, `GOUT);
			// 2 : data = mov(`DINP, `DOUT);
			// 3 : data = jmp(1);

			// Test ATC
			// 0 : data = set(`DOUT, 1);
			// 1 : data = set_bit(`GOUT, `DVAL);
			// 4 : data = {`MOV, `SHL, `REG, `DOUT, `REG, `DOUT, `N8};
			// 8 : data = atc(`SHFT, 16);
			// 12: data = jmp(4);
			// 16: data = set(`DOUT, 250);
			// 20: data = acc(`UAD, `DOUT, 1);
			// 24: data = atc(`OFLW, 8);
			// 28: data = jmp(20);

			// Test Jump
			// 0 : data = {`MOV, `PUR, `NUM, 8'd 1, `REG, `DOUT, `N8};
			// 4 : data = {`ACC, `SMT, `REG, `DOUT, `NUM, -8'd 2, `N8};
			// 7 : data = {`JMP, `SLT, `REG, `DOUT, `NUM, 8'd64, 8'd 4};
			// 10: data = {`MOV, `PUR, `NUM, 8'd 100, `REG, `DOUT, `N8};
			// 13: data = {`ACC, `SAD, `REG, `DOUT, `NUM, -8'd 7, `N8};
			// 16: data = {`JMP, `SLE, `NUM, 8'd 0, `REG, `DOUT, 8'd 13};
			// 20: data = {`JMP, `UNC, `N10, `N10, 8'd 0};

			// Test ACC
			// 0: data = {`MOV, `PUR, `NUM, 8'd 0, `REG, `DOUT, `N8};
			// 4: data = {`ACC, `UAD, `REG, `DOUT, `NUM, 8'd 15, `N8};
			// 8: data = {`JMP, `UNC, `N10, `N10, 8'd 4};

			// Test MOV
			// 0 : data = {`MOV,`PUR, `NUM, 8'd  0, `REG, `DOUT, `N8};
			// 1 : data = {`MOV,`PUR, `NUM, 8'd  1, `REG, `DOUT, `N8};
			// 2 : data = {`MOV,`PUR, `NUM, 8'd  2, `REG, `DOUT, `N8};
			// 3 : data = {`MOV,`PUR, `NUM, 8'd  3, `REG, `DOUT, `N8};
			// 4 : data = {`MOV,`PUR, `NUM, 8'd  4, `REG, `DOUT, `N8};
			// 5 : data = {`MOV,`PUR, `NUM, 8'd  5, `REG, `DOUT, `N8};
			// 6 : data = {`MOV,`PUR, `NUM, 8'd  6, `REG, `DOUT, `N8};
			// 7 : data = {`MOV,`PUR, `NUM, 8'd  7, `REG, `DOUT, `N8};
			// 8 : data = {`MOV,`PUR, `NUM, 8'd  8, `REG, `DOUT, `N8};
			// 9 : data = {`MOV,`PUR, `NUM, 8'd  9, `REG, `DOUT, `N8};

			// 10: data = {`MOV,`PUR, `NUM, 8'd 10, `REG, `DOUT, `N8};
			// 11: data = {`MOV,`PUR, `NUM, 8'd 11, `REG, `DOUT, `N8};
			// 12: data = {`MOV,`SHR, `NUM, 8'd 12, `REG, `DOUT, `N8};
			// 13: data = {`MOV,`PUR, `NUM, 8'd 13, `REG, `DOUT, `N8};
			// 14: data = {`MOV,`SHL, `NUM, 8'd 14, `REG, `DOUT, `N8};
			// 15: data = {`MOV,`PUR, `NUM, 8'd 15, `REG, `DOUT, `N8};
			// 16: data = {`MOV,`SHL, `NUM, 8'd 16, `REG, `DOUT, `N8};
			// 17: data = {`MOV,`SHR, `NUM, 8'd 17, `REG, `DOUT, `N8};
			// 18: data = {`MOV,`PUR, `NUM, 8'd 18, `REG, `DOUT, `N8};
			// 19: data = {`MOV,`PUR, `NUM, 8'd 19, `REG, `DOUT, `N8};

			// 20: data = {`JMP, `UNC, `N10, `N10, `N8};

		endcase

	//////////////////// Stage 10 ////////////////////
	//================================================
	//  syntactic sugar functions
	//================================================	
	function [34:0] set;
		input [7:0] reg_num;
		input [7:0] value;
		set = {`MOV, `PUR, `NUM, value, `REG, reg_num, `N8};
	endfunction
	
	function [34:0] mov;
		input [7:0] src_reg;
		input [7:0] dst_reg;
		mov = {`MOV, `PUR, `REG, src_reg, `REG, dst_reg, `N8};
	endfunction
	
	function [34:0] jmp;
		input [7:0] addr;
		jmp = {`JMP, `UNC, `N10, `N10, addr};
	endfunction
	
	function [34:0] atc;
		input [2:0] bit;
		input [7:0] addr;
		atc = {`ATC, bit, `N10, `N10, addr};
	endfunction
	
	function [34:0] acc;
		input [2:0] op;
		input [7:0] reg_num;
		input [7:0] value;
		acc = {`ACC, op, `REG, reg_num, `REG, value, `N8};
	endfunction
	
	//////////////////// Stage 11 ////////////////////
	function [34:0] set_bit;
		input [7:0] reg_num;
		input [2:0] bit;
		set_bit = {`ACC, `OR, `REG, reg_num, `NUM, 8'b1 << bit, `N8};
	endfunction
	
	function [34:0] clr_bit;
		input [7:0] reg_num;
		input [2:0] bit;
		clr_bit = {`ACC, `AND, `REG, reg_num, `NUM, ~(8'b1 << bit), `N8};
	endfunction
	
	//////////////////// Part 2 /////////////////////
	function [34:0] jmp_eq;
		 input [7:0] reg_num;
		 input [7:0] value;
		 input [7:0] addr;
		 jmp_eq = {`JMP, `EQ, `REG, reg_num, `NUM, value, addr};
	endfunction

	function [34:0] mov_shift;
		 input [2:0] op;
		 input [7:0] src_reg;
		 input [7:0] dst_reg;
		 mov_shift = {`MOV, op, `REG, src_reg, `REG, dst_reg, `N8};
	endfunction	
	
	function [34:0] acc_reg;
		 input [2:0] op;
		 input [7:0] reg1;
		 input [7:0] reg2;
		 acc_reg = {`ACC, op, `REG, reg1, `REG, reg2, `N8};
	endfunction

endmodule
