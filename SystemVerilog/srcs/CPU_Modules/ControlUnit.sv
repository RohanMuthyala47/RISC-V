`include "parameters.sv"

module ControlUnit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    
    output logic       Branch,
    output logic       MemRead,
    output logic       MemtoReg,
    output logic       MemWrite,
    output logic       ALU_Src,
    output logic       RegWrite,

    output logic [4:0] ALU_Op
);

    always_comb begin
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        MemWrite = 0;
        ALU_Src = 0;
        RegWrite = 0;
        ALU_Op = ALU_DEF;

        case (opcode)
            // R-type
            7'b0110011: begin
                RegWrite = 1;
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
                    default:         ALU_Op = ALU_DEF;
                endcase
            end

            // I-type (Immediate)
            7'b0010011: begin
                RegWrite = 1;
                ALU_Src = 1;
                case (funct3)
                    3'b000:  ALU_Op = ALU_ADD;
                    3'b100:  ALU_Op = ALU_XOR;
                    3'b110:  ALU_Op = ALU_OR;
                    3'b111:  ALU_Op = ALU_AND;
                    3'b001:  ALU_Op = ALU_SLL;
                    3'b101:  ALU_Op = (funct7 == 7'b0000000) ? ALU_SRL : ALU_SRA;
                    3'b010:  ALU_Op = ALU_SLT;
                    3'b011:  ALU_Op = ALU_SLTU;
                    default: ALU_Op = ALU_DEF;
                endcase
            end

            // Load (I-type)
            7'b0000011: begin
                RegWrite = 1;
                MemRead = 1;
                MemtoReg = 1;
                ALU_Src = 1;
                ALU_Op = ALU_ADD;
            end

            // Store (S-type)
            7'b0100011: begin
                MemWrite = 1;
                ALU_Src = 1;
                ALU_Op = ALU_ADD;
            end

            // Branch (B-type)
            7'b1100011: begin
                Branch = 1;
                ALU_Src = 0;
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

            // JAL
            7'b1101111: begin
                RegWrite = 1;
                ALU_Src = 0;
                ALU_Op = ALU_JAL;
            end

            // JALR
            7'b1100111: begin
                RegWrite = 1;
                ALU_Src = 1;
                ALU_Op = ALU_JALR;
            end

            // AUIPC (U-type)
            7'b0010111: begin
                RegWrite = 1;
                ALU_Src = 1;
                ALU_Op = ALU_AUIPC;
            end

            // LUI (U-type)
            7'b0110111: begin
                RegWrite = 1;
                ALU_Src = 1;
                ALU_Op = ALU_LUI;
            end

            default: begin
                ALU_Op = ALU_DEF;
            end
        endcase
    end

endmodule
