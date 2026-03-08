import cpu_pkg::*;

module CPU_Pipelined (
    input logic clk,
    input logic rst
);
    
    // Sign-Extended Immediate
    logic [DATA_WIDTH - 1:0] Immediate_ID;
    
    // ALU signals
    logic [DATA_WIDTH - 1:0] alu_op2_E;
    logic [DATA_WIDTH - 1:0] alu_result_E;
    
    // ALU -> PC signals
    logic                    branch_taken;
    logic [ADDR_WIDTH - 1:0] branch_target;
    
    logic                    jal_jump_E;
    logic                    jalr_jump_E;
    logic [ADDR_WIDTH - 1:0] jal_target;
    logic [ADDR_WIDTH - 1:0] jalr_target;
    
    // Data Memory signals
    logic [DATA_WIDTH - 1:0] mem_read_data_M;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stage 1 logic
    ///////////////////////////////////////////////////////////////////////////////

    // Program Counter
    logic [ADDR_WIDTH - 1:0]  PC_IF;
    
    // Instruction
    logic [INSTR_WIDTH - 1:0] Instruction_IF;
    
    // Program Counter
    ProgramCounter pc_inst (
        .clk           (clk),
        .rst           (rst),
        
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        
        .is_jal        (jal_jump_E),
        .is_jalr       (jalr_jump_E),
        .jal_target    (jal_target),
        .jalr_target   (jalr_target),
        
        .pc            (PC_IF)
    );
    
    // Instruction Memory
    InstructionMemory imem_inst (
        .pc          (PC_IF),
        
        .instruction (Instruction_IF)
    );
    
    // IF-ID PIPELINE REGISTERS
    logic [ADDR_WIDTH - 1:0]  PC_IF_ID;
    logic [INSTR_WIDTH - 1:0] Instruction_IF_ID;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            PC_IF_ID          <= ADDR_WIDTH'(0);
            Instruction_IF_ID <= INSTR_WIDTH'(0);
        end
        else begin
            PC_IF_ID          <= PC_IF;
            Instruction_IF_ID <= Instruction_IF;
        end
    end
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stage 2 logic
    ///////////////////////////////////////////////////////////////////////////////
       
    logic [ADDR_WIDTH - 1:0]  PC_ID;
    logic [INSTR_WIDTH - 1:0] Instruction_ID;
    
    assign PC_ID          =   PC_IF_ID;
    assign Instruction_ID =   Instruction_IF_ID;
    
    // Instruction fields
    logic [6:0]                  opcode;
    logic [REG_ADDR_WIDTH - 1:0] rs1, rs2, rd_ID;
    logic [2:0]                  funct3_ID;
    logic [6:0]                  funct7;
    
    // Extract instruction fields
    assign opcode    = Instruction_ID[6:0];
    assign rs1       = Instruction_ID[19:15];
    assign rs2       = Instruction_ID[24:20];
    assign rd_ID     = Instruction_ID[11:7];
    assign funct3_ID = Instruction_ID[14:12];
    assign funct7    = Instruction_ID[31:25];
    
    // Control Unit signals
    logic       MemRead_ID;
    logic       MemtoReg_ID;
    logic       MemWrite_ID;
    logic       RegWrite_ID;
    
    logic [4:0] ALU_Op_ID;
    
    // Control Unit
    ControlUnit cu_inst (
        .opcode   (opcode),
        .funct3   (funct3_ID),
        .funct7   (funct7),
        
        .MemRead  (MemRead_ID),
        .MemtoReg (MemtoReg_ID),
        .MemWrite (MemWrite_ID),
        .RegWrite (RegWrite_ID),
        
        .ALU_Op   (ALU_Op_ID)
    );
    
    // Register File signals
    logic [DATA_WIDTH - 1:0] read_data1_ID, read_data2_ID;
    logic [DATA_WIDTH - 1:0] reg_write_data;
    
    always_comb begin
        if((jal_jump_WB || jalr_jump_WB) == 1) begin
            reg_write_data = PC_WB + ADDR_WIDTH'(4);
        end
        else if(MemtoReg_WB == 1) begin
            reg_write_data = mem_read_data_WB;
        end
        else begin
            reg_write_data = alu_result_WB;
        end
    end
    
    // Register File
    RegisterFile regfile_inst (
        .clk           (clk),
        .rst           (rst),
        
        .read_address1 (rs1),
        .read_address2 (rs2),
        
        .write_address (rd_WB),
        .write_data    (reg_write_data),
        .write_enable  (RegWrite_WB),
        
        .read_data1    (read_data1_ID),
        .read_data2    (read_data2_ID)
    );
    
    // Sign Extender
    ImmediateSignExtender immsignext_inst (
        .instruction (Instruction_ID),
        
        .immediate   (Immediate_ID)
    );
    
    // ID-EX PIPELINE REGISTERS(2-3)
    logic [ADDR_WIDTH - 1:0]     PC_ID_E;
    
    logic [REG_ADDR_WIDTH - 1:0] rd_ID_E;
    
    logic [2:0]                  funct3_ID_E;
    
    logic                        MemRead_ID_E;
    logic                        MemtoReg_ID_E;
    logic                        MemWrite_ID_E;
    logic                        RegWrite_ID_E;
    
    logic [4:0]                  ALU_Op_ID_E;
    
    logic [DATA_WIDTH - 1:0]     read_data1_ID_E, read_data2_ID_E;
    
    logic [DATA_WIDTH - 1:0]     Immediate_ID_E;
    
    always_ff @(posedge clk)begin
        if(rst) begin
            PC_ID_E         <= ADDR_WIDTH'(0);
            
            rd_ID_E         <= REG_ADDR_WIDTH'(0);
            
            funct3_ID_E     <= 3'b0;
            
            MemRead_ID_E    <= 1'b0;
            MemtoReg_ID_E   <= 1'b0;
            MemWrite_ID_E   <= 1'b0;
            RegWrite_ID_E   <= 1'b0;
            
            ALU_Op_ID_E     <= 5'b0;
            
            read_data1_ID_E <= DATA_WIDTH'(0);
            read_data2_ID_E <= DATA_WIDTH'(0);
            
            Immediate_ID_E  <= DATA_WIDTH'(0);
        end
        else begin
            PC_ID_E         <= PC_ID;
            
            rd_ID_E         <= rd_ID;
            
            funct3_ID_E     <= funct3_ID;
            
            MemRead_ID_E    <= MemRead_ID;
            MemtoReg_ID_E   <= MemtoReg_ID;
            MemWrite_ID_E   <= MemWrite_ID;
            RegWrite_ID_E   <= RegWrite_ID;
            
            ALU_Op_ID_E     <= ALU_Op_ID;
            
            read_data1_ID_E <= read_data1_ID;
            read_data2_ID_E <= read_data2_ID;
            
            Immediate_ID_E  <= Immediate_ID;
        end
    end
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stage 3 logic
    ///////////////////////////////////////////////////////////////////////////////
    
    logic [ADDR_WIDTH - 1:0]     PC_E;
    logic [REG_ADDR_WIDTH - 1:0] rd_E;
    logic [2:0]                  funct3_E;
    logic                        MemRead_E;
    logic                        MemtoReg_E;
    logic                        MemWrite_E;
    logic                        RegWrite_E;
    logic [4:0]                  ALU_Op_E;
    logic [DATA_WIDTH - 1:0]     read_data1_E;
    logic [DATA_WIDTH - 1:0]     read_data2_E;
    logic [DATA_WIDTH - 1:0]     Immediate_E;
    
    assign PC_E         = PC_ID_E;
    assign rd_E         = rd_ID_E;
    assign funct3_E     = funct3_ID_E;
    assign MemRead_E    = MemRead_ID_E;
    assign MemtoReg_E   = MemtoReg_ID_E;
    assign MemWrite_E   = MemWrite_ID_E;
    assign RegWrite_E   = RegWrite_ID_E;
    assign ALU_Op_E     = ALU_Op_ID_E;
    assign read_data1_E = read_data1_ID_E;
    assign read_data2_E = read_data2_ID_E;
    assign Immediate_E  = Immediate_ID_E;
    
    // ALU
    ALU alu_inst (
    	.pc            (PC_E),
    	
        .op1           (read_data1_E),
        .op2           (read_data2_E),
        
        .ALU_Op        (ALU_Op_E),
        
        .immediate     (Immediate_E),
        
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        
        .jal_jump      (jal_jump_E),
        .jalr_jump     (jalr_jump_E),
        .jal_target    (jal_target),
        .jalr_target   (jalr_target),
        
        .alu_result    (alu_result_E)
    );
    
    // EX-MEM PIPELINE REGISTERS
    logic [ADDR_WIDTH - 1:0]     PC_E_M;
    
    logic [REG_ADDR_WIDTH - 1:0] rd_E_M;
    
    logic [2:0]                  funct3_E_M;
    
    logic [DATA_WIDTH - 1:0]     read_data2_E_M;
    
    logic                        MemRead_E_M;
    logic                        MemtoReg_E_M;
    logic                        MemWrite_E_M;
    logic                        RegWrite_E_M;
    
    logic [DATA_WIDTH - 1:0]     alu_result_E_M;
    
    logic                        jal_jump_E_M;
    logic                        jalr_jump_E_M;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            PC_E_M         <= ADDR_WIDTH'(0);
            
	        rd_E_M         <= REG_ADDR_WIDTH'(0);
	    
            funct3_E_M     <= 3'b0;
            
            read_data2_E_M <= DATA_WIDTH'(0);
            
            MemRead_E_M    <= 1'b0;
            MemtoReg_E_M   <= 1'b0;
            MemWrite_E_M   <= 1'b0;
            RegWrite_E_M   <= 1'b0;
            
            alu_result_E_M <= DATA_WIDTH'(0);
            
            jal_jump_E_M   <= 1'b0;
            jalr_jump_E_M  <= 1'b0;
        end
        else begin
            PC_E_M         <= PC_E;
            
            rd_E_M         <= rd_E;
            
            funct3_E_M     <= funct3_E;
            
            read_data2_E_M <= read_data2_E;
            
            MemRead_E_M    <= MemRead_E;
            MemtoReg_E_M   <= MemtoReg_E;
            MemWrite_E_M   <= MemWrite_E;
            RegWrite_E_M   <= RegWrite_E;
            
            alu_result_E_M <= alu_result_E;
            
            jal_jump_E_M   <= jal_jump_E;
            jalr_jump_E_M  <= jalr_jump_E;
        end
    end
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stage 4 logic
    ///////////////////////////////////////////////////////////////////////////////
    logic [ADDR_WIDTH - 1:0]     PC_M;
    logic [REG_ADDR_WIDTH - 1:0] rd_M;
    logic [2:0]                  funct3_M;
    logic [DATA_WIDTH - 1:0]     read_data2_M;
    logic                        MemRead_M;
    logic                        MemtoReg_M;
    logic                        MemWrite_M;
    logic                        RegWrite_M;
    logic [DATA_WIDTH - 1:0]     alu_result_M;
    logic                        jal_jump_M;
    logic                        jalr_jump_M;
   
    assign PC_M         = PC_E_M;
    assign rd_M         = rd_E_M;
    assign funct3_M     = funct3_E_M;
    assign read_data2_M = read_data2_E_M;
    assign MemRead_M    = MemRead_E_M;
    assign MemtoReg_M   = MemtoReg_E_M;
    assign MemWrite_M   = MemWrite_E_M;
    assign RegWrite_M   = RegWrite_E_M;
    assign alu_result_M = alu_result_E_M;
    assign jal_jump_M   = jal_jump_E_M;
    assign jalr_jump_M  = jalr_jump_E_M;
    
    DataMemory dmem_inst (
        .clk        (clk),
        .rst        (rst),
        
        .MemRead    (MemRead_M),
        .MemWrite   (MemWrite_M),
        
        .address    (alu_result_M),
        
        .write_data (read_data2_M),
        
        .funct3     (funct3_M),
        
        .read_data  (mem_read_data_M)
    );
    
    // MEM-WB PIPELINE REGISTERS
    logic [ADDR_WIDTH - 1:0]     PC_M_WB;
    
    logic [REG_ADDR_WIDTH - 1:0] rd_M_WB;
    
    logic                        MemtoReg_M_WB;
    logic                        RegWrite_M_WB;
    
    logic [DATA_WIDTH - 1:0]     alu_result_M_WB;
    
    logic [DATA_WIDTH - 1:0]     mem_read_data_M_WB;
    
    logic                        jal_jump_M_WB;
    logic                        jalr_jump_M_WB;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            PC_M_WB            <= ADDR_WIDTH'(0);
            
            rd_M_WB            <= REG_ADDR_WIDTH'(0);
            
            MemtoReg_M_WB      <= 1'b0;
            RegWrite_M_WB      <= 1'b0;
            
            alu_result_M_WB    <= DATA_WIDTH'(0);
            
            mem_read_data_M_WB <= DATA_WIDTH'(0);
            
            jal_jump_M_WB      <= 1'b0;
            jalr_jump_M_WB     <= 1'b0;
        end
        else begin
            PC_M_WB            <= PC_M;
            
            rd_M_WB            <= rd_M;
            
            MemtoReg_M_WB      <= MemtoReg_M;
            RegWrite_M_WB      <= RegWrite_M;
            
            alu_result_M_WB    <= alu_result_M;
            
            mem_read_data_M_WB <= mem_read_data_M;
            
            jal_jump_M_WB      <= jal_jump_M;
            jalr_jump_M_WB     <= jalr_jump_M;
        end
    end
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stage 5 logic
    ///////////////////////////////////////////////////////////////////////////////
    logic [ADDR_WIDTH - 1:0]     PC_WB;
    logic [REG_ADDR_WIDTH - 1:0] rd_WB;
    logic                        MemtoReg_WB;
    logic                        RegWrite_WB;
    logic [DATA_WIDTH - 1:0]     alu_result_WB;
    logic [DATA_WIDTH - 1:0]     mem_read_data_WB;
    logic                        jal_jump_WB;
    logic                        jalr_jump_WB;
    
    assign PC_WB            = PC_M_WB;
    assign rd_WB            = rd_M_WB;
    assign MemtoReg_WB      = MemtoReg_M_WB;
    assign RegWrite_WB      = RegWrite_M_WB;
    assign alu_result_WB    = alu_result_M_WB;
    assign mem_read_data_WB = mem_read_data_M_WB;
    assign jal_jump_WB      = jal_jump_M_WB;
    assign jalr_jump_WB     = jalr_jump_M_WB;
    
endmodule
