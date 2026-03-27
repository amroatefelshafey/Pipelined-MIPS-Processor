module Adder_Subtractor ( 
						 input [31:0] A, B,
						 input M,     // Mode, 0 for A + B || 1 for A - B    
						 output [31:0] OUT, 
						 output Cout
						); 
						
wire [31:0] Carry; // Cout of the ith FA
wire [31:0] B_modified; 
assign B_modified = B ^ {32{M}};   // Invert all bits if Cin=1 

genvar i; 
generate 
	for (i = 0; i < 32; i = i + 1) begin : ADD_SUB_LOOP 
		if (i == 0) 
			full_adder FA (A[i], B_modified[i], M, OUT[i], Carry[i]); 
		else 
			full_adder FA (A[i], B_modified[i], Carry[i-1], OUT[i], Carry[i]); 
	end 
	
endgenerate 

assign Cout = Carry[31]; 

endmodule
