module ExMemReg(
output [1:0] WBOut, MemOut,
output [31:0] ALUOut, WriteOut,
output [4:0] RegdOut,
input [1:0] WBIn, MemIn,
input [31:0] ALUIn, WriteIn,
input [4:0] RegdIn,
input clk, reset);

  reg [72:0] pipelined_data;
    
  always @(posedge clk) begin
    if (reset == 1'b1)begin
      pipelined_data <= 0;
    end
    else begin
      pipelined_data <= {WBIn, MemIn, ALUIn, WriteIn, RegdIn};
    end
      
  end

  assign {WBOut, MemOut, ALUOut, WriteOut, RegdOut} = pipelined_data;

endmodule