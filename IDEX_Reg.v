/*
FIGURE 4.38 MEM and WB: The fourth and fifth pipe
stages of a load instruction, highlighting the portions of
the datapath in Figure 4.35 used in this pipe stage.
*/

//keep inputs and outputs together. nightmare to wire otherwise
module ID_EX_reg(
	input clk,
	input rst,
	input [1:0] WB_in,
	input [1:0] M_in,
	input [3:0] EX_in,
	input [31:0] data_r1,
	input [31:0] data_r2,
	input [31:0] signExt_in,
	input [4:0] rt,
	input [4:0] rd,
	input [4:0] rs,
	output [1:0] WB_out,
	output [1:0] M_out,
	output [3:0] EX_out,
	output [31:0] data_r1_out,
	output [31:0] data_r2_out,
	output [31:0] signExt_out,
	output [4:0] rt_out,
	output [4:0] rd_out,
	output [4:0] rs_out
);

reg [118:0] pipeline_data;
	
always @(posedge clk) begin
	if (rst) pipeline_data <= 119'b0;

	else pipeline_data <= {WB_in, M_in, EX_in, data_r1, data_r2, signExt_in, rt, rd, rs};
	
end

assign {WB_out, M_out, EX_out, data_r1_out, data_r2_out, signExt_out, rt_out, rd_out, rs_out} = pipeline_data;

endmodule