module EXMEM_Reg(WB_out, M_out, ALUData_out, WriteData_out, Regd_out, WB_in, M_in, ALUData_in, WriteData_in, Regd_in, clk, reset_in);

  output [31:0] ALUData_out, WriteData_out;
  output [4:0] Regd_out;
  output [1:0] WB_out;
  output [1:0] M_out;
  input [31:0] ALUData_in, WriteData_in;
  input [4:0] Regd_in;
  input [1:0] WB_in; 
  input [1:0] M_in;
  input clk, reset_in;
    
  reg [72:0] state_internal;
    
  always @(posedge clk) begin
    if (reset_in == 1'b1)begin
      state_internal <= 0;
    end
    else begin
      state_internal <= {WB_in, M_in, ALUData_in, WriteData_in, Regd_in};
    end
      
  end //always

  assign {WB_out, M_out, ALUData_out, WriteData_out, Regd_out} = state_internal;

endmodule
