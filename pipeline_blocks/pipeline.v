module pipeline(
    input clk
);
 
//(forward change)
wire        Stall, Flush;
wire [1:0]  ForwardAE, ForwardBE;
wire [1:0]  ForwardAD, ForwardBD;
wire        ForwardDM;

wire PC_Write    = ~Stall;
wire IF_ID_Write = ~Stall;


// Hi / Lo  (written in EX stage, latched here at top level)
reg  [31:0] hi, lo;
 

//  IF STAGE

 
// Program Counter 
reg  [31:0] pc;
 
// pc_next MUX inputs
wire [31:0] pc4        = pc + 32'd4;             // PC + 4
wire [31:0] pc_branch;                            // branch target  (computed in ID)
wire [31:0] pc_jump;                              // JAL target     (computed in ID)
wire        PCSrc;                                // branch taken signal (from ID)
wire        ID_Jump_taken;                        // jump signal    (from ID)
 
// PC next-value MUX  (jump > branch > PC+4)
wire [31:0] pc_next = ID_Jump_taken ? pc_jump    :
                      PCSrc         ? pc_branch  : pc4;
 
always @(posedge clk) begin
    if (PC_Write)
        pc <= pc_next;
end
 
// Instruction Memory
wire [31:0] IF_instr;
instr_mem IM (pc, IF_instr);
 

//  IF/ID Pipeline Register

wire [31:0] IFID_PC4;
wire [31:0] IFID_instr;

//(forward change)
IF_ID_reg IF_ID_REG (clk, IF_ID_Write, Flush, pc4, IF_instr, IFID_PC4, IFID_instr);
 
//  ID STAGE
 
// Instruction decode
wire [5:0] ID_opcode = IFID_instr[31:26];
wire [4:0] ID_rs     = IFID_instr[25:21];
wire [4:0] ID_rt     = IFID_instr[20:16];
wire [4:0] ID_rd     = IFID_instr[15:11];
wire [4:0] ID_shamt  = IFID_instr[10:6];
wire [5:0] ID_funct  = IFID_instr[5:0];
wire [15:0] ID_imm16 = IFID_instr[15:0];
wire [25:0] ID_jinstr= IFID_instr[25:0];
wire [3:0]  ID_PC4_upper = IFID_PC4[31:28];
 
//  Control Unit 
wire ID_RegDst, ID_ALUSrcA, ID_ALUSrcB, ID_MemtoReg;
wire ID_RegWrite, ID_MemRead, ID_MemWrite, ID_Branch;
wire ID_SLT, ID_Jump, ID_HiLoWrite, ID_ExtOp;
wire [1:0] ID_ALUOp;
 
control_unit CU (ID_opcode, ID_funct, ID_RegDst, ID_ALUSrcA, ID_ALUSrcB, ID_MemtoReg, ID_RegWrite, ID_MemRead, 
ID_MemWrite, ID_Branch, ID_SLT, ID_Jump, ID_HiLoWrite, ID_ExtOp, ID_ALUOp);
 
//  Sign / Zero Extender 
wire [31:0] ID_imm32;
extender EXT (ID_imm16, ID_ExtOp, ID_imm32);
 
//  Register File 
// Write-back values come from WB stage ( 5th stage )
wire        WB_RegWrite;
wire [4:0]  WB_Write_Reg;
wire [31:0] WB_Write_Data;
 
wire [31:0] ID_Read_Data1, ID_Read_Data2;
 
register_file RF (clk, ID_rs, ID_rt, WB_Write_Reg, WB_Write_Data, WB_RegWrite, ID_Read_Data1, ID_Read_Data2);
 
//  Branch Address 
assign pc_branch     = IFID_PC4 + (ID_imm32 << 2);
 
//  Jump Address
assign pc_jump       = { ID_PC4_upper, ID_jinstr, 2'b00 };
 
//  Branch Comparator (forward change)
wire [31:0] BranchA = (ForwardAD == 2'b10) ? EXMEM_ALU_Lo  :
                      (ForwardAD == 2'b01) ? WB_Write_Data :
                                             ID_Read_Data1;
wire [31:0] BranchB = (ForwardBD == 2'b10) ? EXMEM_ALU_Lo  :
                      (ForwardBD == 2'b01) ? WB_Write_Data :
                                             ID_Read_Data2;
wire   ID_Zero = (BranchA == BranchB);
assign PCSrc   = ID_Branch & ID_Zero;
assign ID_Jump_taken = ID_Jump;
 
//  ID/EX Pipeline Register
// Control 
wire        IDEX_RegDst, IDEX_ALUSrcA, IDEX_ALUSrcB, IDEX_MemtoReg;
wire        IDEX_RegWrite, IDEX_MemRead, IDEX_MemWrite, IDEX_Branch;
wire        IDEX_SLT, IDEX_Jump, IDEX_HiLoWrite;
wire [1:0]  IDEX_ALUOp;
// Data
wire [31:0] IDEX_PC4;
wire [3:0]  IDEX_PC4_upper;
wire [31:0] IDEX_Read_Data1, IDEX_Read_Data2;
wire [31:0] IDEX_imm32;
wire [4:0]  IDEX_rs, IDEX_rt, IDEX_rd, IDEX_shamt;
wire [5:0]  IDEX_funct;
wire [25:0] IDEX_jinstr;
 
ID_EX_reg ID_EX_REG (
    .clk           (clk),
    .NOP           (Stall),
 
    // Control in
    .in_RegDst     (ID_RegDst),
    .in_ALUSrcA    (ID_ALUSrcA),
    .in_ALUSrcB    (ID_ALUSrcB),
    .in_MemtoReg   (ID_MemtoReg),
    .in_RegWrite   (ID_RegWrite),
    .in_MemRead    (ID_MemRead),
    .in_MemWrite   (ID_MemWrite),
    .in_Branch     (ID_Branch),
    .in_SLT        (ID_SLT),
    .in_Jump       (ID_Jump),
    .in_HiLoWrite  (ID_HiLoWrite),
    .in_ALUOp      (ID_ALUOp),
 
    // Data in
    .in_PC4        (IFID_PC4),
    .in_PC4_upper  (ID_PC4_upper),
    .in_Read_Data1 (ID_Read_Data1),
    .in_Read_Data2 (ID_Read_Data2),
    .in_imm32      (ID_imm32),
    .in_rs         (ID_rs),
    .in_rt         (ID_rt),
    .in_rd         (ID_rd),
    .in_shamt      (ID_shamt),
    .in_funct      (ID_funct),
    .in_jinstr     (ID_jinstr),
 
    // Control out
    .out_RegDst    (IDEX_RegDst),
    .out_ALUSrcA   (IDEX_ALUSrcA),
    .out_ALUSrcB   (IDEX_ALUSrcB),
    .out_MemtoReg  (IDEX_MemtoReg),
    .out_RegWrite  (IDEX_RegWrite),
    .out_MemRead   (IDEX_MemRead),
    .out_MemWrite  (IDEX_MemWrite),
    .out_Branch    (IDEX_Branch),
    .out_SLT       (IDEX_SLT),
    .out_Jump      (IDEX_Jump),
    .out_HiLoWrite (IDEX_HiLoWrite),
    .out_ALUOp     (IDEX_ALUOp),
 
    // Data out
    .out_PC4       (IDEX_PC4),
    .out_PC4_upper (IDEX_PC4_upper),
    .out_Read_Data1(IDEX_Read_Data1),
    .out_Read_Data2(IDEX_Read_Data2),
    .out_imm32     (IDEX_imm32),
    .out_rs        (IDEX_rs),
    .out_rt        (IDEX_rt),
    .out_rd        (IDEX_rd),
    .out_shamt     (IDEX_shamt),
    .out_funct     (IDEX_funct),
    .out_jinstr    (IDEX_jinstr)
);
 

//  EX STAGE
 
//  Write-Register MUX 
//  (MUX at the Bottom of the Datapath)
wire [4:0] EX_Write_Reg = IDEX_Jump   ? 5'd31        :
                          IDEX_RegDst ? IDEX_rd       : IDEX_rt;
 
//  ALU (Source) A MUX 
// (MUX at the top of ALU) (forward change)
wire [31:0] ForwardA_out = (ForwardAE == 2'b10) ? EXMEM_ALU_Lo  :
                           (ForwardAE == 2'b01) ? WB_Write_Data :
                                                  IDEX_Read_Data1;
wire [31:0] EX_ALU_A_pre = IDEX_ALUSrcA ? {{27{1'b0}}, IDEX_shamt} : ForwardA_out;
wire [31:0] EX_ALU_A     = IDEX_Jump    ? IDEX_PC4 : EX_ALU_A_pre;
 
//  ALU Source B MUX 
//  (MUX at the bottom of ALU) (forward change)
wire [31:0] ForwardB_out = (ForwardBE == 2'b10) ? EXMEM_ALU_Lo  :
                           (ForwardBE == 2'b01) ? WB_Write_Data :
                                                  IDEX_Read_Data2;
wire [31:0] EX_ALU_B_pre = IDEX_ALUSrcB ? IDEX_imm32 : ForwardB_out;
wire [31:0] EX_ALU_B     = IDEX_Jump    ? 32'd4      : EX_ALU_B_pre;
 
//  ALU Control 
wire [2:0] EX_ALUCtl;
alu_control AC (IDEX_ALUOp, IDEX_funct, EX_ALUCtl);
 
//  ALU 
wire [31:0] EX_ALU_Hi, EX_ALU_Lo; 
wire        EX_Carry, EX_Zero, EX_Sign;
 
ALU alu (EX_ALU_A, EX_ALU_B, EX_ALUCtl, EX_ALU_Hi, EX_ALU_Lo, EX_Carry, EX_Zero, EX_Sign);


//  Hi/Lo write-back 
always @(posedge clk) begin
    if (IDEX_HiLoWrite) begin
        hi <= EX_ALU_Hi;
        lo <= EX_ALU_Lo;
    end
end
 

//  EX/MEM Pipeline Register
wire        EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg, EXMEM_RegWrite;
wire        EXMEM_SLT, EXMEM_HiLoWrite;
wire [31:0] EXMEM_ALU_Hi, EXMEM_ALU_Lo;
wire        EXMEM_Zero, EXMEM_Sign;
wire [31:0] EXMEM_Write_Data;  
wire [4:0]  EXMEM_Write_Reg;
 
EX_MEM_reg EX_MEM_REG (
    .clk           (clk),
 
    // Control in
    .in_MemRead    (IDEX_MemRead),
    .in_MemWrite   (IDEX_MemWrite),
    .in_MemtoReg   (IDEX_MemtoReg),
    .in_RegWrite   (IDEX_RegWrite),
    .in_SLT        (IDEX_SLT),
    .in_HiLoWrite  (IDEX_HiLoWrite),
 
    // Data in
    .in_ALU_Hi     (EX_ALU_Hi),
    .in_ALU_Lo     (EX_ALU_Lo),
    .in_Zero       (EX_Zero),
    .in_Sign       (EX_Sign),
    .in_Write_Data (ForwardB_out),   // forward change
    .in_Write_Reg  (EX_Write_Reg),
 
    // Control out
    .out_MemRead   (EXMEM_MemRead),
    .out_MemWrite  (EXMEM_MemWrite),
    .out_MemtoReg  (EXMEM_MemtoReg),
    .out_RegWrite  (EXMEM_RegWrite),
    .out_SLT       (EXMEM_SLT),
    .out_HiLoWrite (EXMEM_HiLoWrite),
 
    // Data out
    .out_ALU_Hi    (EXMEM_ALU_Hi),
    .out_ALU_Lo    (EXMEM_ALU_Lo),
    .out_Zero      (EXMEM_Zero),
    .out_Sign      (EXMEM_Sign),
    .out_Write_Data(EXMEM_Write_Data),
    .out_Write_Reg (EXMEM_Write_Reg)
);
 
//  MEM STAGE

wire [31:0] MEM_Read_Data;

// (forward change)
wire [31:0] MEM_Write_Data = ForwardDM ? MEMWB_Read_Data : EXMEM_Write_Data;
data_memory DM (clk, EXMEM_ALU_Lo, MEM_Write_Data, EXMEM_MemRead, EXMEM_MemWrite, MEM_Read_Data);
 
//  MEM/WB Pipeline Register
wire        MEMWB_MemtoReg, MEMWB_RegWrite, MEMWB_SLT, MEMWB_HiLoWrite;
wire [31:0] MEMWB_ALU_Hi, MEMWB_ALU_Lo;
wire [31:0] MEMWB_Read_Data;
wire        MEMWB_Sign;
wire [4:0]  MEMWB_Write_Reg;
 
MEM_WB_reg MEM_WB_REG (
    .clk           (clk),
 
    // Control in
    .in_MemtoReg   (EXMEM_MemtoReg),
    .in_RegWrite   (EXMEM_RegWrite),
    .in_SLT        (EXMEM_SLT),
    .in_HiLoWrite  (EXMEM_HiLoWrite),
 
    // Data in
    .in_ALU_Hi     (EXMEM_ALU_Hi),
    .in_ALU_Lo     (EXMEM_ALU_Lo),
    .in_Read_Data  (MEM_Read_Data),
    .in_Sign       (EXMEM_Sign),
    .in_Write_Reg  (EXMEM_Write_Reg),
 
    // Control out
    .out_MemtoReg  (MEMWB_MemtoReg),
    .out_RegWrite  (MEMWB_RegWrite),
    .out_SLT       (MEMWB_SLT),
    .out_HiLoWrite (MEMWB_HiLoWrite),
 
    // Data out
    .out_ALU_Hi    (MEMWB_ALU_Hi),
    .out_ALU_Lo    (MEMWB_ALU_Lo),
    .out_Read_Data (MEMWB_Read_Data),
    .out_Sign      (MEMWB_Sign),
    .out_Write_Reg (MEMWB_Write_Reg)
);
 
//  WB STAGE
 
// Write-register destination
assign WB_Write_Reg  = MEMWB_Write_Reg;
assign WB_RegWrite   = MEMWB_RegWrite;

assign WB_Write_Data = MEMWB_SLT      ? {{31{1'b0}}, MEMWB_Sign} :
                       MEMWB_MemtoReg ? MEMWB_Read_Data          :
                                        MEMWB_ALU_Lo;
										
// Hazard unit
hazard_unit HU (
    .IFIDrs       (ID_rs),
    .IFIDrt       (ID_rt),
    .IDEXrs       (IDEX_rs),
    .IDEXrt       (IDEX_rt),
    .IDEXrd       (EX_Write_Reg),
    .EXMEMrd      (EXMEM_Write_Reg),
    .MEMWBrd      (MEMWB_Write_Reg),
    .IDEXRegWrite (IDEX_RegWrite),
    .EXMEMRegWrite(EXMEM_RegWrite),
    .MEMWBRegWrite(MEMWB_RegWrite),
    .IDEXMemRead  (IDEX_MemRead),
    .EXMEMMemRead (EXMEM_MemRead),
    .MEMWBMemRead (MEMWB_MemRead),
    .MemWriteD    (ID_MemWrite),
    .PCSrc        (PCSrc),
    .Jump         (ID_Jump),
    .Branch       (ID_Branch),
    .ForwardAD    (ForwardAD),
    .ForwardAE    (ForwardAE),
    .ForwardBD    (ForwardBD),
    .ForwardBE    (ForwardBE),
    .ForwardDM    (ForwardDM),
    .Stall        (Stall),
    .Flush        (Flush)
);
									
endmodule
 
