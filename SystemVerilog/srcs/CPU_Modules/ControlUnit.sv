import cpu_pkg::*;

module ControlUnit (
    input  opcode_t    opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic       MemRead,
    output logic       MemtoReg,
    output logic       MemWrite,
    output logic       RegWrite,

    output alu_op_t    ALU_Op
);

    always_comb begin
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        MemWrite = 1'b0;
        RegWrite = 1'b0;
        ALU_Op   = ALU_DEF;

        case (opcode)
            // R-type
            R_TYPE: begin
                RegWrite = 1'b1;
                case ({funct7, funct3})
                    10'b0000000_000: ALU_Op = ALU_ADD;
                    10'b0100000_000: ALU_Op = ALU_SUB;
                    10'b0000000_100: ALU_Op = ALU_XOR;
                    10'b0000000_110: ALU_Op = ALU_OR;
                    10'b0000000_111: ALU_Op = ALU_AND;
                    10'b0000000_001: ALU_Op = ALU_SLL;
                    10'b0000000_101: ALU_Op = ALU_SRL;
                    10'b0100000_101: ALU_Op = ALU_SRA;
                    10'b0000000_010: ALU_Op = ALU_SLT;
                    10'b0000000_011: ALU_Op = ALU_SLTU;
                    default        : ALU_Op = ALU_DEF;
                endcase
            end

            // I-type (Immediate)
            I_TYPE: begin
                RegWrite = 1'b1;
                case (funct3)
                    3'b000:  ALU_Op = ALU_ADDI;
                    3'b100:  ALU_Op = ALU_XORI;
                    3'b110:  ALU_Op = ALU_ORI;
                    3'b111:  ALU_Op = ALU_ANDI;
                    3'b001:  ALU_Op = ALU_SLLI;
                    3'b101:  ALU_Op = (funct7 == 7'b0) ? ALU_SRLI : ALU_SRAI;
                    3'b010:  ALU_Op = ALU_SLTI;
                    3'b011:  ALU_Op = ALU_SLTIU;
                    default: ALU_Op = ALU_DEF;
                endcase
            end

            // Load (I-type)
            I_TYPE_LOAD: begin
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALU_Op   = ALU_ADDI;
            end

            // Store (S-type)
            S_TYPE: begin
                MemWrite = 1'b1;
                ALU_Op   = ALU_ADDI;
            end

            // Branch (B-type)
            B_TYPE: begin
                case (funct3)
                    3'b000:  ALU_Op = ALU_BEQ;
                    3'b001:  ALU_Op = ALU_BNE;
                    3'b100:  ALU_Op = ALU_BLT;
                    3'b101:  ALU_Op = ALU_BGE;
                    3'b110:  ALU_Op = ALU_BLTU;
                    3'b111:  ALU_Op = ALU_BGEU;
                    default: ALU_Op = ALU_DEF;
                endcase
            end

            // JAL (J-type)
            J_TYPE: begin
                RegWrite = 1'b1;
                ALU_Op   = ALU_JAL;
            end

            // JALR (I-type)
            I_TYPE_JALR: begin
                RegWrite = 1'b1;
                ALU_Op   = ALU_JALR;
            end

            // AUIPC (U-type)
            U_TYPE_AUIPC: begin
                RegWrite = 1'b1;
                ALU_Op   = ALU_AUIPC;
            end

            // LUI (U-type)
            U_TYPE_LUI: begin
                RegWrite = 1'b1;
                ALU_Op   = ALU_LUI;
            end

            default: ALU_Op = ALU_DEF;
        endcase
    end

endmodule
