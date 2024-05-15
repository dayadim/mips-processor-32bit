/*
use readmemh and writememh. similar to ostream

*/

`timescale 1ns/1ps

module data_mem #(parameter DATAFILE = "") (clk, wr_en, data_in, addr_in, data_out);

input clk, wr_en;
input [31:0] data_in, addr_in;
output [31:0] data_out;		//keep this as output

reg [31:0] internal_dataMem [0:255];

initial begin
	$readmemh(DATAFILE, internal_dataMem);
end

always@(posedge clk) begin
	if(wr_en) internal_dataMem[addr_in] <= data_in;

	$writememh(DATAFILE, internal_dataMem);
end

//always @ (*) begin
	assign data_out = internal_dataMem[addr_in];
//end

endmodule