module ControlUnit (
    input  logic [6:0]   opcode,
    input  logic [2:0]   funct3,
    input  logic [6:0]   funct7,
    
    output logic          Branch,
    output logic          MemRead,
    output logic          MemtoReg,
    output logic          MemWrite,
    output logic          ALU_Src,
    output logic          RegWrite,

    output logic [4:0] alu_control,
    output logic [2:0] instr_type
);

    always_comb begin
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        MemWrite = 0;
        ALU_Src = 0;
        RegWrite = 0;
        alu_control = 5'b11111;
        instr_type = 3'b110;

        case (opcode)
            // R-type
            7'b0110011: begin
                RegWrite = 1;
                instr_type = 3'b000; // R-type
                case ({funct7, funct3})
                    10'b0000000_000: alu_control = 5'b00000; // ADD
                    10'b0100000_000: alu_control = 5'b00001; // SUB
                    10'b0000000_100: alu_control = 5'b00010; // XOR
                    10'b0000000_110: alu_control = 5'b00011; // OR
                    10'b0000000_111: alu_control = 5'b00100; // AND
                    10'b0000000_001: alu_control = 5'b00101; // SLL
                    10'b0000000_101: alu_control = 5'b00110; // SRL
                    10'b0100000_101: alu_control = 5'b00111; // SRA
                    10'b0000000_010: alu_control = 5'b01000; // SLT
                    10'b0000000_011: alu_control = 5'b01001; // SLTU
                    
                    default:                   alu_control = 5'b11111; //Illegal
                endcase
            end

            // I-type: Immediate operations & JALR
            7'b0010011: begin
                RegWrite = 1;
                ALU_Src = 1;
                instr_type = 3'b001;
                case (funct3)
                    3'b000: alu_control = 5'b00000; // ADDI
                    3'b100: alu_control = 5'b00010; // XORI
                    3'b110: alu_control = 5'b00011; // ORI
                    3'b111: alu_control = 5'b00100; // ANDI
                    3'b001: alu_control = 5'b00101; // SLLI
                    3'b101: begin
                        alu_control = (funct7 == 7'b0000000) ? 5'b00110 : 5'b00111; // SRLI or SRAI
                    end
                    3'b010: alu_control = 5'b01000; // SLTI
                    3'b011: alu_control = 5'b01001; // SLTIU
                    
                    default: alu_control = 5'b11111; //Illegal
                endcase
            end

            // Load (I-type)
            7'b0000011: begin
                RegWrite = 1;
                MemRead = 1;
                MemtoReg = 1;
                ALU_Src = 1;
                alu_control = 5'b00000; // ADD
                instr_type = 3'b001;
            end

            // S-type
            7'b0100011: begin
                MemWrite = 1;
                ALU_Src = 1;
                alu_control = 5'b00000; // ADD
                instr_type = 3'b010;
            end

            // B-type
            7'b1100011: begin
                Branch = 1;
                ALU_Src = 0;
                instr_type = 3'b011;
                case (funct3)
                    3'b000: alu_control = 5'b01010; // BEQ
                    3'b001: alu_control = 5'b01011; // BNE
                    3'b100: alu_control = 5'b01100; // BLT
                    3'b101: alu_control = 5'b01101; // BGE
                    3'b110: alu_control = 5'b01110; // BLTU
                    3'b111: alu_control = 5'b01111; // BGEU
                
                    default: alu_control = 5'b11111;
                endcase
            end

            // JAL
            7'b1101111: begin
                RegWrite = 1;
                ALU_Src = 0;
                alu_control = 5'b10010; // JAL
                instr_type = 3'b101;
            end

            //JALR
            7'b1100111: begin
                RegWrite = 1;
                ALU_Src = 1;
                alu_control = 5'b10011; // JALR
                instr_type = 3'b001;
            end


            // AUIPC (U-type)
            7'b0010111: begin
                RegWrite = 1;
                ALU_Src = 1;
                alu_control = 5'b10001;
                instr_type = 3'b100;
            end

            // LUI (U-type)
            7'b0110111: begin
                RegWrite = 1;
                ALU_Src = 1;
                alu_control = 5'b10000;
                instr_type = 3'b100;
            end

            default: begin
                alu_control = 5'b11111;
                instr_type = 3'b110;
            end
        endcase
    end

endmodule