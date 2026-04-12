module ALU(
			input CLK, RST,
			input [31:0] A, B,
			input [2:0] ALUCtl,
			output reg [31:0] OUT,
			output [63:0] Mult_OUT,
			output Sign, Mult_READY
			);

	wire M, Cout, Start;
	wire [31:0] Sum, Shift_Result, OR_Result;
	//wire [63:0] Mult_Result;

	assign Start = ~ALUCtl[1] & ~ALUCtl[0]; // Signal the start of a multu operation
	assign M = ALUCtl[2];

	assign Shift_Result = B << A; // B is shifted because A is rs, and sll does R[rd] = R[rt] << shamt (B is rt, A is shamt)
	assign OR_Result = A | B;
	Adder_Subtractor Adder_Subtractor(A, B, M, Sum, Cout);
	Seq_Multiplier Multiplier(CLK, RST, Start, A, B, Mult_OUT, Mult_READY);

	always@(*) begin

		casex(ALUCtl)
		
		//3'bx00: Mult_OUT = Mult_Result;
		3'bx01: OUT = OR_Result;
		3'bx10: OUT = Sum;
		3'bx11: OUT = Shift_Result;
		default: OUT = 32'bx;
		
		endcase
	end
	
	assign Sign = OUT[31];

endmodule
