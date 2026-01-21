// parameters.vh
`ifndef PARAMETERS_VH
`define PARAMETERS_VH

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;

parameter MEMORY_SIZE = 1024;

parameter REGISTER_FILE_SIZE = 32;

// ALU Operations
// R-type and I-type
parameter ALU_ADD   = 5'b00000;
parameter ALU_SUB   = 5'b00001;
parameter ALU_XOR   = 5'b00010;
parameter ALU_OR    = 5'b00011;
parameter ALU_AND   = 5'b00100;
parameter ALU_SLL   = 5'b00101;
parameter ALU_SRL   = 5'b00110;
parameter ALU_SRA   = 5'b00111;
parameter ALU_SLT   = 5'b01000;
parameter ALU_SLTU  = 5'b01001;

// B-type
parameter ALU_BEQ   = 5'b01010;
parameter ALU_BNE   = 5'b01011;
parameter ALU_BLT   = 5'b01100;
parameter ALU_BGE   = 5'b01101;
parameter ALU_BLTU  = 5'b01110;
parameter ALU_BGEU  = 5'b01111;

// U-type
parameter ALU_AUIPC = 5'b10000;
parameter ALU_LUI   = 5'b10001;

// JAL and JALR
parameter ALU_JAL   = 5'b10010;
parameter ALU_JALR  = 5'b10011;

// Default
parameter ALU_DEF   = 5'b11111;

`endif

