module InstructionMemory (
    input  logic             clk,
    input  logic             rst,
    input  logic [31:0]  pc,
    output logic [31:0] instruction
);
    localparam MemoryDepth = 1024;
    logic [31:0] InstructionMemory [0 : MemoryDepth - 1];
    
    initial begin
        $readmemh("program.hex", InstructionMemory);
    end

    always_comb begin
        if(pc[31:2] < MemoryDepth)
            instruction = InstructionMemory[pc[31:2]]; 
        else
            instruction = 32'b0;
    end
    
endmodule