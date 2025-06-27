module CPU (
    input  logic clk,
    input  logic rst
);

    // Program Counter signals
    logic [31:0] pc;
    
    // Instruction Memory signals
    logic [31:0] instruction;
    
    // Control Unit signals
    logic        Branch;
    logic        MemRead;
    logic        MemtoReg;
    logic        MemWrite;
    logic        ALU_Src;
    logic        RegWrite;
    logic [4:0]  alu_control;
    logic [2:0]  instr_type;
    
    // Instruction fields
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    
    // Register File signals
    logic [31:0] read_data1, read_data2;
    logic [31:0] write_data;
    
    // Sign Extender signals
    logic [31:0] immediate;
    
    // ALU signals
    logic [31:0] alu_op2;
    logic [31:0] alu_result;
    logic        branch_taken;
    logic        jal_jump;
    logic        jalr_jump;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    
    // Data Memory signals
    logic [31:0] mem_read_data;
    
    // Extract instruction fields
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    assign alu_op2 = ALU_Src ? immediate : read_data2;

    assign write_data = MemtoReg ? mem_read_data : alu_result;

    logic [31:0] branch_target;
    assign branch_target = pc + immediate;
    
    // Program Counter
    ProgramCounter ProgramCounter (
        .clk(clk),
        .rst(rst),
        .branch_taken(branch_taken),
        .branch(Branch),
        .branch_target(branch_target),
        .is_jal(jal_jump),
        .is_jalr(jalr_jump),
        .jal_target(jal_target),
        .jalr_target(jalr_target),
        .pc(pc)
    );
    
    // Instruction Memory
    InstructionMemory InstructionMemory (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instruction(instruction)
    );
    
    // Control Unit
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
    
    // Register File
    RegisterFile RegisterFile (
        .clk(clk),
        .rst(rst),
        .read_address1(rs1),
        .read_address2(rs2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .wr_address(rd),
        .data(write_data),
        .write_enable(RegWrite)
    );
    
    // Sign Extender
    SignExtender SignExtender (
        .instruction(instruction),
        .instr_type(instr_type),
        .immediate(immediate)
    );
    
    // ALU
    ALU ALU (
        .op1(read_data1),
        .op2(alu_op2),
        .alu_control(alu_control),
        .pc(pc),
        .alu_result(alu_result),
        .branch_taken(branch_taken),
        .jal_jump(jal_jump),
        .jalr_jump(jalr_jump),
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
