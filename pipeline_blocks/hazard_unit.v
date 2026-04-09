module hazard_unit(
  input [4:0] IFIDrs, IFIDrt,
  input [4:0] IDEXrs, IDEXrt,
  input [4:0] IDEXrd, // Output of the Multiplexer choosing between rd, rt, or 31
  input [4:0] EXMEMrd,
  input [4:0] MEMWBrd,
  
  input IDEXRegWrite, EXMEMRegWrite, MEMWBRegWrite, // Conditions for data hazards (if no write, there is no hazard!)
  input IDEXMemRead, EXMEMMemRead, MEMWBMemRead, // These deal with load-use and load-store hazards respectively

  input PCSrc, Jump, Branch // Necessary Signals to determine whether we flush/stall or not. Branch is used only to determine stalling
  
  output [1:0] ForwardA, 
  output reg [1:0] ForwardB, // Forwarding signals
  output ForwardDM, // Deals with the load-store hazard
  output Stall, // This deals with load-use hazards which require a 1 cycle stall
  output Flush
);


  wire loadFollowingBranch = EXMEMMemRead & ( (EXMEMrd == IFIDrs) | (EXMEMrd == IFIDrt) ) & Branch ; // This deals with load-branch 2nd stall
  wire EXFollowingBranch = IDEXRegWrite & (IDEXrd != 0) & ( (IFIDrs == IDEXrd) | (IFIDrt == IDEXrd) ) & Branch;
  // DATA HAZARD HANDLING
  // Forwarding Logic (ForwardA & ForwardB)

  // ----- ForwardA -----
  assign ForwardA[0] = (IDEXrs == EXMEMrd) & EXMEMRegWrite & (EXMEMrd != 0);
  assign ForwardA[1] = ForwardA[0] | (MEMWB.rd == IDEXrs) & (MEMWBRegWrite) & (MEMWBrd != 0);

  // ----- ForwardB -----
  always@(*) begin
    if (MEMWBRegWrite & (MEMWBrd !=  0)
        & (!EXMEMRegWrite | (EXMEMrd ==  0) | (EXMEMrd ==  IDEXrt))
        & (MEMWBrd == IDEXrt)) ForwardB = 2'b10;

    else if (MEMWBRegWrite & (MEMWBrd !=  0)
             & (MEMWBrd == IDEXrt)) ForwardB = 2'b01;
    
    else ForwardB = 2'b00;
  end

  // ----- Load-Store Forwarding Logic (ForwardDM) -----
  assign ForwardDM = MEMWBMemRead & (MEMWBrd == EXMEMrd);
  
  // ----- Load-Use Stalling Logic (Stall, IFIDWrite, PCWrite) -----
  assign Stall = (IDEXMemRead & ( (IDEXrt == IFIDrs) | (IDEXrt == IFIDrt) ) | loadFollowingBranch ) & !Jump; // Must assert the instruction is not a jump 
                                                                                    // (jump signal here is from cycle 2)
  // CONTROL HAZARD HANDLING

  assign Flush = PCSrc | Jump;

endmodule
