`include "parameters.svh"

module ImmediateSignExtender (
    input  logic [ADDR_WIDTH - 1:0] instruction,
    output logic [DATA_WIDTH - 1:0] immediate
);

    wire [6:0] opcode = instruction[6:0];

    always_comb begin
        case (opcode)
            I_TYPE, I_TYPE_LOAD, I_TYPE_JALR: // I-type
            immediate = {{21{instruction[31]}}, instruction[30:20]};
                
            I_TYPE_SYS: // I-type ECALL and EBREAK
                immediate = {DATA_WIDTH{1'b0}};
                
            S_TYPE: // S-type
                immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
                
            B_TYPE: // B-type
				immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                          
	        U_TYPE_AUIPC, U_TYPE_LUI: // U-type
                immediate = {instruction[31:12], 12'b0};
                
            J_TYPE: // J-type JAL
				immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                
            default: 
                immediate = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
