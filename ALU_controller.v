/*
see
- FIGURE B.5.16 The MIPS ALU control: a simple piece of combinational control logic.
- FIGURE 4.12 How the ALU control bits are set depends..
- http://alumni.cs.ucr.edu/~vladimir/cs161/mips.html
	all opcodes here

did we not have an ica for this? - update: we had nothing like this ever.
*/


module ALU_controller (ALUOp_in, funct_code, ALUOp_out);

					//coming from:
input [1:0] ALUOp_in;			//controller module?
input [5:0] funct_code;			//

output reg [3:0] ALUOp_out;		//goes to ALU itself

always @(*) begin
	case(ALUOp_in)
	0: ALUOp_out <= 4'h2; //add for lw and sw
	1: ALUOp_out <= 4'h6; //sub for beq
	
	//if r-type or otherwise
	2: begin
		case(funct_code)
            6'b100100: ALUOp_out <= 4'b0000;  //AND
            6'b100101: ALUOp_out <= 4'b0001;  //OR
            6'b100111: ALUOp_out <= 4'b1100;  //NOR
            6'b100000: ALUOp_out <= 4'b0010;  //ADD
            6'b100010: ALUOp_out <= 4'b0110;  //SUB
            6'b101010: ALUOp_out <= 4'b0111;  //SLT
            6'b011010: ALUOp_out <= 4'b1000;  //DIV
            6'b011000: ALUOp_out <= 4'b0101;  //MULT
            6'b010000: ALUOp_out <= 4'b0011;  //MFHI
            6'b010010: ALUOp_out <= 4'b0100;  //MFLO
			default: ALUOp_out <= ALUOp_out;
		endcase
	end
	default: ALUOp_out <= ALUOp_out;
	endcase
end

endmodule