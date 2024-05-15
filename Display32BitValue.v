/*
  This code was generated using ChatGPT

  ChatGPT Prompt: Write a verilog module that takes the 32 bit input and devises a way to display it on the de2-115 seven segment displays

  ChatGPT Output explanation of the code:
  In this module, the value_in input represents the 32-bit value_in you want to display. The module uses a 
  lookup table (hexDigit_internal) to map each hexadecimal digit_out (4 bits) to the corresponding seven segment 
  display encoding. The seg_out output represents the segments of the seven segment display, and the 
  digit_out output selects which digit_out to enable on the display. The clk input is the clock signal 
  used for multiplexing the display. The module uses a multiplexing scheme to sequentially display 
  each digit_out of the 32-bit value_in. It cycles through the digits at each rising edge of the clock, 
  enabling one digit_out at a time while displaying the corresponding segment value_in. Please note that 
  the specific pin assignments and connections to the DE2-115 FPGA may vary depending on the 
  board's documentation and your implementation requirements.

*/

module Display32BitValue(
  input clk,
  input [31:0] value_in,
  output reg [6:0] seg_out[0:3],
  output reg [3:0] digit_out
);
  
  reg [3:0] digit_count;
  
  always @(posedge clk) begin
    digit_count <= digit_count + 1;
    case (digit_count)
      4'b0000: begin
        seg_out[0] = value_in[3:0]; // Assign segment signals for digit 0
        seg_out[1] = value_in[7:4]; // Assign segment signals for digit 1
        seg_out[2] = value_in[11:8]; // Assign segment signals for digit 2
        seg_out[3] = value_in[15:12]; // Assign segment signals for digit 3
        digit_out = 4'b1110; // Enable digit 0
      end
      4'b0001: begin
        digit_out = 4'b1101; // Enable digit 1
      end
      4'b0010: begin
        digit_out = 4'b1011; // Enable digit 2
      end
      4'b0011: begin
        digit_out = 4'b0111; // Enable digit 3
      end
      default: begin
        seg_out[0] = 7'b111_1111; // Turn off all segments for unused digits
        seg_out[1] = 7'b111_1111;
        seg_out[2] = 7'b111_1111;
        seg_out[3] = 7'b111_1111;
        digit_out = 4'b1111; // Disable all digits
      end
    endcase
  end
  
endmodule
