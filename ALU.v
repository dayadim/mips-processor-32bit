module ALU(data_out, ZEROFLAG_out, data1_in, data2_in, ALUOp_in);

  output reg [31:0] data_out;
  output reg ZEROFLAG_out;
  input [31:0] data1_in, data2_in;
  input [3:0] ALUOp_in;

  // Internal registers for use with the MFHI and MFLO instructions
  reg [31:0] HI_internal, LO_internal;

  always@(*) begin
    case(ALUOp_in)
      0: data_out <= data1_in & data2_in;
      1: data_out <= data1_in | data2_in;
      2: data_out <= data1_in + data2_in;
      3: data_out <= HI_internal;
      4: data_out <= LO_internal;
      5: begin
        {HI_internal, LO_internal} = data1_in * data2_in;
        data_out <= LO_internal;
      end
      6: data_out <= data1_in - data2_in;
      7: begin 
          if(data1_in < data2_in)
            data_out <= 32'b1;
        end
      8: begin
        LO_internal = data1_in / data2_in;
        HI_internal = data1_in % data2_in;
        data_out <= LO_internal;
      end
      12: data_out <= ~(data1_in | data2_in);
      default: data_out <= 32'b0;
    endcase

    if(data_out == 0)
      ZEROFLAG_out <= 1'b1;
    else
      ZEROFLAG_out <= 1'b0;

  end


endmodule
