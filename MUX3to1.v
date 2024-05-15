module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);

  parameter N = 32;

  output reg [N-1:0] data_out;
  input [N-1:0] data1_in, data2_in, data3_in;
  input [1:0] sel_in;

  always@(*) begin
    case(sel_in)
      0: data_out <= data1_in;
      1: data_out <= data2_in;
      2: data_out <= data3_in;
      default: data_out <= data_out;
    endcase
  end

endmodule
