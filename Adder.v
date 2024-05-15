module adder(sum, in1, in2);
    output [31:0] sum;
    input [31:0] in1, in2;

    assign sum = in1 + in2;

endmodule