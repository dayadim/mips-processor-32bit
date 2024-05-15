module Control(WB_out, M_out, EX_out, Jmp_out, Branch_out, Ins_in);

  output [1:0] WB_out, M_out;
  output [3:0] EX_out;
  output reg Jmp_out, Branch_out;
  input [5:0] Ins_in;

  reg RegDest_internal, MemRead_internal, MemToReg_internal, MemWrite_internal, ALUSrc_internal, RegWrite_internal;
  reg [1:0] ALUOp_internal;

  always@(*) begin
    case(Ins_in)
      6'h0: begin //Rtype
        RegWrite_internal = 1'b1;
        MemToReg_internal = 1'b0;
        Branch_out = 1'b0;
        MemRead_internal = 1'b0;
        MemWrite_internal = 1'b0;
        RegDest_internal = 1'b1;
        ALUOp_internal = 2'b10;
        ALUSrc_internal = 1'b0;
        Jmp_out = 1'b0;
      end
      6'h8: begin // ADDI
        RegWrite_internal = 1'b1;
        MemToReg_internal = 1'b0;
        Branch_out = 1'b0;
        MemRead_internal = 1'b0;
        MemWrite_internal = 1'b0;
        RegDest_internal = 1'b0;
        ALUOp_internal = 2'b00;
        ALUSrc_internal = 1'b1;
        Jmp_out = 1'b0;
      end
      6'h23: begin //lw
        RegWrite_internal = 1'b1;
        MemToReg_internal = 1'b1;
        Branch_out = 1'b0;
        MemRead_internal = 1'b1;
        MemWrite_internal = 1'b0;
        RegDest_internal = 1'b0;
        ALUOp_internal = 2'b00;
        ALUSrc_internal = 1'b1;
        Jmp_out = 1'b0;
      end
      6'h2b: begin //sw
        RegWrite_internal = 1'b0;
        MemToReg_internal = 1'b0;
        Branch_out = 1'b0;
        MemRead_internal = 1'b0;
        MemWrite_internal = 1'b1;
        RegDest_internal = 1'b0;
        ALUOp_internal = 2'b00;
        ALUSrc_internal = 1'b1;
        Jmp_out = 1'b0;
      end
      6'h04: begin //beq
        RegWrite_internal = 1'b0;
        MemToReg_internal = 1'b0;
        Branch_out = 1'b1;
        MemRead_internal = 1'b0;
        MemWrite_internal = 1'b0;
        RegDest_internal = 1'b0;
        ALUOp_internal = 2'b01;
        ALUSrc_internal = 1'b0;
        Jmp_out = 1'b0;
      end
      6'h02: begin //jump may be broken... maybe
        RegWrite_internal = 1'b0;
        MemToReg_internal = 1'b0;
        Branch_out = 1'b1;
        MemRead_internal = 1'b0;
        MemWrite_internal = 1'b0;
        RegDest_internal = 1'b0;
        ALUOp_internal = 2'b01;
        ALUSrc_internal = 1'b0;
        Jmp_out = 1'b1;
      end
      default: begin
        {RegWrite_internal, MemToReg_internal, Branch_out, MemRead_internal,
        MemWrite_internal, RegDest_internal, ALUOp_internal, ALUSrc_internal, Jmp_out} = 0;
      end
    endcase
end


assign WB_out = {RegWrite_internal, MemToReg_internal};
assign M_out = {MemRead_internal, MemWrite_internal};
assign EX_out = {RegDest_internal, ALUOp_internal, ALUSrc_internal};

endmodule
