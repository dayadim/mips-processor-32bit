/*
general purpose mux 32 bit
*/

module mux_2to1_32bit (in1, in2, sel, out);

input [31:0] in1, in2;
input sel;

output reg [31:0] out;

always @ (*) begin
	out <= sel ? in2 : in1;
end

endmodule