module instr_mem (
input [31:0] addr, // PC address
output reg [31:0] instr // Instruction output
);

// 32-bit memory
reg [31:0] mem [0:65535];
// Word index (word-aligned)

always@(*)
	instr = mem[addr[15:0]];

endmodule