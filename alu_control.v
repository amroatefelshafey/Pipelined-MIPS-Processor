module alu_control( 
					input [1:0] ALUOp, 
					input [5:0] funct, 
					output reg [2:0] ALUCtl
					);

always@(*) begin

	case(ALUOp)

	2'b00: ALUCtl = 3'b010;   // ADD  (LW/SW/JAL)   opcode = 0x23 , 0x2B

	2'b01: ALUCtl = 3'b110;   // SUB  (BEQ/SLTI compare)       opcode = 0x04

	2'b10: begin             // R-TYPE        opcode = 0x00

		casex(funct)

			6'b100x00: ALUCtl = 3'b010;   // ADD   funct = 0x20
			6'b100x10: ALUCtl = 3'b110;   // SUB   funct = 0x22
			6'b011x01: ALUCtl = 3'b000;   // MULTU funct = 0x19
			6'b000x00: ALUCtl = 3'b111;   // SLL   funct = 0x00

			default:   ALUCtl = 3'b010;   // default to avoid latch 
		
		endcase
		end

	2'b11: ALUCtl = 3'b001;   // ORI  opcode = 0x0D

	default: ALUCtl = 3'b010;  // default to avoid latch 

	endcase

end

endmodule