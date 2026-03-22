import cpu_pkg::*;

module InstructionCache (
	input logic                      clk,
	input logic                      rst,
	
	input  logic                     cpu_addr_req,
	input  logic [ADDR_WIDTH - 1:0]  address,
	
	output logic [INSTR_WIDTH - 1:0] instruction,

	output logic                     stall,
	
	AXI_if.master                    axi
);

	// Cache Memory declaration
	logic                        cache_valid_array [0:CACHE_LINES - 1]; // Cache valid bits
	logic [CACHE_TAG_BITS - 1:0] cache_tag_array   [0:CACHE_LINES - 1]; // Tag array
	logic [DATA_WIDTH - 1:0]     cache_data_array  [0:CACHE_LINES - 1]; // Data array
	
	logic [CACHE_TAG_BITS - 1:0]    addr_tag;
	logic [CACHE_INDEX_BITS - 1:0]  addr_index;
	logic [CACHE_OFFSET_BITS - 1:0] addr_offset;
	
	assign addr_tag    = address[ADDR_WIDTH - 1 : CACHE_INDEX_BITS + CACHE_OFFSET_BITS];
	assign addr_index  = address[CACHE_INDEX_BITS + CACHE_OFFSET_BITS - 1 : CACHE_OFFSET_BITS];
	assign addr_offset = address[CACHE_OFFSET_BITS - 1 : 0];
	
	logic                        cache_line_valid;
	logic [CACHE_TAG_BITS - 1:0] cache_line_tag;
	logic [DATA_WIDTH - 1:0]     cache_line_data;
	
	assign cache_line_valid = cache_valid_array[addr_index];
	assign cache_line_tag   = cache_tag_array  [addr_index];
	assign cache_line_data  = cache_data_array [addr_index];
	
	logic  hit;
	assign hit = cache_line_valid && (cache_line_tag == addr_tag);
	
	cache_state_t curr_state, next_state;
	
	always_ff @(posedge clk) begin
		if(rst)
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end
	
	always_comb begin
    	next_state = curr_state;

    	case (curr_state)
        	IDLE: next_state        = cpu_addr_req ? CHECK : IDLE;

        	CHECK: next_state       = hit ? (cpu_addr_req ? CHECK : IDLE) : RD_REQ;

        	RD_REQ: next_state      = axi.ARREADY ? RD_DATA : RD_REQ;

        	RD_DATA: next_state     = (axi.RLAST && axi.RVALID) ? RD_COMPLETE : RD_DATA;

        	RD_COMPLETE: next_state = cpu_addr_req ? CHECK : IDLE;

        	default: next_state     = IDLE;
        	
    	endcase
	end
	
	always_comb begin
    	stall       = 1'b0;
    	instruction = INSTR_WIDTH'(0);

    	// AXI READ ADDRESS CHANNEL
    	axi.ARVALID = 1'b0;
    	axi.ARADDR  = ADDR_WIDTH'(0);
    	axi.ARLEN   = 8'd0;   // single-beat burst
    	axi.ARSIZE  = 3'b010; // 4 bytes per beat
    	axi.ARBURST = 2'b01;  // INCR
    	
    	// AXI READ DATA CHANNEL
    	axi.RREADY  = 1'b0;

    	case (curr_state)
        	IDLE: ;

        	CHECK: begin
            	if (hit) begin
                	stall       = 1'b0;
                	instruction = cache_line_data[INSTR_WIDTH - 1:0];
            	end 
            	else begin
                	stall = 1'b1;
            	end
        	end

        	RD_REQ: begin
            	stall       = 1'b1;
            	axi.ARVALID = 1'b1;
            	axi.ARADDR  = {addr_tag, addr_index, CACHE_OFFSET_BITS'(0)};
        	end

        	RD_DATA: begin
            	stall       = 1'b1;
            	axi.RREADY  = 1'b1;
        	end

        	RD_COMPLETE: begin
            	stall       = 1'b0;
            	instruction = cache_line_data[INSTR_WIDTH - 1:0];
        	end

        	default: ;
        	
    	endcase
	end
	
	always_ff @(posedge clk) begin
    	if (rst) begin
        	for (int i = 0; i < CACHE_LINES; i = i + 1)
            	cache_valid_array[i] <= 1'b0;
    	end 
    	else begin
        	if (curr_state == RD_DATA && axi.RVALID && axi.RLAST) begin
            	cache_valid_array [addr_index] <= 1'b1;
            	cache_tag_array   [addr_index] <= addr_tag;
            	cache_data_array  [addr_index] <= axi.RDATA;
        	end
    	end
	end

endmodule
