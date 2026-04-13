`timescale 1ns/1ps
module pipeline_tb;

reg clk;
integer i;

// For Self Checking
integer errors;
integer cycle;

pipeline uut (
    .clk(clk)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// PC, Registers, & Memory Initialization
initial begin

    // Program Counter
    uut.pc = 32'h0000300c;

    // IF/ID register
    uut.IF_ID_REG.out_PC   = 32'h00003010;
    uut.IF_ID_REG.out_Instr = 32'h00000000;   // NOP

    // ID/EX register  — zero every field 
    uut.ID_EX_REG.out_RegDst    = 0;
    uut.ID_EX_REG.out_ALUSrcA   = 0;
    uut.ID_EX_REG.out_ALUSrcB   = 0;
    uut.ID_EX_REG.out_MemtoReg  = 0;
    uut.ID_EX_REG.out_RegWrite  = 0;
    uut.ID_EX_REG.out_MemRead   = 0;
    uut.ID_EX_REG.out_MemWrite  = 0;
    uut.ID_EX_REG.out_SLT       = 0;
    uut.ID_EX_REG.out_Jump      = 0;
    uut.ID_EX_REG.out_HiLoWrite = 0;
    uut.ID_EX_REG.out_ALUOp     = 2'b00;
    uut.ID_EX_REG.out_ExtOp     = 0;
    uut.ID_EX_REG.out_PC4       = 32'h00003010;
    uut.ID_EX_REG.out_Read_Data1= 32'h00000000;
    uut.ID_EX_REG.out_Read_Data2= 32'h00000000;
    uut.ID_EX_REG.out_imm16     = 32'h00000000;
    uut.ID_EX_REG.out_rs        = 5'd0;
    uut.ID_EX_REG.out_rt        = 5'd0;

    // EX/MEM register
    uut.EX_MEM_REG.out_MemRead  = 0;
    uut.EX_MEM_REG.out_MemWrite = 0;
    uut.EX_MEM_REG.out_MemtoReg = 0;
    uut.EX_MEM_REG.out_RegWrite = 0;
    uut.EX_MEM_REG.out_SLT      = 0;
    uut.EX_MEM_REG.out_ALU      = 32'h00000000;
    uut.EX_MEM_REG.out_Sign     = 32'h00000000;
    uut.EX_MEM_REG.out_Write_Data = 32'h00000000;
    uut.EX_MEM_REG.out_Write_Reg  = 5'd0;

    // MEM/WB register
    uut.MEM_WB_REG.out_MemtoReg = 0;
    uut.MEM_WB_REG.out_RegWrite = 0;
    uut.MEM_WB_REG.out_SLT      = 0;
    uut.MEM_WB_REG.out_ALU      = 32'h00000000;
    uut.MEM_WB_REG.out_Read_Data= 32'h00000000;
    uut.MEM_WB_REG.out_Sign     = 32'h00000000;
    uut.MEM_WB_REG.out_Write_Reg= 5'd0;

    // HI / LO
    uut.hi = 32'h00000000;
    uut.lo = 32'h00000000;

    // Register file — zero all registers
    for (i = 0; i < 32; i = i + 1)
        uut.RF.R[i] = 32'h00000000;

    // Load program and data
    $readmemh("program_n.mem", uut.IM.mem, 32'h00003000, 32'h00003034);
    $readmemh("data.hex",      uut.DM.mem);
end

// Monitor registers and memory
always @(posedge clk) begin
    $display("--- Register File at Time %0t ---", $time);
    $monitor("$v0: %h | $t0: %h | $t1: %h | $t2: %h | $t8: %h | $ra: %h | Mem[0]: %h | Mem[1]: %h | Mem[2]: %h",
             uut.RF.R[2],  uut.RF.R[8],  uut.RF.R[9],  uut.RF.R[10],
             uut.RF.R[24], uut.RF.R[31],
             uut.DM.mem[0], uut.DM.mem[1], uut.DM.mem[2]);
end

// Monitor {Hi, Lo} after 35 ns
initial begin
    #35;
    $strobe("{Hi, Lo} = {%h, %h}", uut.hi, uut.lo);
end

// Main run and self-check
initial begin
    errors = 0;

    //Run the CPU
    for (cycle = 0; cycle < 17; cycle = cycle + 1) begin
        @(posedge clk);
        $display("Cycle=%0d | PC=%h | IF_instr=%h | IFID_instr=%h | Stall=%b | Flush=%b",
                 cycle+1,
                 uut.pc,
                 uut.IF_instr,
                 uut.IFID_instr,
                 uut.Stall,
                 uut.Flush);
    end

    #10;

       // Self-Checking Section
    $display("\n--- SELF-CHECK ---");

    // $v0
    if (uut.RF.R[2] !== 32'd730) begin
        $display("Error: $v0 incorrect = %0d (expected 730)", uut.RF.R[2]);
        errors = errors + 1;
    end

    // $t0
    if (uut.RF.R[8] !== 32'd100) begin
        $display("Error: $t0 incorrect = %0d (expected 100)", uut.RF.R[8]);
        errors = errors + 1;
    end

    // $t1
    if (uut.RF.R[9] !== 32'd8) begin
        $display("Error: $t1 incorrect = %0d (expected 8)", uut.RF.R[9]);
        errors = errors + 1;
    end

    // $t2
    if (uut.RF.R[10] !== 32'd70) begin
        $display("Error: $t2 incorrect = %0d (expected 70)", uut.RF.R[10]);
        errors = errors + 1;
    end

    // $t8
    if (uut.RF.R[24] !== 32'd1) begin
        $display("Error: $t8 incorrect = %0d (expected 1)", uut.RF.R[24]);
        errors = errors + 1;
    end

    // HI / LO
    if (uut.hi !== 32'd0 || uut.lo !== 32'd800) begin
        $display("Error: HI/LO incorrect = %0d / %0d (expected 0 / 800)",
                 uut.hi, uut.lo);
        errors = errors + 1;
    end

    // Memory
    if (uut.DM.mem[0] !== 32'd100) begin
        $display("Error: MEM[0] incorrect = %0d (expected 100)", uut.DM.mem[0]);
        errors = errors + 1;
    end

    if (uut.DM.mem[1] !== 32'd70) begin
        $display("Error: MEM[1] incorrect = %0d (expected 70)", uut.DM.mem[1]);
        errors = errors + 1;
    end

    if (uut.DM.mem[2] !== 32'd800) begin
        $display("Error: MEM[2] incorrect = %0d (expected 800)", uut.DM.mem[2]);
        errors = errors + 1;
    end

    // Final result
    if (errors == 0)
        $display("\n TEST PASSED");
    else
        $display("\n TEST FAILED with %0d errors", errors);

    #10;
    $finish;
end

endmodule
