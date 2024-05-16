/*
see FIGURE B.5.15 A Verilog behavioral definition of a MIPS ALU
*/

module ALU(result, in1, in2, ALUOp_in);
	
								//coming from:
	input [31:0] in1;			//- reg file?
	input [31:0] in2; 			//-	^
	input [3:0] ALUOp_in;				//- alu control module	//fixed sizing error

							//goes to:	
	output reg [31:0] result;	//- addr of data mem
							//	- a 2 to 1 mux after data mem

	reg [31:0] hi, lo;

	always @ (*) begin
		case(ALUOp_in)
			//abd
			0: result <= in1 & in2;
			//or
			1: result <= in1 | in2;
			//add
			2: result <= in1 + in2;
			//mfhi
			3: result <= hi;
			//mflo
			4: result <= lo;
			//mult
			5: begin
				{hi, lo} = in1 * in2;
				result <= lo;
			end
			//sub
			6: result <= in1 - in2;
			//slt
			7: if(in1 < in2) result <= 1;
			//div
			8: begin
				if (in2 != 0) begin
					lo = in1 / in2;
					hi = in1 % in2;
					result <= lo;
				end
			end
			//nor
			12: result <= ~(in1 | in2);
			
			//
			default: result <= 0;

		endcase

	end


endmodule
