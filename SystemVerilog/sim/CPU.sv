module CPU (
    input  logic        clk,
    input  logic        rst
);

    //=================================================
    //INTERMEDIATE WIRES
    //=================================================

    // Program Counter signals
    logic [31:0] pc;
    logic [31:0] next_pc;

    // Instruction memory signals
    logic [31:0] instruction;

    // Instruction Decode
    logic [6:0]  opcode = instruction[6:0];
    logic [4:0]  rd     = instruction[11:7];
    logic [2:0]  funct3 = instruction[14:12];
    logic [4:0]  rs1    = instruction[19:15];
    logic [4:0]  rs2    = instruction[24:20];
    logic [6:0]  funct7 = instruction[31:25];

    // Register File signals
    logic [31:0] reg_data1, reg_data2, write_back_data;

    // Immediate Generator (Sign Extender)
    logic [31:0] imm;
    logic [2:0]  instr_type;

    // Control Signals
    logic        RegWrite, MemWrite, MemRead, MemtoReg, ALU_Src, Branch;
    logic [4:0]  alu_control;

    // ALU Signals
    logic [31:0] alu_op2;
    logic [31:0] alu_result;
    logic        branch_taken;
    logic        jal_jump, jalr_jump;
    logic [31:0] branch_target, jal_target, jalr_target;

    // Data Memory Signals
    logic [31:0] mem_read_data;

    //=================================================
    //BLOCK INSTANTIATIONS
    //=================================================
    
    ProgramCounter ProgramCounter (
        .clk(clk),
        .rst(rst),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .is_jal(jal_jump),
        .is_jalr(jalr_jump),
        .jal_target(jal_target),
        .jalr_target(jalr_target),
        .pc(pc)
    );

    InstructionMemory InstructionMemory (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instruction(instruction)
    );

    ControlUnit ControlUnit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALU_Src(ALU_Src),
        .RegWrite(RegWrite),
        .alu_control(alu_control),
        .instr_type(instr_type)
    );

    RegisterFile RegisterFile (
        .clk(clk),
        .rst(rst),
        .read_address1(rs1),
        .read_address2(rs2),
        .read_data1(reg_data1),
        .read_data2(reg_data2),
        .wr_address(rd),
        .data(write_back_data),
        .write_enable(RegWrite)
    );

    SignExtender SignExtender (
        .instruction(instruction),
        .instr_type(instr_type),
        .immediate(imm)
    );

    assign alu_op2 = (ALU_Src) ? imm : reg_data2;

    ALU ALU (
        .op1(reg_data1),
        .op2(alu_op2),
        .alu_control(alu_control),
        .pc(pc),
        .alu_result(alu_result),
        .branch_taken(branch_taken),
        .jal_jump(jal_jump),
        .jalr_jump(jalr_jump),
        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target)
    );

    DataMemory DataMemory (
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(reg_data2),
        .funct3(funct3),
        .read_data(mem_read_data)
    );

    assign write_back_data = (MemtoReg) ? mem_read_data : alu_result;

endmodule
