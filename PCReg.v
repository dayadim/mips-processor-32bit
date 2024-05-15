module PCReg(address_out, address_in, clk, reset_in, write_in);

  output [31:0] address_out;
  input [31:0] address_in;
  input clk, reset_in, write_in;

  reg [31:0] state_internal;

  always@(posedge clk) begin
    if(reset_in == 1'b1) begin
      state_internal <= 32'b0;
    end
    else begin
      if(write_in == 1'b1)
        state_internal <= address_in;
    end
  end

  assign address_out = state_internal;

endmodule
