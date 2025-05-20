module pc_update (
    input  logic        clk,
    input  logic        rst,
    input  logic        taken_br,
    input  logic        is_jal,
    input  logic        is_jalr,
    input  logic [31:0] br_tgt_pc,
    input  logic [31:0] jalr_tgt_pc,
    output logic [31:0] pc
);

    logic [31:0] next_pc;

    always_comb begin
        if (reset)
            next_pc = 32'd0;
        else if (taken_br)
            next_pc = br_tgt_pc;
        else if (is_jal)
            next_pc = br_tgt_pc;
        else if (is_jalr)
            next_pc = jalr_tgt_pc;
        else
            next_pc = pc + 32'd4;
    end

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else
            pc <= next_pc;
    end

endmodule
