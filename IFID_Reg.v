module IFID_Reg(Ins_out, PC_in, PC_out, Ins_in, write_in, clk, reset_in, flush_in);

  output [31:0] Ins_out, PC_out;
  input [31:0] Ins_in, PC_in;
  input clk, reset_in, flush_in, write_in;
    
  reg [63:0] state_internal;
    
  always @(posedge clk) begin
    if (reset_in == 1'b1)begin
      state_internal <= 0;
    end
    else if (flush_in == 1'b1)begin
      state_internal <= {32'b0, PC_in};
    end
    else begin
      if(write_in == 1'b1)
        state_internal <= {Ins_in, PC_in};
    end
      
  end //always
    assign {Ins_out, PC_out} = state_internal;

endmodule
