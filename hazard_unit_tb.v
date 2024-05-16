module HazardUnit_tb();

reg ID_EX_MemRead, EX_MEM_MemRead, EX_MEM_memToReg, br, comparison_in, jump;
reg [4:0] ID_EX_rt, EX_MEM_rt, IF_ID_rs, IF_ID_rt;
wire IF_ID_wr_en, PC_wr_en, nop_flag, flush_flag;

HazardUnit HazardUnit_inst(
    .ID_EX_MemRead(ID_EX_MemRead), 
    .EX_MEM_MemRead(EX_MEM_MemRead), 
    .EX_MEM_memToReg(EX_MEM_memToReg),
    .ID_EX_rt(ID_EX_rt), 
    .EX_MEM_rt(EX_MEM_rt), 
    .IF_ID_rs(IF_ID_rs), 
    .IF_ID_rt(IF_ID_rt),
    .br(br), 
    .comparison_in(comparison_in), 
    .jump(jump),
    .IF_ID_wr_en(IF_ID_wr_en), 
    .PC_wr_en(PC_wr_en), 
    .nop_flag(nop_flag), 
    .flush_flag(flush_flag)
);

initial begin
    // Test 1
    $display("---------Test 1");
    ID_EX_MemRead = 1;
    ID_EX_rt = 3;
    IF_ID_rs = 3;
    IF_ID_rt = 5;
    EX_MEM_MemRead = 0;
    EX_MEM_memToReg = 0;
    br = 0;
    comparison_in = 0;
    jump = 0;

    #10;

    $display("\nInputs:---");
    $display("ID_EX_MemRead = %b", ID_EX_MemRead);
    $display("ID_EX_rt = %b", ID_EX_rt);
    $display("IF_ID_rs = %b", IF_ID_rs);
    $display("IF_ID_rt = %b", IF_ID_rt);
    $display("EX_MEM_MemRead = %b", EX_MEM_MemRead);
    $display("EX_MEM_memToReg = %b", EX_MEM_memToReg);
    $display("br = %b", br);
    $display("comparison_in = %b", comparison_in);
    $display("jump = %b", jump);

    $display("\nOutputs---");
    $display("IF_ID_wr_en = %b", IF_ID_wr_en);
    $display("PC_wr_en = %b", PC_wr_en);
    $display("nop_flag = %b", nop_flag);
    $display("flush_flag = %b", flush_flag);
    $display("\n\n");


    // Test 2

end

endmodule
