`timescale 1ns/1ps

module CPU(CLK_IN, GLOBALRESET);
	localparam INSMEMFILE = "Program.txt";
	localparam DATAMEMFILE = "Memory.txt";

	/*********FGPA Inputs********/
	input CLK_IN, GLOBALRESET;
	/****************************/

	/**********IF Vars***********/
	wire [31:0] IF_PC_out, IF_PC_in, IF_PCnext, IF_Ins, IF_Branch_MUX_out, IF_Jmp_MUX_out;
	wire IF_PCWrite;
	/****************************/

	/*********IFID Vars**********/
	wire [31:0] IFID_Ins, IFID_PC_out;
	wire IFID_WriteSignal;
	/****************************/

	/**********ID Vars***********/
	wire [31:0] ID_SE_out, ID_BS_2_out, ID_Jump_2_out, ID_BranchPred_out, ID_Reg_1_out, ID_Reg_2_out;
	wire [1:0] ID_WriteBack, ID_Mem;
	wire [3:0] ID_Exec;
	wire [7:0] ID_ExecMUX_out;
	wire FLUSH, ID_Jmp, ID_Branch, ID_Write_CPC, ID_Comparator_out, NOP;
	/****************************/

	/**********EX Vars***********/
	wire [31:0] EX_Reg1_out, EX_Reg2_out, EX_Select, EX_MUX_OP1_out, EX_MUX_OP2_out, EX_ALUSourceMUX_out, EX_ALU_out;
	wire [1:0] EX_WriteBack, EX_Mem;
	wire [3:0] EX_Exec, EX_ALUcon;
	wire [4:0] EX_Regt, EX_Regd, EX_Regs, EX_RegDst_MUX_out;
	wire [1:0] EX_ForwardingA, EX_ForwardingB;
	wire EX_ZEROFLAG;
	/****************************/

	/**********MEM Vars**********/
	wire [31:0] MEM_ALU, MEM_WriteData, MEM_DataMemory_out, MEM_BranchMUX_out;
	wire [1:0] MEM_WriteBack, MEM_Memory;
	wire [4:0] MEM_Regd;
	/****************************/

	/**********WB Vars***********/
	wire [31:0] WB_ALU, WB_DataMemory;
	wire [1:0] WB_WriteBack;
	wire [4:0] WB_Regd;
	/****************************/

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U0(
		// Outputs
		.out(IF_Branch_MUX_out),
		// Inputs
		.in1(IF_PCnext), 
		.in2(ID_BranchPred_out), 
		.sel(ID_Branch)
	); 

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U1(
		// Outputs
		.out(IF_Jmp_MUX_out),
		// Inputs
		.in1(IF_Branch_MUX_out),
		.in2({IF_PCnext[31:28], ID_Jump_2_out[27:0]}),
		.sel(ID_Jmp)
	);

	// module PCReg(address_out, address_in, clk, reset_in, write_in);
	PC U2(
		// Outputs
		.addr_out(IF_PC_out), 
		// Inputs
		.addr_in(IF_Jmp_MUX_out), 
		.clk(CLK_IN),
		.rst(GLOBALRESET), 
		.write_en(IF_PCWrite)
	);

	adder U3(
		// Outputs
		.sum(IF_PCnext), 
		// Inputs
		.in1(IF_PC_out), 
		.in2(32'h4)
	);

	// module InstructionMemory #(FILE = "") (data_out, address_in);
	instr_mem #(INSMEMFILE) U4(
		// Outputs
		.instr_data(IF_Ins), 
		// Inputs
		.addr_in(IF_PC_out)
	);


	// module IFID_Reg(Ins_out, PC_in, PC_out, Ins_in, write_in, clk, reset_in, flush_in);
IF_ID_reg U5 (
	// Outputs
	.instr_out(IFID_Ins),
	.addr_out(IFID_PC_out),
	// Inputs
	.addr_in(IF_PCnext),
	.instr_in(IF_Ins),
	.wr_en(IFID_WriteSignal),
	.clk(CLK_IN),
	.rst(GLOBALRESET),
	.flush(FLUSH)
);

															
	
	// module Control(WB_out, M_out, EX_out, Jmp_out, Branch_out, Ins_in);
	Control U6(
		// Outputs
		.WB(ID_WriteBack),
		.MEM(ID_Mem),
		.EX(ID_Exec),
		.jump(ID_Jmp),
		.branch(ID_Branch),
		// Inputs
		.instruction(IFID_Ins[31:26])
	);

	// module RegisterFile(clk, data_in, Address_R1_in, Address_R2_in, Address_WriteReg_in, RegWrite_in, R1_out, R2_out);
Registers U7(
    // Outputs
    .read_data_1(ID_Reg_1_out),
    .read_data_2(ID_Reg_2_out),
    //.read_v0(v0_wire), // Commented out as v0_wire is not an output of the module
    // Inputs
    .clk(CLK_IN), 
    .regwrite(WB_WriteBack[1]), // Assuming WB_WriteBack[1] is the regwrite signal
    .write_data(MEM_BranchMUX_out),
    .addr_1(IFID_Ins[25:21]),
    .addr_2(IFID_Ins[20:16]),
    .addr_write_reg(WB_Regd)
);


	// module Comparator(bool_out, data1_in, data2_in);
	Comparator U8(
		// Outputs
		.out(ID_Comparator_out),
		// Inputs
		.in1(ID_Reg_1_out),
		.in2(ID_Reg_2_out)
	);

	// module HazardUnit(IDEXMemRead_in, EXMEMMemRead_in, EXMEMMemToReg_in, IDEXRegt_in, EXMEMRegt_in, IFIDRegs_in, IFIDRegt_in, branch_in, ComparatorResult_in, jmp_in, IFIDWrite_out, PCWrite_out, NOP_out, FLUSH_out);
HazardUnit U9(
	// Outputs
	.IF_ID_wr_en(IFID_WriteSignal),
	.PC_wr_en(IF_PCWrite),
	.nop_flag(NOP),
	.flush_flag(FLUSH),
	// Inputs
	.ID_EX_MemRead(EX_Mem[1]),
	.EX_MEM_MemRead(MEM_Memory[1]),
	.EX_MEM_memToReg(MEM_WriteBack[0]),
	.ID_EX_rt(EX_Regt),
	.EX_MEM_rt(MEM_Regd),
	.IF_ID_rs(IFID_Ins[25:21]),
	.IF_ID_rt(IFID_Ins[20:16]),
	.br(ID_Branch),
	.comparison_in(ID_Comparator_out),
	.jump(ID_Jmp)
);


	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_8bit U10(
		// Outputs
		.out(ID_ExecMUX_out),
		// Inputs
		.in1({ID_WriteBack,ID_Mem, ID_Exec}),
		.in2(8'b0),
		.sel(NOP)
	);
	
	// module SignExtend(data_out, data_in);
	sign_extend U11(
		// Outputs
		.out(ID_SE_out),
		// Inputs
		.in(IFID_Ins[15:0])
	);

	// module Shifter(data_out, data_in);
	shift U12(
		// Outputs
		.out(ID_BS_2_out),
		// Inputs
		.in(ID_SE_out)
	);

	// module Shifter(data_out, data_in);
	shift U13(
		// Outputs
		.out(ID_Jump_2_out),
		// Inputs
		.in({6'b0,IFID_Ins[25:0]})
	);

	adder U14(
		// Outputs
		.sum(ID_BranchPred_out),
		// Inputs
		.in1(IFID_PC_out),
		.in2(ID_BS_2_out)
	);
	

	// module IDEX_Reg(WB_in,  M_in,  EX_in,  Reg1Data_in, Reg2Data_in,  Sext_in,  Regt_in, Regd_in, Regs_in, WB_out, M_out, EX_out, Reg1Data_out, Reg2Data_out, Sext_out, Regt_out, Regd_out, Regs_out, clk, reset_in);
ID_EX_reg U15(
	// Outputs
	.WB_out(EX_WriteBack),
	.M_out(EX_Mem),
	.EX_out(EX_Exec),
	.data_r1_out(EX_Reg1_out),
	.data_r2_out(EX_Reg2_out),
	.signExt_out(EX_Select),
	.rt_out(EX_Regt),
	.rd_out(EX_Regd),
	.rs_out(EX_Regs),
	// Inputs
	.clk(CLK_IN),
	.rst(GLOBALRESET),
	.WB_in(ID_ExecMUX_out[7:6]),
	.M_in(ID_ExecMUX_out[5:4]),
	.EX_in(ID_ExecMUX_out[3:0]),
	.data_r1(ID_Reg_1_out),
	.data_r2(ID_Reg_2_out),
	.signExt_in(ID_SE_out),
	.rt(IFID_Ins[20:16]),
	.rd(IFID_Ins[15:11]),
	.rs(IFID_Ins[25:21])
);

	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U16(
		// Outputs
		.dataOut(EX_MUX_OP1_out), 
		// Inputs
		.in1(EX_Reg1_out), 
		.in2(MEM_BranchMUX_out), 
		.in3(MEM_ALU),
		.sel_in(EX_ForwardingA)
	); 

	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U17(
		// Outputs
		.dataOut(EX_MUX_OP2_out), 
		// Inputs
		.in1(EX_Reg2_out), 
		.in2(MEM_BranchMUX_out), 
		.in3(MEM_ALU),
		.sel_in(EX_ForwardingB)
	);
	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U18(
		// Outputs
		.out(EX_ALUSourceMUX_out),
		// Inputs
		.in1(EX_MUX_OP2_out),
		.in2(EX_Select),
		.sel(EX_Exec[0])
	);

	// module ALUControl(ALUOp_in, Funct_in, Data_out);
	ALU_controller U19(
		// Outputs
		.ALUOp_out(EX_ALUcon),
		// Inputs
		.ALUOp_in(EX_Exec[2:1]),
		.funct_code(EX_Select[5:0])
	);

	// module ALU(data_out, ZEROFLAG_out, data1_in, data2_in, ALUOp_in);
	ALU U20(
		// Inputs
		.in1(EX_MUX_OP1_out),
		.in2(EX_ALUSourceMUX_out),
		.ALUOp_in(EX_ALUcon),
		// Outputs
		.result(EX_ALU_out),
		.zeroFlag(EX_ZEROFLAG)

	);

	// module ForwardingUnit(IDEXRegs_in, IDEXRegt_in, EXMEMRegWrite_in, EXMEMRegd_in, MEMWBRegd_in, MEMWBRegWrite_in, ForwardA_out, ForwardB_out);
forwarding_unit U21 (
	// Outputs
	.fwd_A(EX_ForwardingA),
	.fwd_B(EX_ForwardingB),
	// Inputs
	.ID_EX_rs(EX_Regs),
	.ID_EX_rt(EX_Regt),
	.EX_MEM_write(MEM_WriteBack[1]),
	.EX_MEM_rd(MEM_Regd),
	.MEM_WB_rd(WB_Regd),
	.MEM_WB_write(WB_WriteBack[1])
);


	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_5bit U22(
		// Outputs
		.out(EX_RegDst_MUX_out),
		// Inputs
		.in1(EX_Regt),
		.in2(EX_Regd),
		.sel(EX_Exec[3])
	);
	
	
	// module EXMEM_Reg(WB_out, M_out, ALUData_out, WriteData_out, Regd_out, WB_in, M_in, ALUData_in, WriteData_in, Regd_in, clk, reset_in);
	ExMemReg U23(
		// Outputs
		.WBOut(MEM_WriteBack),
		.MemOut(MEM_Memory), 
		.ALUOut(MEM_ALU), 
		.WriteOut(MEM_WriteData), 
		.RegdOut(MEM_Regd),
		// Inputs
		.WBIn(EX_WriteBack), 
		.MemIn(EX_Mem), 
		.ALUIn(EX_ALU_out), 
		.WriteIn(EX_MUX_OP2_out), 
		.RegdIn(EX_RegDst_MUX_out), 
		.reset(GLOBALRESET),
		.clk(CLK_IN)
	);
		

	

	// module DataMemory #(FILE = "") (data_out, data_in, address_in, write_in, clk);
	data_mem #(DATAMEMFILE) U24(
		// Outputs
		.data_out(MEM_DataMemory_out),
		// Inputs
		.data_in(MEM_WriteData),
		.addr_in(MEM_ALU),
		.wr_en(MEM_Memory[0]),
		.clk(CLK_IN)
	);
	

	// module MEMWB_Reg(WB_out, Add_out, DataMem_out, Regd_out, WB_in, Add_in, DataMem_in, Regd_in, clk, reset_in);
	MEM_WB_reg U25(
		// Outputs
		.WB_out(WB_WriteBack), 
		.sum_out(WB_ALU), 
		.mem_data_out(WB_DataMemory), 
		.rd_out(WB_Regd), 
		// Inputs
		.WB_in(MEM_WriteBack), 
		.sum_in(MEM_ALU), 
		.mem_data_in(MEM_DataMemory_out),
		.rd(MEM_Regd), 
		.clk(CLK_IN), 
		.rst(GLOBALRESET)
	);

	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	mux_2to1_32bit U26(
		.out(MEM_BranchMUX_out),
		.in1(WB_ALU),
		.in2(WB_DataMemory),
		.sel(WB_WriteBack[0])
	);



endmodule