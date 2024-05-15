`timescale 1ns/1ps

module Adder(sum_out, a_in, b_in);

    output [31:0] sum_out;
    input [31:0] a_in, b_in;

    assign sum_out = a_in + b_in;


endmodule
