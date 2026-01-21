`include "parameters.vh"

module InstructionMemory (
    input  logic                    clk,
    input  logic                    rst,
    input  logic [ADDR_WIDTH - 1:0] pc,
    output logic [ADDR_WIDTH - 1:0] instruction
);

    logic [ADDR_WIDTH - 1:0] InstructionMemory [0 : MEMORY_SIZE - 1];

    initial begin
        $readmemh("program.hex", InstructionMemory);
    end

    always_ff @(posedge clk) begin
        if (rst)
            instruction <= 32'd0;
        else
            instruction <= InstructionMemory[pc[ADDR_WIDTH - 1:2]];
    end

endmodule
