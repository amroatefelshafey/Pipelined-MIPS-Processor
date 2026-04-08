module hazard_unit(
  input [4:0] IFIDrs, IFIDrt,
  input [4:0] IDEXrs, IDEXrt,
  input [4:0] EXMEMrd,
  input [4:0] MEMWBrd,
  
  input EXMEMRegWrite, MEMWBRegWrite, // Conditions for data hazards (if no write, there is no hazard!)
  input IDEXMemRead, MEMWBMemRead, //These deal with load-use and load-store hazards respectively
  
  output [1:0] ForwardA, ForwardB, // Forwarding signals
  output ForwardDM, // Deals with the load-store hazard
  output Stall // This deals with load-use hazards which require a 1 cycle stall
);

  // DATA HAZARD HANDLING
  // Forwarding Logic (ForwardA & ForwardB)


  // Load-Store forwarding Logic (ForwardDM)
  assign ForwardDM = MEMWBMemRead & (MEMWBrd == EXMEMrd);
  
  //Load-Use Stalling Logic (Stall, IFIDWrite, PCWrite)
  assign Stall = IDEXMemRead & ( (IDEXrt == IFIDrs) | (IDEXrt == IFIDrt) ) & !Jump; // Must asser the instruction is not a jump (jump signal here is from cycle 2)
