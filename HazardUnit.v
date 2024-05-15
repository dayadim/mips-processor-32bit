/*
hazard unit needs big overhaul

https://www.youtube.com/watch?v=79sveBM0OsU&list=PL5AmAh9QoSK4fNTAQf2g-1s6FvQ8edoWd&index=9

or just read section 4.8 on data hazards and 4.8 control hazards

*/

module HazardUnit (
	input ID_EX_MemRead,
	input EX_MEM_MemRead,
	input EX_MEM_memToReg,
	input [4:0] ID_EX_rt,
	input [4:0] EX_MEM_rt,
	input [4:0] IF_ID_rs,
	input [4:0] IF_ID_rt,
	input br,
	input comparison_in,
	input jump,
	output reg IF_ID_wr_en,
	output reg PC_wr_en,
	output reg nop_flag,
	output reg flush_flag
);

//reg [3:0] internal_data	//removed. used indiv output regs instead instead

always @(*) begin
	//standard load hzards
	if ((ID_EX_MemRead && ((ID_EX_rt == IF_ID_rs) || ID_EX_rt == IF_ID_rt)) ||
		(EX_MEM_memToReg && ((EX_MEM_rt == IF_ID_rs) || (EX_MEM_rt == IF_ID_rt)))) begin
		IF_ID_wr_en = 1'b0;
		PC_wr_en = 1'b0;
		nop_flag = 1'b1;
	end

	//branching hazards
	else if(br == 1'b1) begin
		 //second condition in if statement: if load to reg after use in br second instr, before br
		if ((ID_EX_MemRead && ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt))) ||
		(EX_MEM_MemRead && ((EX_MEM_rt == IF_ID_rs) || (EX_MEM_rt == IF_ID_rt)))) begin
			PC_wr_en = 1'b0;
			IF_ID_wr_en = 1'b0;
			nop_flag = 1'b1;
		end else if (comparison_in) begin
			//if branching
			PC_wr_en = 1'b1;
			IF_ID_wr_en = 1'b1;
			nop_flag = 1'b0;
			flush_flag = 1'b1;
		end
	end

	else if (jump) begin
		PC_wr_en = 1'b1;
		IF_ID_wr_en = 1'b1;
		nop_flag = 1'b0;
		flush_flag = 1'b1;
	end
	
	else begin
		PC_wr_en = 1'b1;
		IF_ID_wr_en = 1'b1;
		nop_flag = 1'b0;
		flush_flag = 1'b0;
	end
end

endmodule