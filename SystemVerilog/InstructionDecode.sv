module InstructionDecode(
    input  logic [31:0] instr,
    
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,
    output logic [31:0] imm,

    // field validity signals
    output logic funct3_valid,
    output logic rs1_valid,
    output logic rs2_valid,
    output logic rd_valid,
    output logic imm_valid,

    // Instruction type 
    output logic is_u_instr,
    output logic is_i_instr,
    output logic is_r_instr,
    output logic is_s_instr,
    output logic is_b_instr,
    output logic is_j_instr,

    // decoded alu instructions
    output logic is_beq, is_bne, is_blt, is_bge, is_bltu, is_bgeu,
    output logic is_lui, is_auipc,
    output logic is_jal, is_jalr,
    output logic is_slti, is_sltiu, is_xori, is_ori, is_andi,
    output logic is_slli, is_srli, is_srai,
    output logic is_addi, is_add,
    output logic is_sub, is_sll, is_slt, is_sltu, is_xor,
    output logic is_srl, is_sra, is_or, is_and,
    output logic is_load
);

    //field extraction
    assign opcode  = instr[6:0];
    assign rd      = instr[11:7];
    assign funct3  = instr[14:12];
    assign rs1     = instr[19:15];
    assign rs2     = instr[24:20];
    assign funct7  = instr[31:25];

    // Instruction type 
    assign is_u_instr = (opcode[6:2]  == 5'b00101) || (opcode[6:2]  == 5'b01101);
    assign is_i_instr =  (opcode[6:2]  == 5'b00000 || opcode[6:2]  == 5'b00001 ||
                                     opcode[6:2]  == 5'b00100 || opcode[6:2]  == 5'b00110 ||
                                     opcode[6:2]  == 5'b11001);
    assign is_r_instr =  (opcode[6:2]  == 5'b01011 || opcode[6:2]  == 5'b01100 ||
                                     opcode[6:2]  == 5'b01110 || opcode[6:2]  == 5'b10100);
    assign is_s_instr = (opcode[6:2]  == 5'b01000 || opcode[6:2]  == 5'b01001);
    assign is_b_instr = (opcode[6:2]  == 5'b11000);
    assign is_j_instr =  (opcode[6:2]  == 5'b11011);

    //field validity signals
    assign funct3_valid = is_r_instr || is_i_instr || is_s_instr || is_b_instr;
    assign rs1_valid    = is_r_instr || is_i_instr || is_s_instr || is_b_instr;
    assign rs2_valid    = is_r_instr || is_s_instr || is_b_instr;
    assign rd_valid     = is_r_instr || is_i_instr || is_u_instr || is_j_instr;
    assign imm_valid    = is_i_instr || is_s_instr || is_b_instr || is_u_instr || is_j_instr;

    //instruction type validity
    always_comb begin
        unique case (1)
            is_i_instr: imm = {{21{instr[31]}}, instr[30:20]};
            is_s_instr: imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
            is_b_instr: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            is_u_instr: imm = {instr[31:12], 12'b0};
            is_j_instr: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default:    imm = 32'b0;
        endcase
    end

    // Instruction decode
    logic [10:0] dec_bits;
    assign dec_bits = {instr[30], funct3, opcode};

    assign is_beq   = (dec_bits  == 11'b00001100011) || (dec_bits  == 11'b10001100011);
    assign is_bne   = (dec_bits[9:0] == 10'b0011100011);
    assign is_blt   =   (dec_bits[9:0] == 10'b1001100011);
    assign is_bge   = (dec_bits[9:0] == 10'b1011100011);
    assign is_bltu  = (dec_bits[9:0] == 10'b1101100011);
    assign is_bgeu  = (dec_bits[9:0] == 10'b1111100011);

    assign is_lui   = (dec_bits & 11'b00000111111) == 11'b00000110111;
    assign is_auipc = (dec_bits & 11'b00000111111) == 11'b00000010111;

    assign is_jal   = (dec_bits[6:0]  == 7'b1101111); //jump and link
    assign is_jalr  = (dec_bits[9:0] == 10'b0001100111); //jump and link register

    assign is_addi  = (dec_bits[9:0] == 10'b0000010011);
    assign is_slti     = (dec_bits[9:0] == 10'b0100010011);
    assign is_sltiu   = (dec_bits[9:0] == 10'b0110010011);
    assign is_xori    = (dec_bits[9:0] == 10'b1000010011);
    assign is_ori      = (dec_bits[9:0] == 10'b1100010011);
    assign is_andi   = (dec_bits[9:0] == 10'b1110010011);
    assign is_slli      = (dec_bits == 11'b00010010011);
    assign is_srli     = (dec_bits == 11'b01010010011);
    assign is_srai   = (dec_bits == 11'b11010010011);

    assign is_add   = (dec_bits == 11'b00000110011);
    assign is_sub   = (dec_bits == 11'b10000110011);
    assign is_sll   = (dec_bits == 11'b00010110011);
    assign is_slt   = (dec_bits == 11'b00100110011);
    assign is_sltu  = (dec_bits == 11'b00110110011);
    assign is_xor   = (dec_bits == 11'b01000110011);
    assign is_srl   = (dec_bits == 11'b01010110011);
    assign is_sra   = (dec_bits == 11'b11010110011);
    assign is_or    = (dec_bits == 11'b01100110011);
    assign is_and   = (dec_bits == 11'b01110110011);

    assign is_load  = (opcode == 7'b0000011);

endmodule