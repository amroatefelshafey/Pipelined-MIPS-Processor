module hazard_unit(
  input [4:0] IFIDrs, IFIDrt,
  input [4:0] IDEXrs, IDEXrt,
  input [4:0] IDEXrd, // Output of the Multiplexer choosing between rd, rt, or 31
  input [4:0] EXMEMrd,
  input [4:0] MEMWBrd,
  
  input IDEXRegWrite, EXMEMRegWrite, MEMWBRegWrite, // Conditions for data hazards (if no write, there is no hazard!)
  input IDEXMemRead, EXMEMMemRead, MEMWBMemRead, // These deal with load-use and load-store hazards respectively
  input MemWriteD, // This is needed as a condition to bypass an unecessary stall in the case of load-store

  input PCSrc, Jump, Branch, // Necessary Signals to determine whether we flush/stall or not. Branch is used only to determine stalling

  output reg [1:0] ForwardAD,
  output [1:0] ForwardAE,
  output reg [1:0] ForwardBD, ForwardBE, // Forwarding signals
  output ForwardDM, // Deals with the load-store hazard
  output Stall, // This deals with load-use hazards which require a 1 cycle stall
  output Flush
);


  wire loadFollowingBranch = EXMEMMemRead & ( (EXMEMrd == IFIDrs) | (EXMEMrd == IFIDrt) ) & Branch ; // This deals with load-branch 2nd stall
  wire EXFollowingBranch = IDEXRegWrite & (IDEXrd != 0) & ( (IFIDrs == IDEXrd) | (IFIDrt == IDEXrd) ) & Branch; // This deals with R or I addressing-branch stall
  
  // ------------------------------ DATA HAZARD HANDLING ------------------------------
  
  // Forwarding Logic

  // ----- ForwardAE -----
  assign ForwardAE[0] = (IDEXrs == EXMEMrd) & EXMEMRegWrite & (EXMEMrd != 0);
  assign ForwardAE[1] = ForwardAE[0] | (MEMWBrd == IDEXrs) & (MEMWBRegWrite) & (MEMWBrd != 0);

  // ----- ForwardBE -----
  always@(*) begin
    if (EXMEMRegWrite & (EXMEMrd !=  0)
        & (EXMEMrd == IDEXrt)) ForwardBE = 2'b10;

    else if (MEMWBRegWrite & (MEMWBrd !=  0)
             & !( EXMEMRegWrite & (EXMEMrd !=  0)
                 & (EXMEMrd == IDEXrt) ) // This is redundant but will keep it for now because its !(if condition)
             & (MEMWBrd == IDEXrt)) ForwardBE = 2'b01;
    
    else ForwardBE = 2'b00;
  end

  // ----- ForwardAD -----
  always@(*) begin
    if (EXMEMRegWrite & (EXMEMrd !=  0)
        & (EXMEMrd == IFIDrs)) ForwardAD = 2'b10;

    else if (MEMWBRegWrite & (MEMWBrd !=  0)
             & !( EXMEMRegWrite & (EXMEMrd !=  0)
                 & (EXMEMrd == IFIDrs) ) // This is redundant but will keep it for now because its !(if condition)
             & (MEMWBrd == IFIDrs)) ForwardAD = 2'b01;

    else ForwardAD = 2'b00;
  end
    // ----- ForwardBD -----
  always@(*) begin
    if (EXMEMRegWrite & (EXMEMrd !=  0)
        & (EXMEMrd == IFIDrt)) ForwardBD = 2'b10;

    else if (MEMWBRegWrite & (MEMWBrd !=  0)
             & !( EXMEMRegWrite & (EXMEMrd !=  0)
                 & (EXMEMrd == IFIDrt) ) // This is redundant but will keep it for now because its !(if condition)
             & (MEMWBrd == IFIDrt)) ForwardBD = 2'b01;

    else ForwardBD = 2'b00;
  end

  // ----- Load-Store Forwarding Logic (ForwardDM) -----
  assign ForwardDM = MEMWBMemRead & (MEMWBrd == EXMEMrd); // Adding EXMEMMemWrite as a condition is redundant
  
  // Stalling Logic (Stall, IFIDWrite, PCWrite)
    
  assign Stall = (IDEXMemRead & ( (IDEXrt == IFIDrs) | (IDEXrt == IFIDrt & !MemWriteD) ) | loadFollowingBranch | EXFollowingBranch) & !Jump; // Must assert the instruction is not a jump 
                                                                                    // (jump signal here is from cycle 2)
    
  // ------------------------------ CONTROL HAZARD HANDLING ------------------------------
    
  // Flushing Logic
  
  assign Flush = PCSrc | Jump;

endmodule
