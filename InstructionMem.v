
//
//
// Simulation Module
//
//
`timescale 1ns/1ps

module InstructionMemory #(parameter FILE = "") (data_out, address_in);

  output [31:0] data_out;
  input [31:0] address_in;

  reg [31:0] memory_internal [0:255];

  initial begin
    $readmemh(FILE, memory_internal);
  end

  assign data_out = memory_internal[address_in];


endmodule


//
//
// FPGA Module
//
//
/*
module InstructionMemory #(parameter MEM_SIZE = 256) (data_out, address_in, clk);
  output reg [31:0] data_out;
  input [31:0] address_in;
  input clk;

  reg [31:0] Memory_internal [0:MEM_SIZE-1];

  always @(posedge clk) begin
    data_out <= Memory_internal[address_in];
  end
endmodule

*/