module CPU (
    input logic clk,
    input logic rst
);

    // Program Counter signals
    logic [31:0] pc, next_pc;
    
    // Instruction Memory signals
    logic [31:0] instruction;
    
    // Control Unit signals
    logic reg_write, mem_write, mem_read, mem_to_reg;
    logic alu_src, branch, jump;
    logic [4:0] alu_control;
    logic [2:0] instr_type;
    
    // Register File signals
    logic [4:0] rs1, rs2, rd;
    logic [31:0] reg_data1, reg_data2, write_data;
    
    // ALU signals
    logic [31:0] alu_op1, alu_op2, alu_result;
    logic branch_taken;
    logic [31:0] jal_target, jalr_target;
    
    // Sign Extender signals
    logic [31:0] immediate;
    
    // Data Memory signals
    logic [31:0] mem_read_data;
    
    // Instruction decode
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];
    
    // PC control logic
    always_comb begin
        if (jump && alu_control == 5'b10010) // JAL
            next_pc = jal_target;
        else if (jump && alu_control == 5'b10011) // JALR
            next_pc = jalr_target;
        else if (branch && branch_taken)
            next_pc = pc + immediate;
        else
            next_pc = pc + 32'd4;
    end
    
    // ALU input selection
    assign alu_op1 = reg_data1;
    assign alu_op2 = alu_src ? immediate : reg_data2;
    
    // Write-back
    assign write_data = mem_to_reg ? mem_read_data : alu_result;
    
    // Program Counter
    PC PC (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
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
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .alu_control(alu_control),
        .instr_type(instr_type)
    );
    
    // Register File
    RegisterFile RegisterFile (
        .clk(clk),
        .rst(rst),
        .read_address1(rs1),
        .read_address2(rs2),
        .read_data1(reg_data1),
        .read_data2(reg_data2),
        .wr_address(rd),
        .data(write_data),
        .write_enable(reg_write)
    );
    
    // Sign Extender
    SignExtender SignExtender (
        .instruction(instruction),
        .instr_type(instr_type),
        .immediate(immediate)
    );
    
    // ALU
    ALU ALU (
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_control(alu_control),
        .pc(pc),
        .alu_result(alu_result),
        .branch_taken(branch_taken),
        .jal_trgt_pc(jal_target),
        .jalr_trgt_pc(jalr_target)
    );
    
    // Data Memory
    DataMemory DataMemory (
        .clk(clk),
        .rst(rst),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(reg_data2),
        .funct3(instruction[14:12]),
        .read_data(mem_read_data)
    );

endmodule