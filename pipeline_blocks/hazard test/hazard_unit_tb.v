`timescale 1ns / 1ps

module hazard_unit_tb;

    // 1. Inputs to the Hazard Unit (Registers for Testbench)
    reg [4:0] IFIDrs, IFIDrt;
    reg [4:0] IDEXrs, IDEXrt, IDEXrd;
    reg [4:0] EXMEMrd;
    reg [4:0] MEMWBrd;
    
    reg IDEXRegWrite, EXMEMRegWrite, MEMWBRegWrite;
    reg IDEXMemRead, EXMEMMemRead, MEMWBMemRead;
    reg PCSrc, Jump, Branch;

    // 2. Outputs from the Hazard Unit (Wires to read)
    wire [1:0] ForwardAD, ForwardAE;
    wire [1:0] ForwardBD, ForwardBE;
    wire ForwardDM, Stall, Flush;

    // 3. Instantiate the Device Under Test (DUT)
    hazard_unit uut (
        .IFIDrs(IFIDrs), .IFIDrt(IFIDrt),
        .IDEXrs(IDEXrs), .IDEXrt(IDEXrt), .IDEXrd(IDEXrd),
        .EXMEMrd(EXMEMrd), .MEMWBrd(MEMWBrd),
        .IDEXRegWrite(IDEXRegWrite), .EXMEMRegWrite(EXMEMRegWrite), .MEMWBRegWrite(MEMWBRegWrite),
        .IDEXMemRead(IDEXMemRead), .EXMEMMemRead(EXMEMMemRead), .MEMWBMemRead(MEMWBMemRead),
        .PCSrc(PCSrc), .Jump(Jump), .Branch(Branch),
        .ForwardAD(ForwardAD), .ForwardAE(ForwardAE),
        .ForwardBD(ForwardBD), .ForwardBE(ForwardBE),
        .ForwardDM(ForwardDM), .Stall(Stall), .Flush(Flush)
    );

    // 4. Test Sequence
    initial begin
        // Initialize all signals to 0 (Empty Pipeline)
        IFIDrs = 0; IFIDrt = 0;
        IDEXrs = 0; IDEXrt = 0; IDEXrd = 0; IDEXRegWrite = 0; IDEXMemRead = 0;
        EXMEMrd = 0; EXMEMRegWrite = 0; EXMEMMemRead = 0;
        MEMWBrd = 0; MEMWBRegWrite = 0; MEMWBMemRead = 0;
        PCSrc = 0; Jump = 0; Branch = 0;
        
        $display("Starting Cycle-by-Cycle Simulation...\n");
		$display("STIMULUS CODE TO RUN:\nsub $2, $1, $3\nand $12, $2, $5\nor $13, $6, $2\nadd $14, $2 , $2\nsw $15, 100($2)");
										 
										  
										 

        // --- Cycle 1 & 2: Pipeline filling (No hazards expected) ---
        // sub in ID, and in IF
        #10;
        
        // --- Cycle 3: sub in EX, and in ID, or in IF ---
        // sub: rs=1, rt=3, rd=2
        IDEXrs = 1; IDEXrt = 3; IDEXrd = 2; IDEXRegWrite = 1;
        // and: rs=2, rt=5
        IFIDrs = 2; IFIDrt = 5; 
        #10;

        // --- Cycle 4: sub in MEM, and in EX, or in ID, add in IF ---
        // sub moves to EX/MEM
        EXMEMrd = 2; EXMEMRegWrite = 1;
        // and moves to ID/EX
        IDEXrs = 2; IDEXrt = 5; IDEXrd = 12; IDEXRegWrite = 1;
        // or moves to IF/ID (rs=6, rt=2)
        IFIDrs = 6; IFIDrt = 2;
        #10;
        $display("\nCycle 4: 'sub' in MEM, 'and' in EX.");
        $display("Expected: ForwardAE should trigger (EX/MEM hazard for Rs=$2).");
        $display("Actual ForwardAE: %b", ForwardAE);
        $display("----------------------------------------");

        // --- Cycle 5: sub in WB, and in MEM, or in EX, add in ID, sw in IF ---
        // sub moves to MEM/WB
        MEMWBrd = 2; MEMWBRegWrite = 1;
        // and moves to EX/MEM
        EXMEMrd = 12; EXMEMRegWrite = 1;
        // or moves to ID/EX
        IDEXrs = 6; IDEXrt = 2; IDEXrd = 13; IDEXRegWrite = 1;
        // add moves to IF/ID (rs=2, rt=2)
        IFIDrs = 2; IFIDrt = 2;
        #10;
        $display("Cycle 5: 'sub' in WB, 'or' in EX.");
        $display("Expected: ForwardBE should be 01 (MEM/WB hazard for Rt=$2).");
        $display("Actual ForwardBE: %b", ForwardBE);
        $display("----------------------------------------");

        // --- Cycle 6: sub done, and in WB, or in MEM, add in EX, sw in ID ---
        // and moves to MEM/WB
        MEMWBrd = 12; MEMWBRegWrite = 1;
        // or moves to EX/MEM
        EXMEMrd = 13; EXMEMRegWrite = 1;
        // add moves to ID/EX
        IDEXrs = 2; IDEXrt = 2; IDEXrd = 14; IDEXRegWrite = 1;
        // sw moves to IF/ID (rs=2, rt=15)
        IFIDrs = 2; IFIDrt = 15;
        #10;
        $display("Cycle 6: 'add' in EX needs $2. 'sub' is already out of pipeline.");
        $display("Expected: No forwarding needed from hazard unit (handled by RegFile read/write phase).");
        $display("Actual ForwardAE: %b | ForwardBE: %b", ForwardAE, ForwardBE);
        $display("----------------------------------------");

        // --- Cycle 7: and done, or in WB, add in MEM, sw in EX ---
        // or moves to MEM/WB
        MEMWBrd = 13; MEMWBRegWrite = 1;
        // add moves to EX/MEM
        EXMEMrd = 14; EXMEMRegWrite = 1;
        // sw moves to ID/EX
        IDEXrs = 2; IDEXrt = 15; IDEXrd = 0; IDEXRegWrite = 0; IDEXMemRead = 0;
        #10;

        $display("\nSimulation Complete.");
        $finish;
    end

endmodule
