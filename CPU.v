`timescale 1ns/1ps
`include "Adder.v"
`include "ALU.v"
`include "ALUControl.v"
`include "Comparator.v"
`include "Control.v"
`include "DataMemory.v"
`include "EXMEM_Reg.v"
`include "ForwardingUnit.v"
`include "HazardUnit.v"
`include "IDEX_Reg.v"
`include "IFID_Reg.v"
`include "InstructionMem.v"
`include "MEMWB_Reg.v"
`include "MUX2to1.v"
`include "MUX3to1.v"
`include "PCReg.v"
`include "RegisterFile.v"
`include "Shifter.v"
`include "SignExtend.v"
//`include "Display32BitValue.v"

module CPU(CLK_IN, GLOBALRESET);
	localparam v0 = 2;
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

	/**********FPGA VARS***********/
	wire [31:0] v0_wire;
	wire [6:0] seg;
	wire [3:0] digit;	
	/****************************/



	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 U0(
		// Outputs
		.data_out(IF_Branch_MUX_out),
		// Inputs
		.data1_in(IF_PCnext), 
		.data2_in(ID_BranchPred_out), 
		.sel_in(ID_Branch)
	); 

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 U1(
		// Outputs
		.data_out(IF_Jmp_MUX_out),
		// Inputs
		.data1_in(IF_Branch_MUX_out),
		.data2_in({IF_PCnext[31:28], ID_Jump_2_out[27:0]}),
		.sel_in(ID_Jmp)
	);

	// module PCReg(address_out, address_in, clk, reset_in, write_in);
	PCReg U2(
		// Outputs
		.address_out(IF_PC_out), 
		// Inputs
		.address_in(IF_Jmp_MUX_out), 
		.clk(CLK_IN),
		.reset_in(GLOBALRESET), 
		.write_in(IF_PCWrite)
	);

	// module Adder(sum_out, a_in, b_in);
	Adder U3(
		// Outputs
		.sum_out(IF_PCnext), 
		// Inputs
		.a_in(IF_PC_out), 
		.b_in(32'h4)
	);

	// module InstructionMemory #(FILE = "") (data_out, address_in);
	InstructionMemory #(INSMEMFILE) U4(
		// Outputs
		.data_out(IF_Ins), 
		// Inputs
		.address_in(IF_PC_out)
	);


	// module IFID_Reg(Ins_out, PC_in, PC_out, Ins_in, write_in, clk, reset_in, flush_in);
	IFID_Reg U5 (
		// Outputs
		.Ins_out(IFID_Ins),
		.PC_out(IFID_PC_out),
		// Inputs
		.PC_in(IF_PCnext),
		.Ins_in(IF_Ins),
		.write_in(IFID_WriteSignal),
		.clk(CLK_IN),
		.reset_in(GLOBALRESET),
		.flush_in(FLUSH)
	);
															
	
	// module Control(WB_out, M_out, EX_out, Jmp_out, Branch_out, Ins_in);
	Control U6(
		// Outputs
		.WB_out(ID_WriteBack),
		.M_out(ID_Mem),
		.EX_out(ID_Exec),
		.Jmp_out(ID_Jmp),
		.Branch_out(ID_Branch),
		// Inputs
		.Ins_in(IFID_Ins[31:26])
	);

	// module RegisterFile(clk, data_in, Address_R1_in, Address_R2_in, Address_WriteReg_in, RegWrite_in, R1_out, R2_out);
	RegisterFile U7(
		// Outputs
		.R1_out(ID_Reg_1_out),
		.R2_out(ID_Reg_2_out),
		.V0_out(v0_wire),
		// Inputs
		.clk(CLK_IN), 
		.data_in(MEM_BranchMUX_out),
		.Address_R1_in(IFID_Ins[25:21]),
		.Address_R2_in(IFID_Ins[20:16]),
		.Address_WriteReg_in(WB_Regd),
		.RegWrite_in(WB_WriteBack[1])
	); 

	// module Comparator(bool_out, data1_in, data2_in);
	Comparator U8(
		// Outputs
		.bool_out(ID_Comparator_out),
		// Inputs
		.data1_in(ID_Reg_1_out),
		.data2_in(ID_Reg_2_out)
	);

	// module HazardUnit(IDEXMemRead_in, EXMEMMemRead_in, EXMEMMemToReg_in, IDEXRegt_in, EXMEMRegt_in, IFIDRegs_in, IFIDRegt_in, branch_in, ComparatorResult_in, jmp_in, IFIDWrite_out, PCWrite_out, NOP_out, FLUSH_out);
	HazardUnit U9(
		// Outputs
		.IFIDWrite_out(IFID_WriteSignal),
		.PCWrite_out(IF_PCWrite),
		.NOP_out(NOP),
		.FLUSH_out(FLUSH),
		// Inputs
		.IDEXMemRead_in(EX_Mem[1]),
		.EXMEMMemRead_in(MEM_Memory[1]),
		.EXMEMMemToReg_in(MEM_WriteBack[0]),
		.IDEXRegt_in(EX_Regt),
		.EXMEMRegt_in(MEM_Regd),
		.IFIDRegs_in(IFID_Ins[25:21]),
		.IFIDRegt_in(IFID_Ins[20:16]),
		.branch_in(ID_Branch),
		.ComparatorResult_in(ID_Comparator_out),
		.jmp_in(ID_Jmp)
	);

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 #(8) U10(
		// Outputs
		.data_out(ID_ExecMUX_out),
		// Inputs
		.data1_in({ID_WriteBack,ID_Mem, ID_Exec}),
		.data2_in(8'b0),
		.sel_in(NOP)
	);
	
	// module SignExtend(data_out, data_in);
	SignExtend U11(
		// Outputs
		.data_out(ID_SE_out),
		// Inputs
		.data_in(IFID_Ins[15:0])
	);

	// module Shifter(data_out, data_in);
	Shifter U12(
		// Outputs
		.data_out(ID_BS_2_out),
		// Inputs
		.data_in(ID_SE_out)
	);

	// module Shifter(data_out, data_in);
	Shifter U13(
		// Outputs
		.data_out(ID_Jump_2_out),
		// Inputs
		.data_in({6'b0,IFID_Ins[25:0]})
	);

	// module Adder(sum_out, a_in, b_in);
	Adder U14(
		// Outputs
		.sum_out(ID_BranchPred_out),
		// Inputs
		.a_in(IFID_PC_out),
		.b_in(ID_BS_2_out)
	);
	

	// module IDEX_Reg(WB_in,  M_in,  EX_in,  Reg1Data_in, Reg2Data_in,  Sext_in,  Regt_in, Regd_in, Regs_in, WB_out, M_out, EX_out, Reg1Data_out, Reg2Data_out, Sext_out, Regt_out, Regd_out, Regs_out, clk, reset_in);
	IDEX_Reg U15(
		// Outputs
		.WB_out(EX_WriteBack),
		.M_out(EX_Mem),
		.EX_out(EX_Exec),
		.Reg1Data_out(EX_Reg1_out),
		.Reg2Data_out(EX_Reg2_out),
		.Sext_out(EX_Select),
		.Regt_out(EX_Regt),
		.Regd_out(EX_Regd),
		.Regs_out(EX_Regs),
		// Inputs
		.clk(CLK_IN),
		.reset_in(GLOBALRESET),
		.WB_in(ID_ExecMUX_out[7:6]),
		.M_in(ID_ExecMUX_out[5:4]),
		.EX_in(ID_ExecMUX_out[3:0]),
		.Reg1Data_in(ID_Reg_1_out),
		.Reg2Data_in(ID_Reg_2_out),
		.Sext_in(ID_SE_out),
		.Regt_in(IFID_Ins[20:16]),
		.Regd_in(IFID_Ins[15:11]),
		.Regs_in(IFID_Ins[25:21])
	);

	
	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U16(
		// Outputs
		.data_out(EX_MUX_OP1_out), 
		// Inputs
		.data1_in(EX_Reg1_out), 
		.data2_in(MEM_BranchMUX_out), 
		.data3_in(MEM_ALU),
		.sel_in(EX_ForwardingA)
	); 

	// module MUX3to1(data_out, data1_in, data2_in, data3_in, sel_in);
	MUX3to1 U17(
		// Outputs
		.data_out(EX_MUX_OP2_out), 
		// Inputs
		.data1_in(EX_Reg2_out), 
		.data2_in(MEM_BranchMUX_out), 
		.data3_in(MEM_ALU),
		.sel_in(EX_ForwardingB)
	);
	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 U18(
		// Outputs
		.data_out(EX_ALUSourceMUX_out),
		// Inputs
		.data1_in(EX_MUX_OP2_out),
		.data2_in(EX_Select),
		.sel_in(EX_Exec[0])
	);

	// module ALUControl(ALUOp_in, Funct_in, Data_out);
	ALUControl U19(
		// Outputs
		.Data_out(EX_ALUcon),
		// Inputs
		.ALUOp_in(EX_Exec[2:1]),
		.Funct_in(EX_Select[5:0])
	);

	// module ALU(data_out, ZEROFLAG_out, data1_in, data2_in, ALUOp_in);
	ALU U20(
		// Outputs
		.data_out(EX_ALU_out),
		.ZEROFLAG_out(EX_ZEROFLAG),
		// Inputs
		.data1_in(EX_MUX_OP1_out),
		.data2_in(EX_ALUSourceMUX_out),
		.ALUOp_in(EX_ALUcon)
	);

	// module ForwardingUnit(IDEXRegs_in, IDEXRegt_in, EXMEMRegWrite_in, EXMEMRegd_in, MEMWBRegd_in, MEMWBRegWrite_in, ForwardA_out, ForwardB_out);
	ForwardingUnit U21 (
		// Outputs
		.ForwardA_out(EX_ForwardingA),
		.ForwardB_out(EX_ForwardingB),
		// Inputs
		.IDEXRegs_in(EX_Regs),
		.IDEXRegt_in(EX_Regt),
		.EXMEMRegWrite_in(MEM_WriteBack[1]),
		.EXMEMRegd_in(MEM_Regd),
		.MEMWBRegd_in(WB_Regd),
		.MEMWBRegWrite_in(WB_WriteBack[1])
	);

	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 #(5) U22(
		// Outputs
		.data_out(EX_RegDst_MUX_out),
		// Inputs
		.data1_in(EX_Regt),
		.data2_in(EX_Regd),
		.sel_in(EX_Exec[3])
	);
	
	
	// module EXMEM_Reg(WB_out, M_out, ALUData_out, WriteData_out, Regd_out, WB_in, M_in, ALUData_in, WriteData_in, Regd_in, clk, reset_in);
	EXMEM_Reg U23(
		// Outputs
		.WB_out(MEM_WriteBack),
		.M_out(MEM_Memory), 
		.ALUData_out(MEM_ALU), 
		.WriteData_out(MEM_WriteData), 
		.Regd_out(MEM_Regd),
		// Inputs
		.WB_in(EX_WriteBack), 
		.M_in(EX_Mem), 
		.ALUData_in(EX_ALU_out), 
		.WriteData_in(EX_MUX_OP2_out), 
		.Regd_in(EX_RegDst_MUX_out), 
		.reset_in(GLOBALRESET),
		.clk(CLK_IN)
	);
		

	

	// module DataMemory #(FILE = "") (data_out, data_in, address_in, write_in, clk);
	DataMemory #(DATAMEMFILE) U24(
		// Outputs
		.data_out(MEM_DataMemory_out),
		// Inputs
		.data_in(MEM_WriteData),
		.address_in(MEM_ALU),
		.write_in(MEM_Memory[0]),
		.clk(CLK_IN)
	);
	

	// module MEMWB_Reg(WB_out, Add_out, DataMem_out, Regd_out, WB_in, Add_in, DataMem_in, Regd_in, clk, reset_in);
	MEMWB_Reg U25(
		// Outputs
		.WB_out(WB_WriteBack), 
		.Add_out(WB_ALU), 
		.DataMem_out(WB_DataMemory), 
		.Regd_out(WB_Regd), 
		// Inputs
		.WB_in(MEM_WriteBack), 
		.Add_in(MEM_ALU), 
		.DataMem_in(MEM_DataMemory_out),
		.Regd_in(MEM_Regd), 
		.clk(CLK_IN), 
		.reset_in(GLOBALRESET)
	);

	
	// module MUX2to1(data_out, data1_in, data2_in, sel_in);
	MUX2to1 U26(
		.data_out(MEM_BranchMUX_out),
		.data1_in(WB_ALU),
		.data2_in(WB_DataMemory),
		.sel_in(WB_WriteBack[0])
	);

	/*
	// module Display32BitValue(input [31:0] value,output reg [6:0] seg[0:3],output reg [3:0] digit_select);
	Display32BitValue U27 (
		// Outputs
		.digit_out(digit),
		.seg_out(seg),
		// Inputs
		.value_in(v0_wire),
		.clk(CLK_IN)
	);
	*/
	/*
	assign HEX0[0] = seg[0][6];
	assign HEX0[1] = seg[0][5];
	assign HEX0[2] = seg[0][4];
	assign HEX0[3] = seg[0][3];
	assign HEX0[4] = seg[0][2];
	assign HEX0[5] = seg[0][1];
	assign HEX0[6] = seg[0][0];

	assign HEX1[0] = seg[1][6];
	assign HEX1[1] = seg[1][5];
	assign HEX1[2] = seg[1][4];
	assign HEX1[3] = seg[1][3];
	assign HEX1[4] = seg[1][2];
	assign HEX1[5] = seg[1][1];
	assign HEX1[6] = seg[1][0];

	assign HEX2[0] = seg[2][6];
	assign HEX2[1] = seg[2][5];
	assign HEX2[2] = seg[2][4];
	assign HEX2[3] = seg[2][3];
	assign HEX2[4] = seg[2][2];
	assign HEX2[5] = seg[2][1];
	assign HEX2[6] = seg[2][0];

	assign HEX3[0] = seg[3][6];
	assign HEX3[1] = seg[3][5];
	assign HEX3[2] = seg[3][4];
	assign HEX3[3] = seg[3][3];
	assign HEX3[4] = seg[3][2];
	assign HEX3[5] = seg[3][1];
	assign HEX3[6] = seg[3][0];
	*/


endmodule