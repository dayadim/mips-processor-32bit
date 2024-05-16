/*
OUTPUTS:
	instruction/data output

liam reads from a file, using $readmemh. very smart.
https://github.com/liamgoss/MIPS-32-Bit-Processor/blob/main/InstructionMem.v

https://ovisign.com/verilog-verification/verilog-write-read-file-operations/
"If you want to read data from a file in Verilog, you can use the system tasks $readmemb or $readmemh"

*/

module instr_mem #(parameter FILE = "") (addr_in, instr_data);

	input [31:0] addr_in;

	output reg [31:0] instr_data;

	reg [31:0] internalMem [0:255];		//memory as registers

	initial begin							//when init, read filecontents as memory
		$readmemh(FILE, internalMem);		//	directly addes it into the internal mem
	end

	//assign instr_data = internalMem[addr_in];

	always @ (*) begin
		instr_data <= internalMem[addr_in];
	end

endmodule