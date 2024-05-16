/*
figure 4.17 The simple datapath with the control unit.
inputs:
5 bit instr
outputs:
reg dest - mux before write data of regfile
branch - and gate?
mem read - data mem
mem to reg - data mem after mux
alu op - alu controller
mem write - data mem
alu src - mux before alu
regwrite - regfile

figure 4.18

FIGURE 4.22 The control function for the simple single-
cycle implementation is completely specified by this
truth table.

important:
FIGURE 4.50 and 4.51 shows what signals go where
	i think figure 4.51 doesn't show everything
	WB is RegWrite and MemToReg
	MEM is MemRead and MemWrite
	EX is RegDest, ALUOp and ALUSrc
	jump and branch are their own.

FIGURE 4.24 incorporates the jump instr - not shown anywhere else
*/

module Control (
	input [5:0] instruction,
	output [1:0] WB, MEM,
	output [3:0] EX,
	output reg jump, branch
	);

	//internal data regs
	reg [1:0] ALUOp;
	reg RegDest, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;


//DO NOT USE X'S USE 0S. WEIRD ERRORS
	always @ (*) begin
		case (instruction)
			//rtype
			6'b000000: begin
				RegDest = 1;
				branch = 0;
				MemRead = 0;
				MemToReg = 0;
				ALUOp = 2'b10;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 1;
				jump = 0;
			end
			
			//addi
			6'b001000: begin
				RegDest = 1'bx;
				branch = 0;
				MemRead = 1'bx;
				MemToReg = 0;
				ALUOp = 2'b00;
				MemWrite = 0;
				ALUSrc = 1;
				RegWrite = 1;
				jump = 0;
			end
			
			//lw
			6'b100011: begin
				RegDest = 0;
				branch = 0;
				MemRead = 1;
				MemToReg = 1;
				ALUOp = 2'b00;
				MemWrite = 0;
				ALUSrc = 1;
				RegWrite = 1;
				jump = 0;
			end

			//sw
			6'b101011: begin
				RegDest = 1'bx;
				branch = 0;
				MemRead = 0;
				MemToReg = 1'bx;
				ALUOp = 2'b00;
				MemWrite = 1;
				ALUSrc = 1;
				RegWrite = 0;
				jump = 0;
			end

			//beq
			6'b000100: begin
				RegDest = 1'bx;
				branch = 1;
				MemRead = 0;
				MemToReg = 0;
				ALUOp = 2'b01;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
				jump = 0;
			end

			//jump
			6'b000010: begin
				RegDest = 1'bx;
				branch = 0;
				MemRead = 1'bx;
				MemToReg = 0;
				ALUOp = 2'b00;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
				jump = 1;
			end

			default: begin
				RegDest = 0;
				branch = 0;
				MemRead = 0;
				MemToReg = 0;
				ALUOp = 2'b00;
				MemWrite = 0;
				ALUSrc = 0;
				RegWrite = 0;
				jump = 0;
			end
		endcase
	end

	assign WB = {RegWrite, MemToReg};
	assign MEM = {MemRead, MemWrite};
	assign EX = {RegDest, ALUOp, ALUSrc};

endmodule
