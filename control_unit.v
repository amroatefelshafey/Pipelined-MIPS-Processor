module control_unit(

input [5:0] opcode, funct,

output RegDst,
output ALUSrcA,
output ALUSrcB,
output MemtoReg,
output RegWrite,
output MemRead,
output MemWrite,
output Branch,
output SLT,
output Jump,
output HiLoWrite,
output ExtOp,
output [1:0] ALUOp

);

wire [13:0] control;

microcode ROM(.opcode(opcode), .funct(funct), .control(control));

assign RegDst   = control[13];
assign ALUSrcA  = control[12];
assign ALUSrcB  = control[11];
assign MemtoReg = control[10];
assign RegWrite = control[9];
assign MemRead  = control[8];
assign MemWrite = control[7];
assign Branch   = control[6];
assign SLT      = control[5];
assign Jump     = control[4];
assign HiLoWrite= control[3];
assign ExtOp    = control[2];
assign ALUOp    = control[1:0];

endmodule