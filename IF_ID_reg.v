/*
! no TB yet. VERIFY BEFORE RUNS

FIGURE 4.35 The pipelined version of the datapath in

Section 4.7 Assume Branch Not Taken - why we flush.

READ:
instr_out will feed 32 bits out instead of several outputs.
this cuts down on our code and number of wires. we can have one and choose 
    a number of bits from this single output


*/

module IF_ID_reg (
	input clk,
    input rst,
    input wr_en,				//write
    input flush,				//see sec 4.7 for why we need a flush
    input [31:0] instr_in,
    output [31:0] instr_out,    //outputs can't be regs otherwise we're limited to clk
    input [31:0] addr_in,
    output [31:0] addr_out
);

parameter N = 64;	//unsure about size so parameterized. prob 64 bits

reg [N-1:0] pipeline_data;	//first half instr, second half address

//we need to always be updating our internal data. converted to one liner
//assign instr_out = data[(N/2)-1:0];
//assign addr_out = data[N-1:(N/2)];

assign {instr_out, addr_out} = pipeline_data;

always @ (posedge clk) begin
	if (rst) pipeline_data <= 0;

	else if (flush) pipeline_data <= {32'b0, addr_in};

	else if (wr_en) pipeline_data <= {instr_in, addr_in};
end

endmodule