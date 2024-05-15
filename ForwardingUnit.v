module forwarding_unit(
	input [4:0] EX_MEM_rd, MEM_WB_rd, ID_EX_rs, ID_EX_rt,
	input EX_MEM_write, MEM_WB_write,
	output reg [1:0] fwd_A, fwd_B
);

// fwd_A
always @(*) begin
		//ex hazard
		if(EX_MEM_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs))
			fwd_A <= 2'b10;
		//mem hazard
		else if(MEM_WB_write && (MEM_WB_rd != 0) && ~(EX_MEM_write && (EX_MEM_rd != 0)) && (EX_MEM_rd != ID_EX_rs) && (MEM_WB_rd == ID_EX_rs))
			fwd_A <= 2'b01;
		else
			fwd_A <= 2'b00;
	end
	
// fwd_B
always @(*) begin
		//ex hazard
		if(EX_MEM_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt))
			fwd_B <= 2'b10;
		//mem hazard
		else if(MEM_WB_write && (MEM_WB_rd != 0) && ~(EX_MEM_write && (EX_MEM_rd != 0)) && (EX_MEM_rd != ID_EX_rt) && (MEM_WB_rd == ID_EX_rt))
			fwd_B <= 2'b01;
		else
			fwd_B <= 2'b00;
	end

endmodule

////------old code
/*
module fwd_unit (
	input		EX_MEM_write,  // if EX/MEM stage writes back to regfile
	input 		MEM_WB_write,  // if MEM/WB stage writes back to regfile
	input [4:0] ID_EX_rs,  // src reg in ID/EX stage
	input [4:0] ID_EX_rt,  // targ reg in ID/EX stage
	input [4:0] EX_MEM_rd,  // dest reg in EX/MEM stage
	input [4:0] MEM_WB_rd,  // dest reg in MEM/WB stage
	output reg [1:0] fwd_A,
	output reg [1:0] fwd_B
	);


// fwd_A
always @(*)
	begin
		//ex hazard
		if(EX_MEM_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs))
			fwd_A <= 2'b10;
		//mem hazard
		else if(MEM_WB_write && (MEM_WB_rd != 0) && ~(EX_MEM_write && (EX_MEM_rd != 0)) && (EX_MEM_rd != ID_EX_rs) && (MEM_WB_rd == ID_EX_rs))
			fwd_A <= 2'b01;
		else
			fwd_A <= 2'b00;
	end
	
// fwd_B
always @(*)
	begin
		//ex hazard
		if(EX_MEM_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt))
			fwd_B <= 2'b10;
		//mem hazard
		else if(MEM_WB_write && (MEM_WB_rd != 0) && ~(EX_MEM_write && (EX_MEM_rd != 0)) && (EX_MEM_rd != ID_EX_rt) && (MEM_WB_rd == ID_EX_rt))
			fwd_B <= 2'b01;
		else
			fwd_B <= 2'b00;
	end

endmodule


*/