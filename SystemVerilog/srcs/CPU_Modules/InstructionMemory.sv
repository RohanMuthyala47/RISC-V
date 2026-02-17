`include "parameters.vh"

module InstructionMemory (
    input  logic                    rst,
    input  logic [ADDR_WIDTH - 1:0] pc,
    output logic [31:0]             instruction
);

    logic [31:0] InstructionMemory [0 : MEMORY_SIZE - 1];

    initial begin
        $readmemh("program.hex", InstructionMemory);
    end

    always_comb begin
        /* verilator lint_off WIDTHTRUNC */
	    instruction = InstructionMemory[pc[ADDR_WIDTH - 1:2]];
	    /* verilator lint_on WIDTHTRUNC */
    end

endmodule
