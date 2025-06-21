module ALU (
    input  logic [31:0] op1,
    input  logic [31:0] op2,
    input  logic [4:0]   alu_control,
    input  logic [31:0] pc,
    
    output logic [31:0] alu_result,
    
    output logic            branch_taken,
    output logic            jal_jump,
    output logic            jalr_jump,
    
    output logic [31:0] branch_target,
    output logic [31:0] jal_target,
    output logic [31:0] jalr_target
);

    always_comb begin
        alu_result = 32'b0;
        branch_taken = 1'b0;
        jal_jump = 1'b0;
        jalr_jump = 1'b0;

        case (alu_control)
            5'b00000: alu_result = op1 + op2;                                                                     // ADD, ADDI and LOAD/STORE
            5'b00001: alu_result = op1 - op2;                                                                      // SUB

            5'b00010: alu_result = op1 ^ op2;                                                                     // XOR, XORI
            5'b00011: alu_result = op1 | op2;                                                                     // OR, ORI
            5'b00100: alu_result = op1 & op2;                                                                    // AND, ANDI

            5'b00101: alu_result = op1 << op2[4:0];                                                          // SLL, SLLI
            5'b00110: alu_result = op1 >> op2[4:0];                                                          // SRL, SRLI
            5'b00111: alu_result = $signed(op1) >>> op2[4:0];                                       // SRA, SRAI

            5'b01000: alu_result = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;     // SLT, SLTI
            5'b01001: alu_result = (op1 < op2) ? 32'd1 : 32'd0;                                      // SLTU, SLTIU

            5'b01010: branch_taken = (op1 == op2);                                                       // BEQ
            5'b01011: branch_taken = (op1 != op2);                                                        // BNE
            5'b01100: branch_taken = ($signed(op1) < $signed(op2));                       // BLT
            5'b01101: branch_taken = ($signed(op1) >= $signed(op2));                     // BGE
            5'b01110: branch_taken = (op1 < op2);                                                        // BLTU
            5'b01111: branch_taken = (op1 >= op2);                                                     // BGEU

            5'b10000: alu_result = op2 << 12;                                                                 // LUI
            5'b10001: alu_result = pc + (op2 << 12);                                                      // AUIPC

            5'b10010: begin                                                                                               // JAL return address
                alu_result = pc + 4;
                jal_jump = 1'b1;
            end
            
            5'b10011: begin                                                                                              // JALR return address  
                alu_result = pc + 4;
                jalr_jump = 1'b1;
            end

            default: begin
                alu_result   = 32'b0;
                branch_taken = 1'b0;
                jal_jump     = 1'b0;
                jalr_jump    = 1'b0;
            end
        endcase
    end
    
    assign branch_target = pc + op2;                 //Branch condition
    
    assign jal_target  = pc + op2;                        // JAL
    assign jalr_target = (op1 + op2) & ~32'h1; // JALR

endmodule
