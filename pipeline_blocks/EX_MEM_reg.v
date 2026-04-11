module EX_MEM_reg(
    input clk,

    //  Control signals IN 
    input        in_MemRead, in_MemWrite, in_MemtoReg, in_RegWrite, in_SLT, 

    // Data going IN 
    input [31:0] in_ALU,
    input [31:0] in_Sign,
    input [31:0] in_Write_Data,   // forwarded RD2 (used by SW)
    input [4:0]  in_Write_Reg,

    //  Control signals OUT
    output reg        out_MemRead, out_MemWrite, out_MemtoReg, out_RegWrite, out_SLT, 

    //  Data going OUT 
    output reg [31:0] out_ALU,
    output reg [31:0] out_Sign,
    output reg [31:0] out_Write_Data,
    output reg [4:0]  out_Write_Reg
);
    always @(posedge clk) begin
        out_MemRead   <= in_MemRead;   out_MemWrite  <= in_MemWrite;
        out_MemtoReg  <= in_MemtoReg;  out_RegWrite  <= in_RegWrite;
        out_SLT       <= in_SLT;       
        out_ALU       <= in_ALU;       out_Sign      <= in_Sign;
        out_Write_Data<= in_Write_Data;  out_Write_Reg <= in_Write_Reg;
    end
endmodule
