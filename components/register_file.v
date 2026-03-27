module register_file(
	input CLK,
	input [4:0] rs, rt, //source & target registers
	input [4:0] Write_Reg,  //The register to write back to
	input [31:0] Write_Data, //Data written to the specified register by Write_Reg
	input RegWrite, //Write Enable
	output [31:0] Read_Data1, Read_Data2); //Read_Data1->rs, Read_Data2->rt
	
	reg [31:0] R [31:0]; //32, 32-bit GPR's of MIPS
	
	always@(posedge CLK) begin
		if(RegWrite && Write_Reg != 0)
			R[Write_Reg] = Write_Data;
	end //end always
	
	
	
	assign Read_Data1 = R[rs];
	assign Read_Data2 = R[rt];

endmodule

