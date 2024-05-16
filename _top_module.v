`timescale 1ns/1ps
module top_module (clock, reset);
	input clock, reset;
	localparam instructionFile = "Program.txt";
	localparam dataFile = "Memory.txt";

	//IF stage
	wire [31:0] IF_addr_out, IF_addr_in, IF_addrPlus4, IF_instr, IF_b_mux_out, IF_jump_mux_out;
	wire IF_addr_wr;

	//ID
	wire [31:0] IF_ID_instr_in, IF_ID_addr_out;
	wire IF_ID_wr_en;

	//ID
	wire [31:0] ID_signExt_out, ID_br_shifted__out, ID_jump_shifted_out, ID_br_out, ID_r1_out, ID_r2_out;
	wire [1:0] ID_WB, ID_Mem;
	wire [3:0] ID_Exec;
	wire [7:0] ID_Exec_Mux_out;
	wire ID_flush_signal, ID_jump, ID_br, ID_cmp_out, ID_nop_signal;

	//EX
	wire [31:0] EX_r1_out, EX_r2_out, EX_sel, EX_mux_fwdA, EX_mux_fwdB, EX_ALUSrc_mux_out, EX_ALU_out;
	wire [1:0] EX_WB, EX_Mem;
	wire [3:0] EX_Exec, EX_ALU_control;
	wire [4:0] EX_rt, EX_rd, EX_rs, EX_rd_mux_out;
	wire [1:0] EX_fwdA, EX_fwdB;
	wire EX_zero;

	//MEM
	wire [31:0] MEM_ALU, MEM_wrData, MEM_data_out, MEM_br_mux_out;
	wire [1:0] MEM_WB, MEM_mem;
	wire [4:0] MEM_rd;

	//WB
	wire [31:0] WB_ALU, WB_dataMem;
	wire [1:0] WB_WB;
	wire [4:0] WB_rd;

//begin rest of tb
	mux_2to1_32bit U0_IF_branchMux(
		//out
		.out(IF_b_mux_out),
		//in
		.in1(IF_addrPlus4), 
		.in2(ID_br_out), 
		.sel(ID_br)
	); 

	mux_2to1_32bit U1_IF_jumpMux(
		//out
		.out(IF_jump_mux_out),
		//in
		.in1(IF_b_mux_out),
		.in2({IF_addrPlus4[31:28], ID_jump_shifted_out[27:0]}),
		.sel(ID_jump)
	);

	PC U2_IF_PC(
		//out
		.addr_out(IF_addr_out), 
		//in
		.addr_in(IF_jump_mux_out), 
		.clk(clock),
		.rst(reset), 
		.write_en(IF_addr_wr)
	);

	adder U3_IF_adder(
		//out
		.sum(IF_addrPlus4), 
		//in
		.in1(IF_addr_out), 
		.in2(32'h4)
	);

	instr_mem #(instructionFile) U4_IF_instrMem(
		//out
		.instr_data(IF_instr), 
		//in
		.addr_in(IF_addr_out)
	);

//------------------------------------ID stage
IF_ID_reg U5_IFIDREG(
	//out
	.instr_out(IF_ID_instr_in),
	.addr_out(IF_ID_addr_out),
	//in
	.addr_in(IF_addrPlus4),
	.instr_in(IF_instr),
	.wr_en(IF_ID_wr_en),
	.clk(clock),
	.rst(reset),
	.flush(ID_flush_signal)
);


	Control U6_ID_control(
		//out
		.WB(ID_WB),
		.MEM(ID_Mem),
		.EX(ID_Exec),
		.jump(ID_jump),
		.branch(ID_br),
		//in
		.instruction(IF_ID_instr_in[31:26])
	);

Registers U7_ID_regfile(
    //out
    .read_data_1(ID_r1_out),
    .read_data_2(ID_r2_out),
    //in
    .clk(clock), 
    .regwrite(WB_WB[1]), // assuming WB_WB[1] is the regwrite signal
    .write_data(MEM_br_mux_out),
    .addr_1(IF_ID_instr_in[25:21]),
    .addr_2(IF_ID_instr_in[20:16]),
    .addr_write_reg(WB_rd)
);

	Comparator U8_ID_comp(
		//out
		.out(ID_cmp_out),
		//in
		.in1(ID_r1_out),
		.in2(ID_r2_out)
	);

HazardUnit U9_ID_hzdUnit(
	//out
	.IF_ID_wr_en(IF_ID_wr_en),
	.PC_wr_en(IF_addr_wr),
	.nop_flag(ID_nop_signal),
	.flush_flag(ID_flush_signal),
	//in
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


	mux_2to1_8bit U10_ID_nopMux(
		//out
		.out(ID_Exec_Mux_out),
		//in
		.in1({ID_WB,ID_Mem, ID_Exec}),
		.in2(8'b0),
		.sel(ID_nop_signal)
	);
	
	sign_extend U11_ID_signExt(
		//out
		.out(ID_signExt_out),
		//in
		.in(IF_ID_instr_in[15:0])
	);

	shift U12_ID_brShifter(
		//out
		.out(ID_br_shifted__out),
		//in
		.in(ID_signExt_out)
	);

	shift U13_ID_jumpShifter(
		//out
		.out(ID_jump_shifted_out),
		//in
		.in({6'b0,IF_ID_instr_in[25:0]})
	);

	adder U14_brAddedShifter(
		//out
		.sum(ID_br_out),
		//in
		.in1(IF_ID_addr_out),
		.in2(ID_br_shifted__out)
	);

//----------------------------EX
ID_EX_reg U15_IDEXREG(
	//out
	.WB_out(EX_WB),
	.M_out(EX_Mem),
	.EX_out(EX_Exec),
	.data_r1_out(EX_r1_out),
	.data_r2_out(EX_r2_out),
	.signExt_out(EX_sel),
	.rt_out(EX_rt),
	.rd_out(EX_rd),
	.rs_out(EX_rs),
	//in
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

	MUX3to1 U16_EX_muxFwdA(
		//out
		.dataOut(EX_mux_fwdA), 
		//in
		.in1(EX_r1_out), 
		.in2(MEM_br_mux_out), 
		.in3(MEM_ALU),
		.sel_in(EX_fwdA)
	); 

	MUX3to1 U17_EX_muxFWDB(
		//out
		.dataOut(EX_mux_fwdB), 
		//in
		.in1(EX_r2_out), 
		.in2(MEM_br_mux_out), 
		.in3(MEM_ALU),
		.sel_in(EX_fwdB)
	);

	mux_2to1_32bit U18_EX_muxALUSrc(
		//out
		.out(EX_ALUSrc_mux_out),
		//in
		.in1(EX_mux_fwdB),
		.in2(EX_sel),
		.sel(EX_Exec[0])
	);

	ALU_controller U19_EX_ALUControl(
		//out
		.ALUOp_out(EX_ALU_control),
		//in
		.ALUOp_in(EX_Exec[2:1]),
		.funct_code(EX_sel[5:0])
	);

	ALU U20_EX_ALU(
		//in
		.in1(EX_mux_fwdA),
		.in2(EX_ALUSrc_mux_out),
		.ALUOp_in(EX_ALU_control),
		//out
		.result(EX_ALU_out),
		.zeroFlag(EX_zero)

	);


forwarding_unit U21_EX_fwdUnit(
	//out
	.fwd_A(EX_fwdA),
	.fwd_B(EX_fwdB),
	//in
	.ID_EX_rs(EX_rs),
	.ID_EX_rt(EX_rt),
	.EX_MEM_write(MEM_WB[1]),
	.EX_MEM_rd(MEM_rd),
	.MEM_WB_rd(WB_rd),
	.MEM_WB_write(WB_WB[1])
);

	mux_2to1_5bit U22_EX_muxRegsTrans(
		//out
		.out(EX_rd_mux_out),
		//in
		.in1(EX_rt),
		.in2(EX_rd),
		.sel(EX_Exec[3])
	);

//-----------------------------MEM

	ExMemReg U23_EXMEMREG(
		//out
		.WBOut(MEM_WB),
		.MemOut(MEM_mem), 
		.ALUOut(MEM_ALU), 
		.WriteOut(MEM_wrData), 
		.RegdOut(MEM_rd),
		//in
		.WBIn(EX_WB), 
		.MemIn(EX_Mem), 
		.ALUIn(EX_ALU_out), 
		.WriteIn(EX_mux_fwdB), 
		.RegdIn(EX_rd_mux_out), 
		.reset(reset),
		.clk(clock)
	);
		
	data_mem #(dataFile) U24_MEM_dataMem(
		//out
		.data_out(MEM_data_out),
		//in
		.data_in(MEM_wrData),
		.addr_in(MEM_ALU),
		.wr_en(MEM_mem[0]),
		.clk(clock)
	);

//-------------------------------WB
	MEM_WB_reg U25_MEMWBREG(
		//out
		.WB_out(WB_WB), 
		.sum_out(WB_ALU), 
		.mem_data_out(WB_dataMem), 
		.rd_out(WB_rd), 
		//in
		.WB_in(MEM_WB), 
		.sum_in(MEM_ALU), 
		.mem_data_in(MEM_data_out),
		.rd(MEM_rd), 
		.clk(clock), 
		.rst(reset)
	);

	mux_2to1_32bit U26_WB_lastMux(
		.out(MEM_br_mux_out),
		.in1(WB_ALU),
		.in2(WB_dataMem),
		.sel(WB_WB[0])
	);

endmodule