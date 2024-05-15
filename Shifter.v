module Shifter(data_out, data_in);

    output [31:0] data_out;
    input [31:0] data_in;

    assign data_out = data_in << 2;


endmodule
