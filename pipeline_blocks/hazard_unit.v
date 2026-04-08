module hazard_unit(
  input [4:0] IFIDrs, IFIDrt,
  input [4:0] IDEXrs, IDEXrt,
  input [4:0] EXMEMrd,
  input [4:0] MEMWBrd,
  
  input EXMEMRegWrite, MEMWBRegWrite,
  input IDEXMemRead, MEMWBMemRead, //These deal with load-use and load-store hazards respectively
  
  output [1:0] ForwardA, ForwardB, // Forwarding signals
  output ForwardDM, // Deals with the load-store hazard
  output Stall, IFIFWrite, PCWrite // These deal with load-use hazards which require a 1 cycle stall
);
