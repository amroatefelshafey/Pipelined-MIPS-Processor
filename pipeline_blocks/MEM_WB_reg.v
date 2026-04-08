module MEM_WB_reg(
    input clk,

    //  Control signals IN 
    input        in_MemtoReg, in_RegWrite, in_SLT, in_HiLoWrite,

    //  Data going IN 
    input [31:0] in_ALU_Hi, in_ALU_Lo,
    input [31:0] in_Read_Data,
    input [4:0]  in_Write_Reg,
    input        in_Sign,

    //  Control signals OUT 
    output reg        out_MemtoReg, out_RegWrite, out_SLT, out_HiLoWrite,

    //  Data going OUT 
    output reg [31:0] out_ALU_Hi, out_ALU_Lo,
    output reg [31:0] out_Read_Data,
    output reg [4:0]  out_Write_Reg,
    output reg        out_Sign
);
    always @(posedge clk) begin
        out_MemtoReg  <= in_MemtoReg;  out_RegWrite  <= in_RegWrite;
        out_SLT       <= in_SLT;       out_HiLoWrite <= in_HiLoWrite;
        out_ALU_Hi    <= in_ALU_Hi;    out_ALU_Lo    <= in_ALU_Lo;
        out_Read_Data <= in_Read_Data;
        out_Write_Reg <= in_Write_Reg;
        out_Sign      <= in_Sign;
    end
endmodule
