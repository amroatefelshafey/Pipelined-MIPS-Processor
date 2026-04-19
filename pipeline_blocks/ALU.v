module ALU(
	input CLK, RST,			// These are added for the sequential multiplier
	input [31:0] A, B,		
	input [2:0] ALUCtl,
	output reg [31:0] OUT,	// 32-bit ALU Result for ALU operations except for multu
	output [63:0] Mult_OUT,	// 64-bit multiplication result
	output Sign, Mult_READY	// Sign is for slti, Mult_READY is to indicate multiplication is done
	);

	wire M, Cout, Start;
	wire [31:0] Sum, Shift_Result, OR_Result;

	assign Start = ~ALUCtl[1] & ~ALUCtl[0]; // Signal the start of a multu operation
	assign M = ALUCtl[2];					// MSB of ALUCtl determines whether we +/-

	assign Shift_Result = B << A; // B is shifted because A is rs, and sll does R[rd] = R[rt] << shamt (B is rt, A is shamt)
	assign OR_Result = A | B;
	Adder_Subtractor Adder_Subtractor(A, B, M, Sum, Cout); // Instantiates the Adder_Subtractor unit
	Seq_Multiplier Multiplier(CLK, RST, Start, A, B, Mult_OUT, Mult_READY);	// Instantiate sequential MIPS multiplier unit

	always@(*) begin

		casex(ALUCtl)
		
		3'bx01: OUT = OR_Result;
		3'bx10: OUT = Sum;
		3'bx11: OUT = Shift_Result;
		default: OUT = 32'bx;
		
		endcase
	end
	
	assign Sign = OUT[31];

endmodule
