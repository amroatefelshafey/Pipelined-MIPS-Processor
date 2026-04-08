module IF_ID_reg(
    input        clk,
    input        Write,   // to allow the data to pass
    input        NOP,   // for NOP 
    input [31:0] in_PC,
    input [31:0] in_Instr,
    output reg [31:0] out_PC,
    output reg [31:0] out_Instr
);
    always @(posedge clk) begin
        if (NOP) begin
            out_PC   <= 32'b0;
            out_Instr <= 32'b0; 
        end else if (Write) begin
            out_PC   <= in_PC;
            out_Instr <= in_Instr;
        end
    end
endmodule
