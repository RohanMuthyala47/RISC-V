`include "parameters.vh"

module ALU (
    input  logic [DATA_WIDTH - 1:0] op1,
    input  logic [DATA_WIDTH - 1:0] op2,
    input  logic [4:0]              ALU_Op,
    
    input  logic [ADDR_WIDTH - 1:0] pc,

    output logic [DATA_WIDTH - 1:0] alu_result,
    
    output logic                    branch_taken,
    output logic                    jal_jump,
    output logic                    jalr_jump,

    output logic [ADDR_WIDTH - 1:0] branch_target,
    output logic [ADDR_WIDTH - 1:0] jal_target,
    output logic [ADDR_WIDTH - 1:0] jalr_target
);

    always_comb begin
        alu_result   =  32'b0;
        branch_taken = 1'b0;
        jal_jump     = 1'b0;
        jalr_jump    = 1'b0;

        case (ALU_Op)
            ALU_ADD  :  alu_result   = op1 + op2;
            ALU_SUB  :  alu_result   = op1 - op2;

            ALU_XOR  :  alu_result   = op1 ^ op2;
            ALU_OR   :  alu_result   = op1 | op2;
            ALU_AND  :  alu_result   = op1 & op2;

            ALU_SLL  :  alu_result   = op1 << op2[4:0];
            ALU_SRL  :  alu_result   = op1 >> op2[4:0];
            ALU_SRA  :  alu_result   = $signed(op1) >>> op2[4:0];

            ALU_SLT  :  alu_result   = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
            ALU_SLTU :  alu_result   = (op1 < op2) ? 32'd1 : 32'd0;

            ALU_BEQ  :  branch_taken = (op1 == op2);
            ALU_BNE  :  branch_taken = (op1 != op2);
            ALU_BLT  :  branch_taken = ($signed(op1) < $signed(op2));
            ALU_BGE  :  branch_taken = ($signed(op1) >= $signed(op2));
            ALU_BLTU :  branch_taken = (op1 < op2);
            ALU_BGEU :  branch_taken = (op1 >= op2);

            ALU_LUI  :  alu_result   = op2;
            ALU_AUIPC:  alu_result   = pc + op2;

            ALU_JAL: begin
                alu_result = pc + 4;
                jal_jump   = 1'b1;
            end

            ALU_JALR: begin
                alu_result = pc + 4;
                jalr_jump  = 1'b1;
            end
            
            ALU_DEF: begin
                alu_result   = 'b0;
                branch_taken = 1'b0;
                jal_jump     = 1'b0;
                jalr_jump    = 1'b0;
            end
            
            default: begin
                alu_result   = 'b0;
                branch_taken = 1'b0;
                jal_jump     = 1'b0;
                jalr_jump    = 1'b0;
            end
        endcase
    end

    assign branch_target = pc + op2;
    assign jal_target    = pc + op2;
    assign jalr_target   = op1 + op2;

endmodule
