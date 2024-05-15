module Comparator(bool_out, data1_in, data2_in);

  output reg bool_out;
  input [31:0] data1_in, data2_in;

  always@(*) begin
    if(data1_in == data2_in) begin
      bool_out = 1'b1;
    end
    else begin
      bool_out = 1'b0;
    end
  end

endmodule
