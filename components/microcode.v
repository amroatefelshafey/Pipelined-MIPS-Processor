module microcode(input [5:0] opcode, funct, output reg [13:0] control);

always @(*) begin

casex(opcode)

6'b000000: casex (funct)   //R-TYPE
            6'b011x01: control = 14'bx00x0000001x10;  //multu
			6'b000x00: control = 14'b11001000000x10;  //sll
			
			default: control = 14'b10001000000x10; // (add, sub) might switch it to two cases 
			endcase
			

6'b100011: control = 14'b00111100000100; // LW

6'b101011: control = 14'bx01x0010000100; // SW

6'b001101: control = 14'b00101000000011; // ORI (zero extend)

6'b001010: control = 14'b00101000100101; // SLTI (sign extend)

6'b000100: control = 14'bx00x0001000101; // BEQ

6'b000011: control = 14'bxxx00000010x00; // JAL

default: control = 14'bxxxxxxxxxxxxxx;   // default to avoid latch

endcase

end

endmodule
