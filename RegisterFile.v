`timescale 1ns/1ps

module RegisterFile(clk, data_in, Address_R1_in, Address_R2_in, Address_WriteReg_in, RegWrite_in, R1_out, R2_out, V0_out);

  input clk;
  input [31:0] data_in;
  input [4:0] Address_R1_in, Address_R2_in, Address_WriteReg_in;
  input RegWrite_in;
  output [31:0] R1_out, R2_out, V0_out;

  reg [31:0] Registers_internal [0:31];

  always@(negedge clk) begin
    if(RegWrite_in == 1)  begin
        Registers_internal[Address_WriteReg_in] <= data_in;
    end
    Registers_internal[0] <= 32'b0;
  end

  assign  R1_out = Registers_internal[Address_R1_in];
  assign  R2_out = Registers_internal[Address_R2_in];
  assign V0_out = Registers_internal[2]; // Based on MIPS Green Sheet


endmodule
