import cpu_pkg::*;

module Hazard_DetectionUnit (
    input  logic [REG_ADDR_WIDTH - 1:0] rs1_ID,
    input  logic [REG_ADDR_WIDTH - 1:0] rs2_ID,
    
    input  logic [REG_ADDR_WIDTH - 1:0] rd_E,
    
    input  logic                        MemRead_E,
    
    output logic                        PCWrite,
    output logic                        IF_ID_Write,
    output logic                        stall_ctrl
);

	always_comb begin
		PCWrite     = 1'b1;
		IF_ID_Write = 1'b1;
		stall_ctrl  = 1'b0;
		
		if(MemRead_E && ((rd_E == rs1_ID) || (rd_E == rs2_ID))) begin
			PCWrite     = 1'b0;
			IF_ID_Write = 1'b0;
			stall_ctrl  = 1'b1;
		end
	end

endmodule
