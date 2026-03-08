import cpu_pkg::*;

module InstructionMemory (
    input  logic [ADDR_WIDTH - 1:0]  pc,
    
    output logic [INSTR_WIDTH - 1:0] instruction
);

    /* verilator lint_off WIDTHTRUNC */

    // Instruction Memory declaration
    logic [INSTR_WIDTH - 1:0] InstructionMemory [0 : MEM_DEPTH - 1];

    initial begin
        $readmemh("program.hex", InstructionMemory);
    end

    always_comb begin
        instruction = InstructionMemory[pc[ADDR_WIDTH - 1:2]];
    end

endmodule
