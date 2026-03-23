import cpu_pkg::*;

module ALU (
    input  logic [ADDR_WIDTH - 1:0] pc,
	
    input  logic [DATA_WIDTH - 1:0] op1,
    input  logic [DATA_WIDTH - 1:0] op2,
    
    input  alu_op_t                 ALU_Op,
    
    input  logic [DATA_WIDTH - 1:0] immediate,

    output logic                    branch_taken,
    output logic [ADDR_WIDTH - 1:0] branch_target,
    
    output logic                    jal_jump,
    output logic                    jalr_jump,
    output logic [ADDR_WIDTH - 1:0] jal_target,
    output logic [ADDR_WIDTH - 1:0] jalr_target,
    
    output logic [DATA_WIDTH - 1:0] alu_result
);

    always_comb begin
		alu_result    = DATA_WIDTH'(0);
    	branch_taken  = 1'b0;
    	jal_jump      = 1'b0;
    	jalr_jump     = 1'b0;
        case (ALU_Op)
            ALU_ADD   :  alu_result   = op1 + op2;
            ALU_SUB   :  alu_result   = op1 - op2;
            ALU_XOR   :  alu_result   = op1 ^ op2;
            ALU_OR    :  alu_result   = op1 | op2;
            ALU_AND   :  alu_result   = op1 & op2;
            ALU_SLL   :  alu_result   = op1 << op2[$clog2(DATA_WIDTH)-1:0];
            ALU_SRL   :  alu_result   = op1 >> op2[$clog2(DATA_WIDTH)-1:0];
            ALU_SRA   :  alu_result   = $signed(op1) >>> op2[$clog2(DATA_WIDTH)-1:0];
			ALU_SLT   :  alu_result   = $signed(op1) < $signed(op2);
			ALU_SLTU  :  alu_result   = op1 < op2;
            
            ALU_ADDI  :  alu_result   = op1 + immediate;
            ALU_XORI  :  alu_result   = op1 ^ immediate;
            ALU_ORI   :  alu_result   = op1 | immediate;
            ALU_ANDI  :  alu_result   = op1 & immediate;
            ALU_SLLI  :  alu_result   = op1 << immediate[$clog2(DATA_WIDTH)-1:0];
            ALU_SRLI  :  alu_result   = op1 >> immediate[$clog2(DATA_WIDTH)-1:0];
            ALU_SRAI  :  alu_result   = $signed(op1) >>> immediate[$clog2(DATA_WIDTH)-1:0];
			ALU_SLTI  :  alu_result   = $signed(op1) < $signed(immediate);
			ALU_SLTIU :  alu_result   = op1 < immediate;

            ALU_BEQ   :  branch_taken = op1 == op2;
            ALU_BNE   :  branch_taken = op1 != op2;
            ALU_BLT   :  branch_taken = $signed(op1) < $signed(op2);
            ALU_BGE   :  branch_taken = $signed(op1) >= $signed(op2);
            ALU_BLTU  :  branch_taken = op1 < op2;
            ALU_BGEU  :  branch_taken = op1 >= op2;

            ALU_LUI  :  alu_result   = immediate;
            ALU_AUIPC:  alu_result   = pc + immediate;

            ALU_JAL: begin
                alu_result = pc + ADDR_WIDTH'(4);
                jal_jump   = 1'b1;
            end

            ALU_JALR: begin
                alu_result = pc + ADDR_WIDTH'(4);
                jalr_jump  = 1'b1;
            end
            
            ALU_DEF: begin
                alu_result   = DATA_WIDTH'(0);
                branch_taken = 1'b0;
                jal_jump     = 1'b0;
                jalr_jump    = 1'b0;
            end
            
            default: ;
        endcase
    end

    assign branch_target = pc + immediate;
    assign jal_target    = pc + immediate;
    assign jalr_target   = op1 + immediate;

endmodule
