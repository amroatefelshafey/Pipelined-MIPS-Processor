module ID_EX_reg(
    input clk,
    input NOP,   // Zero for all control signals

    // Control signals IN
    input        in_RegDst, in_ALUSrcA, in_ALUSrcB, in_MemtoReg,
    input        in_RegWrite, in_MemRead, in_MemWrite,
    input        in_SLT, in_Jump, in_HiLoWrite, in_ExtOp,
    input [1:0]  in_ALUOp,

    // Data going IN
    input [31:0] in_PC4, 
    input [31:0] in_Read_Data1, in_Read_Data2,
    input [15:0] imm16,
    input [4:0]  rt, rs,

    //  Control signals OUT
    output reg        out_RegDst, out_ALUSrcA, out_ALUSrcB, out_MemtoReg,
    output reg        out_RegWrite, out_MemRead, out_MemWrite,
    output reg        out_SLT, out_Jump, out_HiLoWrite, out_ExtOp
    output reg [1:0]  out_ALUOp,

    // Data going OUT 
    output reg [31:0] out_PC4,
    output reg [31:0] out_Read_Data1, out_Read_Data2,
    input [15:0] out_imm16,
    input [4:0]  out_rt, out_rs,
);
    always @(posedge clk) begin
        if (NOP) begin
            out_RegDst   <= 0; out_ALUSrcA  <= 0; out_ALUSrcB  <= 0;
            out_MemtoReg <= 0; out_RegWrite <= 0; out_MemRead  <= 0;
            out_MemWrite <= 0; out_SLT      <= 0;
            out_Jump     <= 0; out_HiLoWrite<= 0; out_ALUOp    <= 0;
            out_PC4      <= 0; out_Read_Data1<=0; out_Read_Data2<=0; 
            out_imm16    <= 0; out_rs <= 0; out_rt <= 0; out_ExtOp <= 0;
        end else begin
            out_RegDst   <= in_RegDst;   out_ALUSrcA  <= in_ALUSrcA;
            out_ALUSrcB  <= in_ALUSrcB;  out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite; out_MemRead  <= in_MemRead;
            out_MemWrite <= in_MemWrite;
            out_SLT      <= in_SLT;      out_Jump     <= in_Jump;
            out_HiLoWrite<= in_HiLoWrite; out_ALUOp   <= in_ALUOp; out_ExtOp <= in_ExtOp;
            out_PC4      <= in_PC4; 
            out_Read_Data1 <= in_Read_Data1;
            out_Read_Data2 <= in_Read_Data2;
            out_imm16    <= in_imm16;
            out_rs       <= in_rs;  out_rt    <= in_rt;
        end
    end
endmodule

