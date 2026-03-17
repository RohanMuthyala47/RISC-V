import cpu_pkg::*;

module CPU_SingleCycle (
    input logic clk,
    input logic rst
);

    // Program Counter
    logic [ADDR_WIDTH - 1:0] pc;
    
    // Instruction
    logic [INSTR_WIDTH - 1:0] instruction;
    
    // Control Unit signals
    logic        MemRead;
    logic        MemtoReg;
    logic        MemWrite;
    logic        RegWrite;
    logic [4:0]  ALU_Op;
    
    // Instruction fields
    logic [6:0]                  opcode;
    logic [REG_ADDR_WIDTH - 1:0] rs1, rs2, rd;
    logic [2:0]                  funct3;
    logic [6:0]                  funct7;
    
    // Extract instruction fields
    assign opcode = instruction[6:0];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    // Register File signals
    logic [DATA_WIDTH - 1:0] read_data1, read_data2;
    // Data Memory -> Register File signals
    logic [DATA_WIDTH - 1:0] reg_write_data;
    
    always_comb begin
        if(MemtoReg == 1) begin
            reg_write_data = mem_read_data;
        end
        else begin
            reg_write_data = alu_result;
        end
    end
    
    // Sign-extended Immediate
    logic [DATA_WIDTH - 1:0] immediate;
    
    // ALU signals
    logic [DATA_WIDTH - 1:0] alu_result;
    logic                    branch_taken;
    logic                    jal_jump;
    logic                    jalr_jump;
    logic [ADDR_WIDTH - 1:0] branch_target;
    logic [ADDR_WIDTH - 1:0] jal_target;
    logic [ADDR_WIDTH - 1:0] jalr_target;
    
    // Data Memory signals
    logic [DATA_WIDTH - 1:0] mem_read_data;

    // Program Counter
    ProgramCounter pc_inst (
        .clk           (clk),
        .rst           (rst),
        
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        
        .is_jal        (jal_jump),
        .is_jalr       (jalr_jump),
        .jal_target    (jal_target),
        .jalr_target   (jalr_target),
        
        .pc            (pc)
    );
    
    // Instruction Memory
    InstructionMemory imem_inst (
        .pc          (pc),
        
        .instruction (instruction)
    );
    
    // Control Unit
    ControlUnit cu_inst (
        .opcode   (opcode),
        .funct3   (funct3),
        .funct7   (funct7),
        
        .MemRead  (MemRead),
        .MemtoReg (MemtoReg),
        .MemWrite (MemWrite),
        .RegWrite (RegWrite),
        
        .ALU_Op   (ALU_Op)
    );
    
    // Register File
    RegisterFile regfile_inst (
        .clk           (clk),
        .rst           (rst),
        
        .read_address1 (rs1),
        .read_address2 (rs2),
        
        .write_address (rd),
        .write_data    (reg_write_data),
        .write_enable  (RegWrite),
        
        .read_data1    (read_data1),
        .read_data2    (read_data2)
    );
    
    // Sign Extender
    ImmediateSignExtender immsignext_inst (
        .instruction (instruction),
        
        .immediate   (immediate)
    );
    
    // ALU
    ALU alu_inst (
        .pc            (pc),
        
        .op1           (read_data1),
        .op2           (read_data2),
        
        .ALU_Op        (ALU_Op),
        
        .immediate     (immediate),
        
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        
        .jal_jump      (jal_jump),
        .jalr_jump     (jalr_jump),
        .jal_target    (jal_target),
        .jalr_target   (jalr_target),

        .alu_result    (alu_result)
    );
    
    // Data Memory
    DataMemory dmem_inst (
        .clk        (clk),
        .rst        (rst),
        
        .funct3     (funct3),
        
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        
        .address    (alu_result),
        .write_data (read_data2),
        
        .read_data  (mem_read_data)
    );

endmodule
