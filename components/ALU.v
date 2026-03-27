module ALU(
			input [31:0] A, B,
			input [2:0] ALUCtl,
			output reg [31:0] Hi_OUT, Lo_OUT,
			output Carry, Zero, Sign
			);

wire M, c;
wire [31:0] Sum, Shift_Result, OR_Result;
wire [63:0] Mult_Result;


assign M = ALUCtl[2];

assign Shift_Result = B << A; // B is shifted because A is rs, and sll does R[rd] = R[rt] << shamt (B is rt, A is shamt)
assign OR_Result = A | B;
assign Mult_Result = A * B; 
Adder_Subtractor Adder_Subtractor(A, B, M, Sum, Carry);

always@(*)
begin

	casex(ALUCtl)
	
		3'bx00: {Hi_OUT, Lo_OUT} = Mult_Result;
		3'bx01: Lo_OUT = OR_Result;
		3'bx10: Lo_OUT = Sum;
		3'bx11: Lo_OUT = Shift_Result;
		default: {Hi_OUT, Lo_OUT} = 32'bx;
		
	endcase
end

assign Carry = (ALUCtl == 3'bx10) ? c : 0;
assign Zero = ~|Lo_OUT;
assign Sign = Lo_OUT[31];

endmodule
