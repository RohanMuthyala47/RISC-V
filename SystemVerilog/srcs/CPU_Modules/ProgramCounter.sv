module ProgramCounter (
    input  logic            clk,
    input  logic            rst,

    input  logic            branch_taken,
    input  logic            branch,
    input  logic [31:0]     branch_target,
    
    input  logic            is_jal,
    input  logic            is_jalr,
    input  logic [31:0]     jal_target,
    input  logic [31:0]     jalr_target,
    
    output logic [31:0]     pc
);

    logic [31:0] next_pc;
    
    // Set program counter to branch target if branch instruction,
    // jump target if jump instruction,
    // otherwise increment by 4
    always_comb begin
        next_pc = pc + 32'd4;
        
        if (is_jal) begin
            next_pc = jal_target;
        end
        else if (is_jalr) begin
            next_pc = jalr_target;
        end
        else if (branch_taken && branch) begin
            next_pc = branch_target;
        end
    end

    // Update Program Counter
    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else
            pc <= next_pc;
    end

endmodule
