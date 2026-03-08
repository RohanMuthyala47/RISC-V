import cpu_pkg::*;

module ForwardingUnit (
    input  logic [REG_ADDR_WIDTH - 1:0] rs1_E,
    input  logic [REG_ADDR_WIDTH - 1:0] rs2_E,
    
    input  logic [REG_ADDR_WIDTH - 1:0] rd_M,
    input  logic [REG_ADDR_WIDTH - 1:0] rd_WB,
    
    input  logic                        RegWrite_M,
    input  logic                        RegWrite_WB,
    
    output logic [1:0]                  ForwardA,
    output logic [1:0]                  ForwardB
);

    always_comb begin
        if ((RegWrite_M) && (rd_M != 0) && (rd_M == rs1_E))
            ForwardA = 2'b10;
        else if ((RegWrite_WB) && (rd_WB != 0) && !(RegWrite_M && (rd_M != 0) && (rd_M == rs1_E)) && (rd_WB == rs1_E))
            ForwardA = 2'b01;
        else
            ForwardA = 2'b00;
    end

    always_comb begin
        if ((RegWrite_M) && (rd_M != 0) && (rd_M == rs2_E))
            ForwardB = 2'b10;
        else if ((RegWrite_WB) && (rd_WB != 0) && !(RegWrite_M && (rd_M != 0) && (rd_M == rs2_E)) && (rd_WB == rs2_E))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end

endmodule
