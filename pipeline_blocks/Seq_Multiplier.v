module Seq_Multiplier #(parameter Width = 32, bits = 5)
(
//Inputs
input CLK, RST,
input Start,
input [Width - 1:0] Multiplicand, Multiplier,

//Outputs
output wire [2*Width - 1:0] Product,
output wire Ready
);


//Important Variables

reg [1:0] State, Next_State; //00: S_idle, 01: S_add, 10: S_shift
reg C;
reg [Width - 1:0] A, B, Q;
reg [bits - 1:0] P;

reg Dec_P, Shift_Regs, Load_Regs, Add_Regs; //Control Signals
wire Zero;


assign Ready = (State == 2'b00);
assign Zero = (P == 0);
assign Product = {A,Q};

// FSM Sequential Logic
always@(posedge CLK, posedge RST)
begin
	if(RST) State <= 2'b00; else State <= Next_State;
end

// FSM Output Logic
always@(State, Start, Q[0], Zero)
begin
	Next_State = 2'b00;
	Dec_P = 0;
	Shift_Regs = 0;
	Load_Regs = 0;
	Add_Regs = 0;
	
	case (State)
	
	2'b00: begin 
	Load_Regs = 1;
	if (Start) Next_State = 2'b01;
	end
	
	2'b01: begin
	Dec_P = 1;
	Next_State = 2'b10;
	if (Q[0]) Add_Regs = 1;
	end
	
	2'b10: begin
	Shift_Regs = 1;
	if(Zero) Next_State = 2'b00; else Next_State = 2'b01;
	end
	
	default:
	Next_State <= 2'b00;
	
	endcase
end

//Datapath
always@(posedge CLK)
begin

	if(Load_Regs) begin
		A <= 0;
		B <= Multiplicand;
		Q <= Multiplier;
		C <= 0;
		P <= Width;
	end
	
	if(Add_Regs) {C,A} <= A + B;
	
	if(Shift_Regs) {C,A,Q} <= {C,A,Q} >> 1;
	
	if(Dec_P) P <= P - 1;
	
end
endmodule
