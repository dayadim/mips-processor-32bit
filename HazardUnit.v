module HazardUnit(IDEXMemRead_in, EXMEMMemRead_in, EXMEMMemToReg_in, IDEXRegt_in, EXMEMRegt_in, IFIDRegs_in, IFIDRegt_in, branch_in, ComparatorResult_in, jmp_in, IFIDWrite_out, PCWrite_out, NOP_out, FLUSH_out);

  input IDEXMemRead_in, EXMEMMemRead_in, EXMEMMemToReg_in, branch_in, ComparatorResult_in, jmp_in;
  input [4:0] IDEXRegt_in, EXMEMRegt_in, IFIDRegs_in, IFIDRegt_in;
  output reg IFIDWrite_out, PCWrite_out, NOP_out, FLUSH_out;


  always@(*)begin 
  //loading hazard detection
    if(IDEXMemRead_in == 1'b1) begin
      if(IDEXRegt_in == IFIDRegs_in) begin
        NOP_out = 1'b1;
        PCWrite_out = 1'b0;
        IFIDWrite_out = 1'b0;
      end
      else if(IDEXRegt_in == IFIDRegt_in) begin
        NOP_out = 1'b1;
        PCWrite_out = 1'b0;
        IFIDWrite_out = 1'b0;
      end
    end

    else if(EXMEMMemToReg_in == 1'b1) begin
      if(EXMEMRegt_in == IFIDRegs_in) begin
        NOP_out = 1'b1;
        PCWrite_out = 1'b0;
        IFIDWrite_out = 1'b0;
      end
      else if(EXMEMRegt_in == IFIDRegt_in) begin
        NOP_out = 1'b1;
        PCWrite_out = 1'b0;
        IFIDWrite_out = 1'b0;
      end
    end

  //branch_in hazards
    else if(branch_in == 1'b1) begin
      if(IDEXMemRead_in == 1'b1) begin
        if(IDEXRegt_in == IFIDRegs_in || IDEXRegt_in == IFIDRegt_in) begin
          NOP_out = 1'b1;
          PCWrite_out = 1'b0;
          IFIDWrite_out = 1'b0;
        end
      end
      else if(EXMEMMemRead_in == 1'b1)begin //if loading to register used in branch_in 2nd instr before branch_in
        if(EXMEMRegt_in == IFIDRegs_in || EXMEMRegt_in == IFIDRegt_in)begin 
          NOP_out = 1'b1;
          PCWrite_out = 1'b0;
          IFIDWrite_out = 1'b0;
        end
      end
      else if(ComparatorResult_in == 1'b1)begin //if actually branching
        NOP_out = 1'b0;
        PCWrite_out = 1'b1;
        IFIDWrite_out = 1'b1;
        FLUSH_out = 1'b1;
      end//ComparatorResult_in
    end //branch_in
    else if(jmp_in == 1'b1) begin
      NOP_out = 1'b0;
      PCWrite_out = 1'b1;
      IFIDWrite_out = 1'b1;
      FLUSH_out = 1'b1;
    end
    else begin
      NOP_out = 1'b0;
      PCWrite_out = 1'b1;
      IFIDWrite_out = 1'b1;
      FLUSH_out = 1'b0;
    end //else
  end //always

endmodule
