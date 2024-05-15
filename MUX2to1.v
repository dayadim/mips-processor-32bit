module MUX2to1(data_out, data1_in, data2_in, sel_in);

  parameter N = 32;

  output reg [N-1:0] data_out;
  input [N-1:0] data1_in, data2_in;
  input sel_in;

  always@(*) begin
    data_out <= sel_in ? data2_in : data1_in;
  end

endmodule
