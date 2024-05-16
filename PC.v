/*
section 4.3 - datapath

FIGURE 4.6 A portion of the datapath used for fetching
instructions and incrementing the program counter.

desc: provides mem addr of next instr with use of adder to instr mem
	holds current address of instruction memory.
	updates on pos edge clk
	sync reset

notes:
	addr out is output reg. can be used within always block

*/

module PC (clk, rst, write_en, addr_in, addr_out);

input clk, rst, write_en;
input [31:0] addr_in;

output reg [31:0] addr_out;

always @ (posedge clk) begin
	if (rst) addr_out <= 32'b0;
	else
		if (write_en) addr_out <= addr_in;
end

endmodule