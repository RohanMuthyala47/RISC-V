import cpu_pkg::*;

module DataCache (
    input  logic                    clk,
    input  logic                    rst,
    
    input  logic [2:0]              funct3,
    
    input  logic                    MemRead,
    input  logic                    MemWrite,
    
    input  logic [ADDR_WIDTH - 1:0] address,
    input  logic [DATA_WIDTH - 1:0] write_data,
    
    output logic [DATA_WIDTH - 1:0] read_data,
    
    output logic                    stall,
	
	AXI_if.master                   axi
);
	
	// Cache Memory declaration
	logic                        cache_valid_array [0:CACHE_LINES - 1]; // Cache valid bits
	logic                        cache_dirty_array [0:CACHE_LINES - 1]; // Cache dirty bits
	logic [CACHE_TAG_BITS - 1:0] cache_tag_array   [0:CACHE_LINES - 1]; // Tag array
	logic [DATA_WIDTH - 1:0]     cache_data_array  [0:CACHE_LINES - 1]; // Data array
	
	logic [CACHE_TAG_BITS - 1:0]    addr_tag;
	logic [CACHE_INDEX_BITS - 1:0]  addr_index;
	logic [CACHE_OFFSET_BITS - 1:0] addr_offset;
	
	assign addr_tag    = address[ADDR_WIDTH - 1:CACHE_INDEX_BITS + CACHE_OFFSET_BITS];
	assign addr_index  = address[CACHE_INDEX_BITS + CACHE_OFFSET_BITS - 1:CACHE_OFFSET_BITS];
	assign addr_offset = address[CACHE_OFFSET_BITS - 1:0];
	
	logic                        cache_line_valid;
	logic                        cache_line_dirty;
	logic [CACHE_TAG_BITS - 1:0] cache_line_tag;
	logic [DATA_WIDTH - 1:0]     cache_line_data;
	
	assign cache_line_valid = cache_valid_array[addr_index];
	assign cache_line_dirty = cache_dirty_array[addr_index];
	assign cache_line_tag   = cache_tag_array  [addr_index];
	assign cache_line_data  = cache_data_array [addr_index];
	
	logic  hit;
	assign hit = cache_line_valid && (cache_line_tag == addr_tag);
	
	dcache_state_t curr_state, next_state;
	
	always_ff @(posedge clk) begin
	    if(rst)
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end
	
	logic [DATA_WIDTH - 1:0] mem_read_data;
	logic [DATA_WIDTH - 1:0] load_read_data;
	
	always_comb begin
		case(funct3)
			3'b000:  load_read_data = {{24{mem_read_data[7]}},  mem_read_data[7:0]};  // LB
			
            3'b001:  load_read_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]}; // LH
            
            3'b010:  load_read_data = mem_read_data;                                  // LW
            
            3'b100:  load_read_data = {24'b0, mem_read_data[7:0]};                    // LBU
            
            3'b101:  load_read_data = {16'b0, mem_read_data[15:0]};                   // LHU
            
            default: load_read_data = mem_read_data;
		endcase
	end
	
	assign read_data = MemRead ? load_read_data : DATA_WIDTH'(0);
	
	always_comb begin
        next_state = curr_state;

    	case (curr_state)
            IDLE:        next_state = (MemRead || MemWrite) ? CHECK : IDLE;

        	CHECK: begin
        		if(hit)
        			     next_state = (MemRead || MemWrite) ? CHECK : IDLE;
        		else
        			     next_state = cache_line_dirty ? WR_REQ : RD_REQ;
        	end
        	
        	WR_REQ:      next_state = axi.AWREADY ? WR_DATA : WR_REQ;
        	
        	WR_DATA:     next_state = (axi.WLAST && axi.WREADY) ? WR_RESP : WR_DATA;
        	
        	WR_RESP:     next_state = (axi.BRESP == 2'b00) ? RD_REQ : WR_REQ;

        	RD_REQ:      next_state = axi.ARREADY ? RD_DATA : RD_REQ;

        	RD_DATA:     next_state = (axi.RLAST && axi.RVALID) ? RD_COMPLETE : RD_DATA;

        	RD_COMPLETE: next_state = (MemWrite || MemRead) ? CHECK : IDLE;

        	default:     next_state = IDLE;
        	
    	endcase
	end
	
	always_comb begin
    	stall       = 1'b0;
    	mem_read_data = DATA_WIDTH'(0);
    	
    	// AXI WRITE ADDRESS CHANNEL
    	axi.AWVALID = 1'b0;
        axi.AWADDR  = ADDR_WIDTH'(0);
        axi.AWLEN   = 8'd0;   // single transaction
        axi.AWSIZE  = 3'b010; // 4 bytes per transaction
        axi.AWBURST = 2'b01;  // INCR
        
        // AXI WRITE DATA CHANNEL
        axi.WVALID  = 1'b0;
        axi.WDATA   = DATA_WIDTH'(0);
        axi.WSTRB   = 4'b1111;
        axi.WLAST   = 1'b0;
        
        // AXI WRITE RESPONSE CHANNEL
        axi.BREADY  = 1'b0;

    	// AXI READ ADDRESS CHANNEL
    	axi.ARVALID = 1'b0;
    	axi.ARADDR  = ADDR_WIDTH'(0);
    	axi.ARLEN   = 8'd0;   // single-beat burst
    	axi.ARSIZE  = 3'b010; // 4 bytes per beat
    	axi.ARBURST = 2'b01;  // INCR
    	
    	// AXI READ DATA CHANNEL
    	axi.RREADY  = 1'b0;

    	case (curr_state)
        	IDLE: stall = 1'b0;

        	CHECK: begin
            	if (hit) begin
                	stall         = 1'b0;
                	mem_read_data = cache_line_data;
            	end 
            	else begin
                	stall = 1'b1;
            	end
        	end
        	
        	WR_REQ: begin
        		stall       = 1'b1;
        		axi.AWVALID = 1'b1;
        		axi.AWADDR  = {cache_line_tag, addr_index, {CACHE_OFFSET_BITS{1'b0}}};
        	end
        	
        	WR_DATA: begin
        		stall      = 1'b1;
        		axi.WDATA  = cache_line_data;
        		axi.WVALID = 1'b1;
        		axi.WLAST  = 1'b1;
        	end
        	
        	WR_RESP: begin
        		stall      = 1'b1;
        		axi.BREADY = 1'b1;
        	end

        	RD_REQ: begin
            	stall       = 1'b1;
            	axi.ARVALID = 1'b1;
            	axi.ARADDR  = {addr_tag, addr_index, CACHE_OFFSET_BITS'(0)};
        	end

        	RD_DATA: begin
            	stall      = 1'b1;
            	axi.RREADY = 1'b1;
        	end

        	RD_COMPLETE: begin
            	stall         = 1'b0;
            	mem_read_data = cache_line_data;
        	end

        	default: ;
        	
    	endcase
	end
	
	always_ff @(posedge clk) begin
    	if (rst) begin
            for (int i = 0; i < CACHE_LINES; i = i + 1) begin
                cache_valid_array[i] <= 1'b0;
                cache_dirty_array[i] <= 1'b0;
            end
        end
    
        else if (curr_state == CHECK && hit && MemWrite) begin
            case (funct3)
                3'b000: begin // SB
                    case (address[1:0])
                        2'b00: cache_data_array[addr_index][7:0]   <= write_data[7:0];
                        2'b01: cache_data_array[addr_index][15:8]  <= write_data[7:0];
                        2'b10: cache_data_array[addr_index][23:16] <= write_data[7:0];
                        2'b11: cache_data_array[addr_index][31:24] <= write_data[7:0];
                    endcase
                end
                
                3'b001: begin // SH
                    case (address[1])
                        1'b0: cache_data_array[addr_index][15:0]  <= write_data[15:0];
                        1'b1: cache_data_array[addr_index][31:16] <= write_data[15:0];
                    endcase
                end
                
                3'b010: cache_data_array[addr_index] <= write_data; // SW
                    
                default: ;
            endcase
            
            cache_dirty_array [addr_index] <= 1'b1;
        end
    
    	else if (curr_state == RD_DATA && axi.RVALID && axi.RLAST) begin
            cache_valid_array [addr_index] <= 1'b1;
            cache_dirty_array [addr_index] <= 1'b0;
            cache_tag_array   [addr_index] <= addr_tag;
            cache_data_array  [addr_index] <= axi.RDATA;
    	end
    
    	else if (curr_state == RD_COMPLETE && MemWrite) begin
            case (funct3)
                3'b000: begin // SB
                    case (address[1:0])
                        2'b00: cache_data_array[addr_index][7:0]   <= write_data[7:0];
                        2'b01: cache_data_array[addr_index][15:8]  <= write_data[7:0];
                        2'b10: cache_data_array[addr_index][23:16] <= write_data[7:0];
                        2'b11: cache_data_array[addr_index][31:24] <= write_data[7:0];
                    endcase
                end
                
                3'b001: begin // SH
                    case (address[1])
                        1'b0: cache_data_array[addr_index][15:0]  <= write_data[15:0];
                        1'b1: cache_data_array[addr_index][31:16] <= write_data[15:0];
                    endcase
                end
                
                3'b010: cache_data_array[addr_index] <= write_data; // SW
                    
                default: ;
            endcase
        
            cache_dirty_array [addr_index] <= 1'b1;
        end
        
        else if (curr_state == WR_RESP && axi.BVALID && axi.BRESP == 2'b00) begin
            cache_dirty_array [addr_index] <= 1'b0;
        end
	end

endmodule
