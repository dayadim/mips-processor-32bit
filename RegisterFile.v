/*
see ica 12
Modify the register file such that it reads its new data input near the beginning of the clock cycle while its outputs will be read near the end of the clock cycle.

"C:\Users\amaan_r7vd8kf\OneDrive - Fresno State\174 Adv Comp Arch\green card 2.jpg"
v0 is reg[2]

*/
`timescale 1ns/1ps

module Registers (
	input clk,
	input regwrite,		//weird syntax highlighting on this input. don't put at end
	input [31:0] write_data,
	input [4:0] addr_1,
	input [4:0] addr_2,
	input [4:0] addr_write_reg,
	output [31:0] read_data_1,
	output [31:0] read_data_2
	//output [31:0] read_v0
);


reg [31:0] regfile [0:31];

always @(negedge clk) begin
	regfile[0] <= 32'b0;	//set reg 0 to zero

	if (regwrite) regfile[addr_write_reg] <= write_data;
end

assign read_data_1 = regfile[addr_1];
assign read_data_2 = regfile[addr_2];
//assign read_v0 = regfile[2];		//delete latere

endmodule


/*
/////////////////////////---OLD CODE

module Registers(
output reg [31:0] read_data_1,
output reg [31:0] read_data_2,
input [4:0] read_reg_1,
input [4:0] read_reg_2,
input [4:0] write_reg,
input [31:0] write_data,
input regwrite,
input clk);

reg [31:0] regfile [0:31];
initial begin
regfile[0] = 31'60000;
regfile [2] = 31'b1010;
regfile[4] = 31'b0100;
regfile[6] = 31'b0110;
regfile [8] = 31'b1000;
regfile [10] = 31'b1010;
regfile [12] = 31'b1100;
regfile [14] = 31'b1110;
end

always@(negedge clk)
begin
if (regwrite == 1)
begin
regfile[write_reg] = write_data;
end //if
end // always@(posedge)

always@(read_reg_1, read_reg_2)
begin
read_data_1 = regfile[read_reg_1]; read_data_2 = regfile [read_reg_2];
end //always @(read...)
endmodule

*/