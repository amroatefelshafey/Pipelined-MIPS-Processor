`timescale 1ns/1ps
module ALU_tb();

	reg CLK;
	reg RST;
	reg [31:0] A, B;
	reg [2:0] ALUCtl;
	
	reg mfhi;
	reg Stall;
	
	wire [31:0] OUT;
	wire [63:0] Mult_OUT;
	wire Sign, Mult_READY;
	integer i;
	
	ALU DUT(CLK,RST,A,B,ALUCtl,OUT,Mult_OUT,Sign,Mult_READY);
	
	initial begin
		CLK = 0;
		force RST = 0;
		forever #5 CLK = ~CLK;
	end
	

	always@(posedge CLK) begin
		#10;
		$display("Time: %d | A = %d | B = %d | Product = %d | Ready = %b | OUT = %d", 
			  $time, $signed(A), $signed(B), $unsigned(Mult_OUT), Mult_READY, $signed(OUT));
	end

	initial begin
	
		// Case #1: Simulates running multu with other instructions in the pipeline
		ALUCtl = 3'bx00; // Assert Start (starts multu operation)
		A = 32'd10;
		B = 32'd10; // Input stimulus (expected 100 final result when Ready=1)
		#20;		// Wait for Multiplier to stabilize input
		ALUCtl = 3'b010; // Add operation, MSB is toggled every cycle to switch to sub
		for (i=0; i<66;i=i+1) begin
			#10;
			A = $random % 100;
			B = $random % 100;
			ALUCtl[2] = ~ALUCtl[2];
		end
		
		
		
		// Case #2: Simulate structural hazard (multu followed by multu).
		// Expected Result: Any # of multu operations following each other discards older
		// calls. In other words, only care about the most recent multu instruction.
		$display("--------------------- Case #2 ---------------------");
		ALUCtl = 3'bx00;
		for(i=0;i<6;i=i+1) begin
			A = $unsigned($random) % 10;
			B = $unsigned($random) % 10;
			force RST = 1;
			#10;
		end
		ALUCtl = 3'b010;
		force RST = 0;
		#650;
		release RST;
		
		// Case #3: Simulate data hazard (multu followed by mfhi/mflo).
		$display("--------------------- Case #3 ---------------------");
		force RST = 0;
		
		ALUCtl = 3'bx00;
		A = 10;
		B = 10;
		
		#100;
		mfhi = 1; // mfhi instruction detected 10 CC's after the multu
		
		for(i=0;i<56;i=i+1) begin
			if(!Mult_READY && mfhi) Stall = 1; else Stall = 0;
			if (Stall) $display("STALLING");
			#10;
		end
		
		$finish;
	end

endmodule
