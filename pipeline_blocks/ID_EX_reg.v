module ID_EX_reg(
    input clk,
    input NOP,   // Zero for all control signals

    // Control signals IN
    input        in_RegDst, in_ALUSrcA, in_ALUSrcB, in_MemtoReg,
    input        in_RegWrite, in_MemRead, in_MemWrite, in_Branch,
    input        in_SLT, in_Jump, in_HiLoWrite,
    input [1:0]  in_ALUOp,

    // Data going IN
    input [31:0] in_PC4,
    input [3:0]  in_PC4_upper,    // PC+4[31:28] for JAL 
    input [31:0] in_Read_Data1, in_Read_Data2,
    input [31:0] in_imm32,
    input [4:0]  in_rs, in_rt, in_rd, in_shamt,
    input [5:0]  in_funct,
    input [25:0] in_jinstr,        // instr[25:0] for JAL 

    //  Control signals OUT
    output reg        out_RegDst, out_ALUSrcA, out_ALUSrcB, out_MemtoReg,
    output reg        out_RegWrite, out_MemRead, out_MemWrite, out_Branch,
    output reg        out_SLT, out_Jump, out_HiLoWrite,
    output reg [1:0]  out_ALUOp,

    // Data going OUT 
    output reg [31:0] out_PC4,
    output reg [3:0]  out_PC4_upper,
    output reg [31:0] out_Read_Data1, out_Read_Data2,
    output reg [31:0] out_imm32,
    output reg [4:0]  out_rs, out_rt, out_rd, out_shamt,
    output reg [5:0]  out_funct,
    output reg [25:0] out_jinstr
);
    always @(posedge clk) begin
        if (NOP) begin
            out_RegDst   <= 0; out_ALUSrcA  <= 0; out_ALUSrcB  <= 0;
            out_MemtoReg <= 0; out_RegWrite <= 0; out_MemRead  <= 0;
            out_MemWrite <= 0; out_Branch   <= 0; out_SLT      <= 0;
            out_Jump     <= 0; out_HiLoWrite<= 0; out_ALUOp    <= 0;
            out_PC4      <= 0; out_PC4_upper <= 0;
            out_Read_Data1<=0; out_Read_Data2<=0; out_imm32    <= 0;
            out_rs <= 0; out_rt <= 0; out_rd <= 0; out_shamt   <= 0;
            out_funct <= 0; out_jinstr <= 0;
        end else begin
            out_RegDst   <= in_RegDst;   out_ALUSrcA  <= in_ALUSrcA;
            out_ALUSrcB  <= in_ALUSrcB;  out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite; out_MemRead  <= in_MemRead;
            out_MemWrite <= in_MemWrite; out_Branch   <= in_Branch;
            out_SLT      <= in_SLT;      out_Jump     <= in_Jump;
            out_HiLoWrite<= in_HiLoWrite; out_ALUOp   <= in_ALUOp;
            out_PC4      <= in_PC4;      out_PC4_upper<= in_PC4_upper;
            out_Read_Data1 <= in_Read_Data1;
            out_Read_Data2 <= in_Read_Data2;
            out_imm32    <= in_imm32;
            out_rs       <= in_rs;  out_rt    <= in_rt;
            out_rd       <= in_rd;  out_shamt <= in_shamt;
            out_funct    <= in_funct;
            out_jinstr   <= in_jinstr;
        end
    end
endmodule
