/*
same as the last few registers

*/

module MEM_WB_reg (
    input clk,
    input rst,
    input [1:0] WB_in,
    input [31:0] sum_in,
    input [31:0] mem_data_in,
    input [4:0] rd,
	//outs
    output [1:0] WB_out,
    output [31:0] sum_out,
    output [31:0] mem_data_out,
    output [4:0] rd_out
);

reg [70:0] pipeline_data;
	
always @(posedge clk) begin
	if (rst) pipeline_data <= 0;

	else pipeline_data <= {WB_in, mem_data_in, sum_in, rd};

end 

//use assign again. don't bother messing with output reg
assign {WB_out, mem_data_out, sum_out, rd_out} = pipeline_data;

endmodule