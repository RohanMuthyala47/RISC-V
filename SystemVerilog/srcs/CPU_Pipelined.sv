module CPU_Pipelined (
    input  logic clk,
    input  logic rst
);
    
    // Sign Extender signals
    logic [31:0] Immediate_ID;
    
    // ALU signals
    logic [31:0] alu_op2_E;
    logic [31:0] alu_result_E;
    logic        branch_taken;
    logic        jal_jump;
    logic        jalr_jump;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    
    // Data Memory signals
    logic [31:0] mem_read_data_M;
    
    
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
    logic [4:0]  rs1, rs2, rd_ID;
    logic [2:0]  funct3_ID;
    logic [6:0]  funct7;
    
    // Extract instruction fields
    assign opcode    = Instruction_ID[6:0];
    assign rd_ID     = Instruction_ID[11:7];
    assign funct3_ID = Instruction_ID[14:12];
    assign rs1       = Instruction_ID[19:15];
    assign rs2       = Instruction_ID[24:20];
    assign funct7    = Instruction_ID[31:25];
    
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
        .funct3(funct3_ID),
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
    
    assign write_data = MemtoReg_WB ? mem_read_data_WB : alu_result_WB;
    
    // Register File
    RegisterFile RegisterFile (
        .clk(clk),
        .rst(rst),
        .read_address1(rs1),
        .read_address2(rs2),
        .wr_address(rd_WB),
        .data(write_data),
        .write_enable(RegWrite_WB),
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
    logic [4:0]  rd_ID_E;
    logic [2:0]  funct3_ID_E;
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
            PC_ID_E         <= 0;
            rd_ID_E         <= 0;
            funct3_ID_E     <= 0;
            Branch_ID_E     <= 0;
            MemRead_ID_E    <= 0;
            MemtoReg_ID_E   <= 0;
            MemWrite_ID_E   <= 0;
            ALU_Src_ID_E    <= 0;
            RegWrite_ID_E   <= 0;
            ALU_Op_ID_E     <= 0;
            instr_type_ID_E <= 0;
            read_data1_ID_E <= 0;
            read_data2_ID_E <= 0;
            Immediate_ID_E  <= 0;
        end
        else begin
            PC_ID_E         <= PC_ID;
            rd_ID_E         <= rd_ID;
            funct3_ID_E     <= funct3_ID;
            Branch_ID_E     <= Branch_ID;
            MemRead_ID_E    <= MemRead_ID;
            MemtoReg_ID_E   <= MemtoReg_ID;
            MemWrite_ID_E   <= MemWrite_ID;
            ALU_Src_ID_E    <= ALU_Src_ID;
            RegWrite_ID_E   <= RegWrite_ID;
            ALU_Op_ID_E     <= ALU_Op_ID;
            instr_type_ID_E <= instr_type_ID;
            read_data1_ID_E <= read_data1_ID;
            read_data2_ID_E <= read_data2_ID;
            Immediate_ID_E  <= Immediate_ID;
        end
    end
    
    logic [31:0] PC_E         = PC_ID_E;
    logic [4:0]  rd_E         = rd_ID_E;
    logic [2:0]  funct3_E     = funct3_ID_E;
    logic        Branch_E     = Branch_ID_E;
    logic        MemRead_E    = MemRead_ID_E;
    logic        MemtoReg_E   = MemtoReg_ID_E;
    logic        MemWrite_E   = MemWrite_ID_E;
    logic        ALU_Src_E    = ALU_Src_ID_E;
    logic        RegWrite_E   = RegWrite_ID_E;
    logic [4:0]  ALU_Op_E     = ALU_Op_ID_E;
    logic [2:0]  instr_type_E = instr_type_ID_E;
    logic [31:0] read_data1_E = read_data1_ID_E;
    logic [31:0] read_data2_E = read_data2_ID_E;
    logic [31:0] Immediate_E  = Immediate_ID_E;
    
    assign alu_op2_E = ALU_Src_E ? Immediate_E : read_data2_E;
    
    // ALU
    ALU ALU (
        .op1(read_data1_E),
        .op2(alu_op2_E),
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
    
    // E-M PIPELINE REGISTERS
    logic [4:0]  rd_E_M;
    logic [2:0]  funct3_E_M;
    logic [31:0] read_data2_E_M;
    logic        MemRead_E_M;
    logic        MemtoReg_E_M;
    logic        MemWrite_E_M;
    logic        RegWrite_E_M;
    logic        Branch_E_M;
    logic [31:0] alu_result_E_M;
    
    always_ff @(posedge clk)
    begin
        if(rst) begin
            rd_E_M         <= 0;
            funct3_E_M     <= 0;
            read_data2_E_M <= 0;
            Branch_E_M     <= 0;
            MemRead_E_M    <= 0;
            MemtoReg_E_M   <= 0;
            MemWrite_E_M   <= 0;
            RegWrite_E_M   <= 0;
            alu_result_E_M <= 0;
        end
        else begin
            rd_E_M         <= rd_E;
            funct3_E_M     <= funct3_E;
            read_data2_E_M <= read_data2_E;
            Branch_E_M     <= Branch_E;
            MemRead_E_M    <= MemRead_E;
            MemtoReg_E_M   <= MemtoReg_E;
            MemWrite_E_M   <= MemWrite_E;
            RegWrite_E_M   <= RegWrite_E;
            alu_result_E_M <= alu_result_E;
        end
    end
    
    logic [4:0]  rd_M         = rd_E_M;
    logic [2:0]  funct3_M     = funct3_E_M;
    logic [31:0] read_data2_M = read_data2_E_M;
    logic        MemRead_M    = MemRead_E_M;
    logic        MemtoReg_M   = MemtoReg_E_M;
    logic        MemWrite_M   = MemWrite_E_M;
    logic        RegWrite_M   = RegWrite_E_M;
    logic        Branch_M     = Branch_E_M;
    logic [31:0] alu_result_M = alu_result_E_M;
    
    DataMemory DataMemory (
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead_M),
        .MemWrite(MemWrite_M),
        .address(alu_result_M),
        .write_data(read_data2_M),
        .funct3(funct3_M),
        .read_data(mem_read_data_M)
    );
    
    // M-WB PIPELINE REGISTERS
    logic [4:0]  rd_M_WB;
    logic        MemtoReg_M_WB;
    logic        RegWrite_M_WB;
    logic [31:0] alu_result_M_WB;
    logic [31:0] mem_read_data_M_WB;
    
    always_ff @(posedge clk)
    begin
        if(rst) begin
            rd_M_WB            <= 0;
            MemtoReg_M_WB      <= 0;
            RegWrite_M_WB      <= 0;
            alu_result_M_WB    <= 0;
            mem_read_data_M_WB <= 0;
        end
        else begin
            rd_M_WB            <= rd_M;
            MemtoReg_M_WB      <= MemtoReg_M;
            RegWrite_M_WB      <= RegWrite_M;
            alu_result_M_WB    <= alu_result_M;
            mem_read_data_M_WB <= mem_read_data_M;
        end
    end
    
    logic [4:0]  rd_WB            = rd_M_WB;
    logic        MemtoReg_WB      = MemtoReg_M_WB;
    logic        RegWrite_WB      = RegWrite_M_WB;
    logic [31:0] alu_result_WB    = alu_result_M_WB;
    logic [31:0] mem_read_data_WB = mem_read_data_M_WB;
    
endmodule
