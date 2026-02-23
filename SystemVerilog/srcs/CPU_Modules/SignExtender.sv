`include "parameters.vh"

module ImmediateSignExtender (
    input  logic [ADDR_WIDTH - 1:0] instruction,
    output logic [DATA_WIDTH - 1:0] immediate
);

    wire [6:0] opcode = instruction[6:0];

    always_comb begin
        case (opcode)
            7'b0010011: // I-type Arithmetic
                immediate = {{21{instruction[31]}}, instruction[30:20]};
                
            7'b0000011: // I-type Load
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                
            7'b1100111: // I-type JALR
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                
            7'b1110011: // I-type ECALL and EBREAK
                immediate = 'b0; // Not required
                
            7'b0100011: // S-type
                immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
                
            7'b1100011: // B-type
                immediate = {{20{instruction[31]}}, instruction[7], 
                          instruction[30:25], instruction[11:8], 1'b0};
                
            7'b0110111: // U-type LUI
                immediate = {instruction[31:12], 12'b0};
                
            7'b0010111: // U-type AUIPC
                immediate = {instruction[31:12], 12'b0};
                
            7'b1101111: // J-type JAL
                immediate = {{12{instruction[31]}}, instruction[19:12], 
                          instruction[20], instruction[30:21], 1'b0};
                
            default: 
                immediate = 32'b0;
        endcase
    end

endmodule
