//For simulation use only//
//Not synthesizeable//

`timescale 1ns/1ps

//
//  SIMULATION MODULE
//
//
module DataMemory #(parameter FILE = "") (data_out, data_in, address_in, write_in, clk);

  output [31:0] data_out;
  input [31:0] data_in, address_in;
  input write_in, clk;

  reg [31:0] Memory_internal [0:255];

  initial
    // Not synthesizable
    $readmemh(FILE, Memory_internal);

  always@(posedge clk) begin
    if(write_in == 1'b1)  begin
        Memory_internal[address_in] <= data_in;
    end
    $writememh(FILE, Memory_internal);
  end


  assign data_out = Memory_internal[address_in];


endmodule


//
//
//  FPGA Module
//
//
/*
module DataMemory #(parameter MEM_SIZE = 256) (data_out, data_in, address_in, write_in, clk);

  output [31:0] data_out;
  input [31:0] data_in, address_in;
  input write_in, clk;

  reg [31:0] Memory_internal [0:MEM_SIZE-1];

  always @(posedge clk) begin
    if (write_in) begin
      Memory_internal[address_in] <= data_in;
    end
  end

  assign data_out = Memory_internal[address_in];

endmodule
*/