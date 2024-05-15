module ALUControl(ALUOp_in, Funct_in, Data_out);

input [1:0] ALUOp_in;
input [5:0] Funct_in;
output reg [3:0] Data_out;

always@(*) begin
  case(ALUOp_in)
    0: Data_out <= 4'h2; // ADD
    1: Data_out <= 4'h6; // SUB
    2: begin
         case(Funct_in)
            6'h20: Data_out <= 4'h2;  // ADD
            6'h22: Data_out <= 4'h6;  // SUB
            6'h24: Data_out <= 4'h0;  // AND
            6'h25: Data_out <= 4'h1;  // OR
            6'h2a: Data_out <= 4'h7;  // SLT
            6'h27: Data_out <= 4'hC;  // NOR
            6'h10: Data_out <= 4'h3;  // MFHI
            6'h12: Data_out <= 4'h4;  // MFLO
            6'h18: Data_out <= 4'h5;  // MULT
            6'h1a: Data_out <= 4'h8;  // DIV

            default: Data_out <= Data_out;
         endcase
       end
    default: Data_out <= Data_out;
  endcase
end

endmodule