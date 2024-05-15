module mux_2to1_5bit (in1, in2, sel, out);

input [4:0] in1, in2;
input sel;

output reg [4:0] out;

always @ (*) begin
	out <= sel ? in2 : in1;
end

endmodule