module CPU_Pipelined (
    input  logic clk,
    input  logic rst
);
    
    // Sign Extender signals
    logic [31:0] Immediate_ID;
    
    // ALU signals
    logic [31:0] alu_op2;
    logic [31:0] alu_result_E;
    logic        branch_taken;
    logic        jal_jump;
    logic        jalr_jump;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    
    // Data Memory signals
    logic [31:0] mem_read_data;
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Updating pipeline registers
    ///////////////////////////////////////////////////////////////////////////////

    // Program Counter output signals
    logic [31:0] PC_IF;
    
    // Instruction Memory signals
    logic [31:0] Instruction_IF;
    
    // Program Counter
    ProgramCounter ProgramCounter (
        .clk(clk),
        .rst(rst),
        .branch_taken(branch_taken),
        .branch(Branch_E),
        .branch_target(branch_target),
        .is_jal(jal_jump),
        .is_jalr(jalr_jump),
        .jal_target(jal_target),
        .jalr_target(jalr_target),
        .pc(PC_IF)
    );
    
    // Instruction Memory
    InstructionMemory InstructionMemory (
        .clk(clk),
        .rst(rst),
        .pc(PC_IF),
        .instruction(Instruction_IF)
    );
    
    // IF-ID PIPELINE REGISTERS
    logic [31:0] PC_IF_ID, Instr_IF_ID;
    always_ff @(posedge clk)
    begin
        if(rst) begin
            PC_IF_ID <= 0;
            Instr_IF_ID <= 0;
        end
        else begin
            PC_IF_ID <= PC_IF;
            Instr_IF_ID <= Instruction_IF;
        end
    end
       
    logic [31:0] PC_ID = PC_IF_ID, Instruction_ID = Instr_IF_ID;
    
    // Instruction fields
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    
     // Extract instruction fields
    assign opcode = Instruction_ID[6:0];
    assign rd     = Instruction_ID[11:7];
    assign funct3 = Instruction_ID[14:12];
    assign rs1    = Instruction_ID[19:15];
    assign rs2    = Instruction_ID[24:20];
    assign funct7 = Instruction_ID[31:25];
    
    // Control Unit signals
    logic           Branch_ID;
    logic           MemRead_ID;
    logic           MemtoReg_ID;
    logic           MemWrite_ID;
    logic           ALU_Src_ID;
    logic           RegWrite_ID;
    logic [4:0]     ALU_Op_ID;
    logic [2:0]     instr_type_ID;
    
    // Control Unit
    ControlUnit ControlUnit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .Branch(Branch_ID),
        .MemRead(MemRead_ID),
        .MemtoReg(MemtoReg_ID),
        .MemWrite(MemWrite_ID),
        .ALU_Src(ALU_Src_ID),
        .RegWrite(RegWrite_ID),
        .alu_control(ALU_Op_ID),
        .instr_type(instr_type_ID)
    );
    
    // Register File signals
    logic [31:0] read_data1_ID, read_data2_ID;
    logic [31:0] write_data;
    
    assign write_data = MemtoReg_ID ? mem_read_data : alu_result;
    
    // Register File
    RegisterFile RegisterFile (
        .clk(clk),
        .rst(rst),
        .read_address1(rs1),
        .read_address2(rs2),
        .wr_address(rd),
        .data(write_data),
        .write_enable(RegWrite_ID),
        .read_data1(read_data1_ID),
        .read_data2(read_data2_ID)
    );
    
    // Sign Extender
    SignExtender SignExtender (
        .instruction(Instruction_ID),
        .instr_type(instr_type_ID),
        .immediate(Immediate_ID)
    );
    
    // IF-ID PIPELINE REGISTERS
    logic [31:0] PC_ID_E;
    logic        Branch_ID_E;
    logic        MemRead_ID_E;
    logic        MemtoReg_ID_E;
    logic        MemWrite_ID_E;
    logic        ALU_Src_ID_E;
    logic        RegWrite_ID_E;
    logic [4:0]  ALU_Op_ID_E;
    logic [2:0]  instr_type_ID_E;
    logic [31:0] read_data1_ID_E, read_data2_ID_E;
    logic [31:0] Immediate_ID_E;
    always_ff @(posedge clk)
    begin
        if(rst) begin
            PC_ID_E <= 0;
            Branch_ID_E <= 0;
            MemRead_ID_E <= 0;
            MemtoReg_ID_E <= 0;
            MemWrite_ID_E <= 0;
            ALU_Src_ID_E <= 0;
            RegWrite_ID_E <= 0;
            ALU_Op_ID_E <= 0;
            instr_type_ID_E <= 0;
            read_data1_ID_E <= 0;
            read_data2_ID_E <= 0;
            Immediate_ID_E <= 0;
        end
        else begin
            PC_ID_E <= PC_ID;
            Branch_ID_E <= Branch_ID;
            MemRead_ID_E <= MemRead_ID;
            MemtoReg_ID_E <= MemtoReg_ID;
            MemWrite_ID_E <= MemWrite_ID;
            ALU_Src_ID_E <= ALU_Src_ID;
            RegWrite_ID_E <= RegWrite_ID;
            ALU_Op_ID_E <= ALU_Op_ID;
            instr_type_ID_E <= instr_type_ID;
            read_data1_ID_E <= read_data1_ID;
            read_data2_ID_E <= read_data2_ID;
            Immediate_ID_E <= Immediate_ID;
        end
    end
    
    logic [31:0] PC_E = PC_ID_E;
    logic        Branch_E = Branch_ID_E;
    logic        MemRead_E = MemRead_ID_E;
    logic        MemtoReg_E = MemtoReg_ID_E;
    logic        MemWrite_E = MemWrite_ID_E;
    logic        ALU_Src_E = ALU_Src_ID_E;
    logic        RegWrite_E = RegWrite_ID_E;
    logic [4:0]  ALU_Op_E = ALU_Op_ID_E;
    logic [2:0]  instr_type_E = instr_type_ID_E;
    logic [31:0] read_data1_E = read_data1_ID_E, read_data2_E = read_data2_ID_E;
    logic [31:0] Immediate_E = Immediate_ID_E;
    
    assign alu_op2 = ALU_Src_E ? Immediate_E : read_data2_E;
    
    // ALU
    ALU ALU (
        .op1(read_data1_E),
        .op2(alu_op2),
        .alu_control(ALU_Op_E),
        .pc(PC_E),
        .alu_result(alu_result_E),
        .branch_taken(branch_taken),
        .jal_jump(jal_jump),
        .jalr_jump(jalr_jump),
        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target)
    );
    
    // Data Memory
    DataMemory DataMemory (
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(read_data2),
        .funct3(funct3),
        .read_data(mem_read_data)
    );

endmodule
