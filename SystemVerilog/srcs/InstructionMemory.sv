module InstructionMemory (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] pc,
    output logic [31:0] instruction
);

    localparam MemoryDepth = 1024;
    logic [31:0] InstructionMemory [0 : MemoryDepth - 1];

    initial begin
        $readmemh("program.hex", InstructionMemory);
    end

    always_ff @(posedge clk) begin
        if (rst)
            instruction <= 32'd0;
        else
            instruction <= InstructionMemory[pc[31:2]];
    end

endmodule
