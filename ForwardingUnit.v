module ForwardingUnit(IDEXRegs_in, IDEXRegt_in, EXMEMRegWrite_in, EXMEMRegd_in, MEMWBRegd_in, MEMWBRegWrite_in, ForwardA_out, ForwardB_out);

  input [4:0] EXMEMRegd_in, MEMWBRegd_in, IDEXRegs_in, IDEXRegt_in;
  input EXMEMRegWrite_in;    
  input MEMWBRegWrite_in;    
  output reg [1:0] ForwardA_out;  
  output reg [1:0] ForwardB_out;  

  always @(*) begin
    case({EXMEMRegWrite_in,MEMWBRegWrite_in})
      2'b00: begin // No Hazard
        ForwardA_out <= 2'b00;
        ForwardB_out <= 2'b00;
      end
      2'b01: begin // MEMWB Hazard
        if(MEMWBRegd_in != 0 && MEMWBRegd_in == IDEXRegs_in)
          ForwardA_out <= 2'b01;
        else
          ForwardA_out <= 0;
        if(MEMWBRegd_in != 0 && MEMWBRegd_in == IDEXRegt_in)
          ForwardB_out <= 2'b01;
        else
          ForwardB_out <= 0;
      end
      2'b10: begin // EXMEM Hazard
        if(EXMEMRegd_in != 0 && EXMEMRegd_in == IDEXRegs_in)
          ForwardA_out <= 2'b10;
        else
          ForwardA_out <= 0;
        if(EXMEMRegd_in != 0 && EXMEMRegd_in == IDEXRegt_in)
          ForwardB_out <= 2'b10;
        else
          ForwardB_out <= 0;
      end
      2'b11: begin // Double Data Hazard
        if(EXMEMRegd_in != 0 && EXMEMRegd_in == IDEXRegs_in) 
          ForwardA_out <= 2'b10;
        else if(MEMWBRegd_in != 0 && MEMWBRegd_in == IDEXRegs_in )
          ForwardA_out <= 2'b01;
        else
          ForwardA_out <= 0;
        if(EXMEMRegd_in != 0 && EXMEMRegd_in == IDEXRegt_in) 
          ForwardB_out <= 2'b10;
        else if(MEMWBRegd_in != 0 && MEMWBRegd_in == IDEXRegt_in)
          ForwardB_out <= 2'b01;
        else
          ForwardB_out <= 0;
      end
      default: begin
        ForwardA_out <= 1'b0;
        ForwardB_out <= 1'b0;
      end // end default
    endcase // endcase statement
  end // end always    
endmodule
