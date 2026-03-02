package cpu_pkg;

typedef enum logic [6:0] {
	R_TYPE       = 7'b0110011,
	I_TYPE       = 7'b0010011,
	I_TYPE_LOAD  = 7'b0000011,
	I_TYPE_SYS   = 7'b1110011,
	S_TYPE       = 7'b0100011,
	B_TYPE       = 7'b1100011,
	U_TYPE_AUIPC = 7'b0010111,
	U_TYPE_LUI   = 7'b0110111,
	I_TYPE_JALR  = 7'b1100111,
	J_TYPE       = 7'b1101111
} opcode_t;

typedef enum logic [4:0] {
    // R-type
    ALU_ADD   = 5'b00000,
    ALU_SUB   = 5'b00001,
    ALU_XOR   = 5'b00010,
    ALU_OR    = 5'b00011,
    ALU_AND   = 5'b00100,
    ALU_SLL   = 5'b00101,
    ALU_SRL   = 5'b00110,
    ALU_SRA   = 5'b00111,
    ALU_SLT   = 5'b01000,
    ALU_SLTU  = 5'b01001,
        
    // I-type
    ALU_ADDI  = 5'b01010,
    ALU_XORI  = 5'b01011,
    ALU_ORI   = 5'b01100,
    ALU_ANDI  = 5'b01101,
    ALU_SLLI  = 5'b01110,
    ALU_SRLI  = 5'b01111,
    ALU_SRAI  = 5'b10000,
    ALU_SLTI  = 5'b10001,
    ALU_SLTIU = 5'b10010,
        
    // B-type
    ALU_BEQ   = 5'b10011,
    ALU_BNE   = 5'b10100,
    ALU_BLT   = 5'b10101,
    ALU_BGE   = 5'b10110,
    ALU_BLTU  = 5'b10111,
    ALU_BGEU  = 5'b11000,
        
    // U-type
    ALU_AUIPC = 5'b11001,
    ALU_LUI   = 5'b11010,
        
    // Jump
    ALU_JAL   = 5'b11011,
    ALU_JALR  = 5'b11100,
        
    // Default
    ALU_DEF   = 5'b11111
} alu_op_t;
    	

typedef enum logic [2:0] {
	IDLE,
	WR_REQ,
	WR_DATA,
	WR_WAIT_RESP,
	RD_REQ,
	RD_DATA
} cache_state_t;

endpackage
