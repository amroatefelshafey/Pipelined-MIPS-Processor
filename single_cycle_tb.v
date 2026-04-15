`timescale 1ns/1ps
module single_cycle_tb;

reg clk;
wire [63:0] OUT;

integer i;
// For Self Checking 
integer errors;
integer cycle;


single_cycle uut (
    .clk(clk),
    .OUT(OUT)
);

// Clock 
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// PC, Registers, & Memory Initialization
initial begin

    uut.pc = 32'h0000300c;
	
	for (i = 0; i < 32; i = i + 1)
        uut.RF.R[i] = 0;
		
	$readmemh("program_n.mem", uut.IM.mem,32'h00003000,32'h00003034);
	$readmemh("data.hex", uut.DM.mem);
	
end


initial begin
	
    errors = 0;
    //Run the CPU
	for (cycle = 0; cycle < 12; cycle = cycle + 1) begin
		@(posedge clk);

    $display("\n================= Cycle=%0d =================", cycle+1);

    $display(" | PC=%h | Instr=%h | OUT=%h",
             uut.pc,
             uut.instr,
             OUT);
			 
	    // ===== Register + Memory =====
    $display("\n--- Register File at Time %0t ---", $time);

    $display("$v0: %h | $t0: %h |                                  | Mem[0]: %h |",
              uut.RF.R[2], uut.RF.R[8], uut.DM.mem[0]);

    $display("$t1: %h | $t2: %h |                                  | Mem[1]: %h |",
              uut.RF.R[9], uut.RF.R[10], uut.DM.mem[1]);

    $display("$t8: %h | $ra: %h |                                  | Mem[2]: %h |",
              uut.RF.R[24], uut.RF.R[31], uut.DM.mem[2]);

    // ===== HI / LO =====
    $strobe("{Hi, Lo} = {%h, %h}", uut.hi, uut.lo);		 
	end

#10;


// ============================
// SELF-CHECK SECTION
// ============================
	$display("\n--- SELF-CHECK ---");

// $v0
	if (uut.RF.R[2] !== 32'd730) begin
		$display("Error: $v0 incorrect = %0d (expected 730)", uut.RF.R[2]);
		errors = errors + 1;
	end else begin
		$display("Correct: $v0 = %0d (expected 730)", uut.RF.R[2]);
	end

// $t0
	if (uut.RF.R[8] !== 32'd100) begin
		$display("Error: $t0 incorrect = %0d (expected 100)", uut.RF.R[8]);
		errors = errors + 1;
	end else begin
		$display("Correct: $t0 = %0d (expected 100)", uut.RF.R[8]);
	end

// $t1
	if (uut.RF.R[9] !== 32'd8) begin
		$display("Error: $t1 incorrect = %0d (expected 8)", uut.RF.R[9]);
		errors = errors + 1;
	end else begin
		$display("Correct: $t1 = %0d (expected 8)", uut.RF.R[9]);
	end

// $t2
	if (uut.RF.R[10] !== 32'd70) begin
		$display("Error: $t2 incorrect = %0d (expected 70)", uut.RF.R[10]);
		errors = errors + 1;
	end else begin
    $display("Correct: $t2 = %0d (expected 70)", uut.RF.R[10]);
	end

// $t8
	if (uut.RF.R[24] !== 32'd1) begin
		$display("Error: $t8 incorrect = %0d (expected 1)", uut.RF.R[24]);
		errors = errors + 1;
	end else begin
		$display("Correct: $t8 = %0d (expected 1)", uut.RF.R[24]);
	end

// HI / LO
	if (uut.hi !== 32'd0 || uut.lo !== 32'd800) begin
		$display("Error: HI/LO incorrect = %0d / %0d (expected 0 / 800)", uut.hi, uut.lo);
		errors = errors + 1;
	end else begin
		$display("Correct: HI/LO = %0d / %0d (expected 0 / 800)", uut.hi, uut.lo);
	end

// Memory
	if (uut.DM.mem[0] !== 32'd100) begin
		$display("Error: MEM[0] incorrect = %0d (expected 100)", uut.DM.mem[0]);
		errors = errors + 1;
	end else begin
		$display("Correct: MEM[0] = %0d (expected 100)", uut.DM.mem[0]);
	end

	if (uut.DM.mem[1] !== 32'd70) begin
		$display("Error: MEM[1] incorrect = %0d (expected 70)", uut.DM.mem[1]);
		errors = errors + 1;
	end else begin
		$display("Correct: MEM[1] = %0d (expected 70)", uut.DM.mem[1]);
	end

	if (uut.DM.mem[2] !== 32'd800) begin
		$display("Error: MEM[2] incorrect = %0d (expected 800)", uut.DM.mem[2]);
		errors = errors + 1;
	end else begin
		$display("Correct: MEM[2] = %0d (expected 800)", uut.DM.mem[2]);
	end


// ============================
// FINAL RESULT
// ============================
	if (errors == 0)
		$display("\n TEST PASSED");
	else
		$display("\n TEST FAILED with %0d errors", errors);

#10;
$finish;
end

endmodule
