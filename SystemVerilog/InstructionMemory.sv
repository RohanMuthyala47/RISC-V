module Instr_Mem( 
    input logic clk, 
    input logic rst, 
    input logic [31:0] pc, 
    output logic [31:0] instruction 
); 
    parameter Memory_Depth = 1024; 
    
    // Memory array declaration
    (* ram_style = "block" *)
    logic [31:0] instruction_memory[0:Memory_Depth - 1]; 
    
    // Calculate word address by ignoring last 2 bits 
    logic [$clog2(Memory_Depth) - 1:0] word_addr; 
    assign word_addr = pc[$clog2(Memory_Depth) + 1:2]; 

    initial begin 
        $readmemh("program.hex", instruction_memory); 
    end 
    
    always_ff @(posedge clk) begin 
        if (rst) begin
            instruction <= 32'h00000013; // NOP instruction (addi x0, x0, 0)
        end else if (word_addr < Memory_Depth) begin
            instruction <= instruction_memory[word_addr]; 
        end else begin
            instruction <= 32'h00000013;
        end
    end 
endmodule