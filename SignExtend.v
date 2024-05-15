module SignExtend(data_out, data_in);

  output reg [31:0] data_out;
  input [15:0] data_in;

  always@(*) begin
    if(data_in[15] == 1'b1) begin
      data_out = {16'hFFFF, data_in};
    end
    else begin
      data_out = {16'b0, data_in};
    end
  end


endmodule
