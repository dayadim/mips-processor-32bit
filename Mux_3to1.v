module MUX3to1(dataOut, in1, in2, in3, sel_in);

  parameter N = 32;

  output reg [N-1:0] dataOut;
  input [N-1:0] in1, in2, in3;
  input [1:0] sel_in;

  always @ (*) begin
    case(sel_in)
      0: dataOut <= in1;
      1: dataOut <= in2;
      2: dataOut <= in3;
      default: dataOut <= dataOut;
    endcase
  end

endmodule
