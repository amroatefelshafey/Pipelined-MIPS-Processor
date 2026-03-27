module single_cycle(
	input clk, // Clock
	output [63:0] OUT
	);

//IF Signals
wire [31:0] instr;

//ID Signals
wire [4:0] Write_Reg;  //The register to write back to
wire [31:0] Write_Data; //Data written to the specified register by Write_Reg
wire [31:0] Read_Data1, Read_Data2;

//EX Signals
wire [31:0] A, B;
wire [2:0] ALUCtl;
wire Carry, Zero, Sign;

//MEM Signals
wire [31:0] read_data;


//Control Signals (14-bits)
wire RegDst, ALUSrcA, ALUSrcB, MemtoReg, RegWrite, MemRead, MemWrite, Branch, SLT, Jump;
wire HiLoWrite, ExtOp;
wire [1:0] ALUOp;

wire [31:0] imm32;
wire [31:0] pc_next;
wire [31:0] pc4;

//Non-General Purpose Registers
reg [31:0] pc, hi, lo;

assign pc4 = pc + 4;
//Module Instantiations

//Datapath
always@(posedge clk)
	pc <= pc_next; 
	
always@(posedge clk)
	if (HiLoWrite == 1)
		{hi,lo} <= OUT;
	
extender ext(instr[15:0], ExtOp, imm32);

instr_mem IM(pc, instr);

register_file RF(clk, instr[25:21], instr[20:16], Write_Reg, Write_Data, RegWrite, Read_Data1, Read_Data2);

ALU alu(A, B, ALUCtl, OUT[63:32], OUT[31:0], Carry, Zero, Sign);

data_memory DM(clk, OUT[31:0], Read_Data2, MemRead, MemWrite, read_data);


//Control
control_unit CU(instr[31:26], instr[5:0], RegDst, ALUSrcA, ALUSrcB, MemtoReg, RegWrite, MemRead, 
				MemWrite, Branch, SLT, Jump, HiLoWrite, ExtOp, ALUOp
				);
 
alu_control AC(ALUOp, instr[5:0], ALUCtl);






assign Write_Reg = Jump == 1 ? 5'd31: 
				   RegDst==1 ? instr[15:11]: instr[20:16];

assign A = Jump == 1 ? pc: 
		   ALUSrcA == 1 ? { {27{1'b0}}, instr[10:6] } : Read_Data1;

assign B = Jump == 1 ? 32'd8:
		   ALUSrcB == 1 ? imm32 : Read_Data2; 

assign Write_Data = SLT == 1 ? { {31{1'b0}},Sign }:
					MemtoReg == 1 ? read_data : OUT[31:0];

assign pc_next = Jump == 1 ? { pc4[31:28], instr[25:0], 2'b00 }: 
				(Branch & Zero) == 1 ? pc4 + (imm32 << 2) : pc4;

endmodule