module IDEX_Reg(
    // Inputs
    clk, 
    reset_in,
    WB_in,
    M_in,
    EX_in,
    Reg1Data_in,
    Reg2Data_in, 
    Sext_in,
    Regt_in,
		Regd_in,
    Regs_in,
    // Outputs
    WB_out,
    M_out,
    EX_out,
    Reg1Data_out,
    Reg2Data_out,
		Sext_out,
    Regt_out,
    Regd_out,
    Regs_out
);

  output [31:0] Reg1Data_out, Reg2Data_out, Sext_out;
  output [4:0] Regt_out, Regd_out, Regs_out;
  output [1:0] WB_out;
  output [1:0] M_out;
  output [3:0] EX_out;
  input [31:0] Reg1Data_in, Reg2Data_in, Sext_in;
  input [4:0] Regt_in, Regd_in, Regs_in;
  input [1:0] WB_in;
  input [1:0] M_in;
  input [3:0] EX_in;
  input clk, reset_in;

    
  reg [118:0] state;
    
  always @(posedge clk) begin
    if (reset_in == 1'b1)begin
      state <= 119'b0;
    end
    else begin
      state <= {WB_in,  M_in,  EX_in,  Reg1Data_in, Reg2Data_in,  Sext_in,  Regt_in, Regd_in, Regs_in};
    end
      
  end //always

  assign {WB_out, M_out, EX_out, Reg1Data_out, Reg2Data_out, Sext_out, Regt_out, Regd_out, Regs_out} = state;

endmodule
