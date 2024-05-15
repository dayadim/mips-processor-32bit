module Comparator (out, in1, in2);

  output reg out;
  input [31:0] in1, in2;

  always@(*) begin
    if (in1 == in2) begin
      out <= 1'b1;
    end
    else begin
      out <= 1'b0;
    end
  end

endmodule