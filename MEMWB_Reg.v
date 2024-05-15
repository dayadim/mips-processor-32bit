module MEMWB_Reg(WB_out, Add_out, DataMem_out, Regd_out, WB_in, Add_in, DataMem_in, Regd_in, clk, reset_in);

  output [31:0] Add_out, DataMem_out;
  output [4:0] Regd_out;
  output [1:0] WB_out;
  input [31:0] Add_in, DataMem_in;
  input [4:0] Regd_in;
  input [1:0] WB_in;
  input clk, reset_in;
    
  reg [70:0] state_internal;
    
  always @(posedge clk) begin
    if (reset_in == 1'b1)begin
      state_internal <= 0;
    end
    else begin
      state_internal <= {WB_in, DataMem_in, Add_in, Regd_in};
    end
      
  end 

  assign {WB_out, DataMem_out, Add_out, Regd_out} = state_internal;

endmodule
