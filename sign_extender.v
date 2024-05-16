/*
don't just sign extend with zero's

*/

module sign_extend (in, out);

input [15:0] in;
output reg [31:0] out;

always @(*) begin
	if (in[15] == 1'b1) out = {16'hFFFF, in};
	else out = {16'b0, in};
end

endmodule