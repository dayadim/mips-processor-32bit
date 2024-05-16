`timescale 1ns/1ps
module top_module (clock, reset);
	localparam instructionFile = "Program.txt";
	localparam dataFile = "Memory.txt";

	/*********FGPA Inputs********/
	input clock, reset;
	/****************************/

	/**********IF Vars***********/
	wire [31:0] IF_addr_out, IF_addr_in, IF_addrPlus4, IF_instr, IF_b_mux_out, IF_jump_mux_out;
	wire IF_addr_wr;
	/****************************/

	/*********IFID Vars**********/
	wire [31:0] IF_ID_instr_in, IF_ID_addr_out;
	wire IF_ID_wr_en;
	/****************************/

	/**********ID Vars***********/
	wire [31:0] ID_signExt_out, ID_br_shifted__out, ID_jump_shifted_out, ID_br_out, ID_r1_out, ID_r2_out;
	wire [1:0] ID_WB, ID_Mem;
	wire [3:0] ID_Exec;
	wire [7:0] ID_Exec_Mux_out;
	wire ID_flush_signal, ID_jump, ID_br, ID_cmp_out, ID_nop_signal;
	/****************************/

	/**********EX Vars***********/
	wire [31:0] EX_r1_out, EX_r2_out, EX_sel, EX_mux_fwd1, EX_mux_fwd2, EX_ALUSrc_mux_out, EX_ALU_out;
	wire [1:0] EX_WB, EX_Mem;
	wire [3:0] EX_Exec, EX_ALU_control;
	wire [4:0] EX_rt, EX_rd, EX_rs, EX_rd_mux_out;
	wire [1:0] EX_fwdA, EX_fwdB;
	wire EX_zero;
	/****************************/

	/**********MEM Vars**********/
	wire [31:0] MEM_ALU, MEM_wrData, MEM_data_out, MEM_br_mux_out;
	wire [1:0] MEM_WB, MEM_mem;
	wire [4:0] MEM_rd;
	/****************************/

	/**********WB Vars***********/
	wire [31:0] WB_ALU, WB_dataMem;
	wire [1:0] WB_WB;
	wire [4:0] WB_rd;
	/****************************/

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U0(
		// Outputs
		.out(IF_b_mux_out),
		// Inputs
		.in1(IF_addrPlus4), 
		.in2(ID_br_out), 
		.sel(ID_br)
	); 

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U1(
		// Outputs
		.out(IF_jump_mux_out),
		// Inputs
		.in1(IF_b_mux_out),
		.in2({IF_addrPlus4[31:28], ID_jump_shifted_out[27:0]}),
		.sel(ID_jump)
	);

	// module PCReg(address_out, address_in, clk, reset_in, write_in);
	PC U2(
		// Outputs
		.addr_out(IF_addr_out), 
		// Inputs
		.addr_in(IF_jump_mux_out), 
		.clk(clock),
		.rst(reset), 
		.write_en(IF_addr_wr)
	);

	adder U3(
		// Outputs
		.sum(IF_addrPlus4), 
		// Inputs
		.in1(IF_addr_out), 
		.in2(32'h4)
	);

	// module InstructionMemory #(FILE = "") (data_out, address_in);
	instr_mem #(instructionFile) U4(
		// Outputs
		.instr_data(IF_instr), 
		// Inputs
		.addr_in(IF_addr_out)
	);


	// module IFID_Reg(Ins_out, PC_in, PC_out, Ins_in, write_in, clk, reset_in, flush_in);
IF_ID_reg U5 (
	// Outputs
	.instr_out(IF_ID_instr_in),
	.addr_out(IF_ID_addr_out),
	// Inputs
	.addr_in(IF_addrPlus4),
	.instr_in(IF_instr),
	.wr_en(IF_ID_wr_en),
	.clk(clock),
	.rst(reset),
	.flush(ID_flush_signal)
);

															
	
	// module Control(WB_out, M_out, EX_out, Jmp_out, Branch_out, Ins_in);
	Control U6(
		// Outputs
		.WB(ID_WB),
		.MEM(ID_Mem),
		.EX(ID_Exec),
		.jump(ID_jump),
		.branch(ID_br),
		// Inputs
		.instruction(IF_ID_instr_in[31:26])
	);

	// module RegisterFile(clk, data_in, Address_R1_in, Address_R2_in, Address_WriteReg_in, RegWrite_in, R1_out, R2_out);
Registers U7(
    // Outputs
    .read_data_1(ID_r1_out),
    .read_data_2(ID_r2_out),
    //.read_v0(v0_wire), // Commented out as v0_wire is not an output of the module
    // Inputs
    .clk(clock), 
    .regwrite(WB_WB[1]), // Assuming WB_WB[1] is the regwrite signal
    .write_data(MEM_br_mux_out),
    .addr_1(IF_ID_instr_in[25:21]),
    .addr_2(IF_ID_instr_in[20:16]),
    .addr_write_reg(WB_rd)
);


	// module Comparator(bool_out, data1_in, data2_in);
	Comparator U8(
		// Outputs
		.out(ID_cmp_out),
		// Inputs
		.in1(ID_r1_out),
		.in2(ID_r2_out)
	);

	// module HazardUnit(IDEXMemRead_in, EXMEMMemRead_in, EXMEMMemToReg_in, IDEXRegt_in, EXMEMRegt_in, IFIDRegs_in, IFIDRegt_in, branch_in, ComparatorResult_in, jmp_in, IFIDWrite_out, PCWrite_out, NOP_out, FLUSH_out);
HazardUnit U9(
	// Outputs
	.IF_ID_wr_en(IF_ID_wr_en),
	.PC_wr_en(IF_addr_wr),
	.nop_flag(ID_nop_signal),
	.flush_flag(ID_flush_signal),
	// Inputs
	.ID_EX_MemRead(EX_Mem[1]),
	.EX_MEM_MemRead(MEM_mem[1]),
	.EX_MEM_memToReg(MEM_WB[0]),
	.ID_EX_rt(EX_rt),
	.EX_MEM_rt(MEM_rd),
	.IF_ID_rs(IF_ID_instr_in[25:21]),
	.IF_ID_rt(IF_ID_instr_in[20:16]),
	.br(ID_br),
	.comparison_in(ID_cmp_out),
	.jump(ID_jump)
);


	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_8bit U10(
		// Outputs
		.out(ID_Exec_Mux_out),
		// Inputs
		.in1({ID_WB,ID_Mem, ID_Exec}),
		.in2(8'b0),
		.sel(ID_nop_signal)
	);
	
	// module SignExtend(data_out, data_in);
	sign_extend U11(
		// Outputs
		.out(ID_signExt_out),
		// Inputs
		.in(IF_ID_instr_in[15:0])
	);

	// module Shifter(data_out, data_in);
	shift U12(
		// Outputs
		.out(ID_br_shifted__out),
		// Inputs
		.in(ID_signExt_out)
	);

	// module Shifter(data_out, data_in);
	shift U13(
		// Outputs
		.out(ID_jump_shifted_out),
		// Inputs
		.in({6'b0,IF_ID_instr_in[25:0]})
	);

	adder U14(
		// Outputs
		.sum(ID_br_out),
		// Inputs
		.in1(IF_ID_addr_out),
		.in2(ID_br_shifted__out)
	);
	

	// module IDEX_Reg(WB_in,  M_in,  EX_in,  Reg1Data_in, Reg2Data_in,  Sext_in,  Regt_in, Regd_in, Regs_in, WB_out, M_out, EX_out, Reg1Data_out, Reg2Data_out, Sext_out, Regt_out, Regd_out, Regs_out, clk, reset_in);
ID_EX_reg U15(
	// Outputs
	.WB_out(EX_WB),
	.M_out(EX_Mem),
	.EX_out(EX_Exec),
	.data_r1_out(EX_r1_out),
	.data_r2_out(EX_r2_out),
	.signExt_out(EX_sel),
	.rt_out(EX_rt),
	.rd_out(EX_rd),
	.rs_out(EX_rs),
	// Inputs
	.clk(clock),
	.rst(reset),
	.WB_in(ID_Exec_Mux_out[7:6]),
	.M_in(ID_Exec_Mux_out[5:4]),
	.EX_in(ID_Exec_Mux_out[3:0]),
	.data_r1(ID_r1_out),
	.data_r2(ID_r2_out),
	.signExt_in(ID_signExt_out),
	.rt(IF_ID_instr_in[20:16]),
	.rd(IF_ID_instr_in[15:11]),
	.rs(IF_ID_instr_in[25:21])
);

	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U16(
		// Outputs
		.dataOut(EX_mux_fwd1), 
		// Inputs
		.in1(EX_r1_out), 
		.in2(MEM_br_mux_out), 
		.in3(MEM_ALU),
		.sel_in(EX_fwdA)
	); 

	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U17(
		// Outputs
		.dataOut(EX_mux_fwd2), 
		// Inputs
		.in1(EX_r2_out), 
		.in2(MEM_br_mux_out), 
		.in3(MEM_ALU),
		.sel_in(EX_fwdB)
	);
	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U18(
		// Outputs
		.out(EX_ALUSrc_mux_out),
		// Inputs
		.in1(EX_mux_fwd2),
		.in2(EX_sel),
		.sel(EX_Exec[0])
	);

	// module ALUControl(ALUOp_in, Funct_in, Data_out);
	ALU_controller U19(
		// Outputs
		.ALUOp_out(EX_ALU_control),
		// Inputs
		.ALUOp_in(EX_Exec[2:1]),
		.funct_code(EX_sel[5:0])
	);

	// module ALU(data_out, ZEROFLAG_out, data1_in, data2_in, ALUOp_in);
	ALU U20(
		// Inputs
		.in1(EX_mux_fwd1),
		.in2(EX_ALUSrc_mux_out),
		.ALUOp_in(EX_ALU_control),
		// Outputs
		.result(EX_ALU_out),
		.zeroFlag(EX_zero)

	);

	// module ForwardingUnit(IDEXRegs_in, IDEXRegt_in, EXMEMRegWrite_in, EXMEMRegd_in, MEMWBRegd_in, MEMWBRegWrite_in, ForwardA_out, ForwardB_out);
forwarding_unit U21 (
	// Outputs
	.fwd_A(EX_fwdA),
	.fwd_B(EX_fwdB),
	// Inputs
	.ID_EX_rs(EX_rs),
	.ID_EX_rt(EX_rt),
	.EX_MEM_write(MEM_WB[1]),
	.EX_MEM_rd(MEM_rd),
	.MEM_WB_rd(WB_rd),
	.MEM_WB_write(WB_WB[1])
);


	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_5bit U22(
		// Outputs
		.out(EX_rd_mux_out),
		// Inputs
		.in1(EX_rt),
		.in2(EX_rd),
		.sel(EX_Exec[3])
	);
	
	
	// module EXMEM_Reg(WB_out, M_out, ALUData_out, WriteData_out, Regd_out, WB_in, M_in, ALUData_in, WriteData_in, Regd_in, clk, reset_in);
	ExMemReg U23(
		// Outputs
		.WBOut(MEM_WB),
		.MemOut(MEM_mem), 
		.ALUOut(MEM_ALU), 
		.WriteOut(MEM_wrData), 
		.RegdOut(MEM_rd),
		// Inputs
		.WBIn(EX_WB), 
		.MemIn(EX_Mem), 
		.ALUIn(EX_ALU_out), 
		.WriteIn(EX_mux_fwd2), 
		.RegdIn(EX_rd_mux_out), 
		.reset(reset),
		.clk(clock)
	);
		

	

	// module DataMemory #(FILE = "") (data_out, data_in, address_in, write_in, clk);
	data_mem #(dataFile) U24(
		// Outputs
		.data_out(MEM_data_out),
		// Inputs
		.data_in(MEM_wrData),
		.addr_in(MEM_ALU),
		.wr_en(MEM_mem[0]),
		.clk(clock)
	);
	

	// module MEMWB_Reg(WB_out, Add_out, DataMem_out, Regd_out, WB_in, Add_in, DataMem_in, Regd_in, clk, reset_in);
	MEM_WB_reg U25(
		// Outputs
		.WB_out(WB_WB), 
		.sum_out(WB_ALU), 
		.mem_data_out(WB_dataMem), 
		.rd_out(WB_rd), 
		// Inputs
		.WB_in(MEM_WB), 
		.sum_in(MEM_ALU), 
		.mem_data_in(MEM_data_out),
		.rd(MEM_rd), 
		.clk(clock), 
		.rst(reset)
	);

	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U26(
		.out(MEM_br_mux_out),
		.in1(WB_ALU),
		.in2(WB_dataMem),
		.sel(WB_WB[0])
	);



endmodule