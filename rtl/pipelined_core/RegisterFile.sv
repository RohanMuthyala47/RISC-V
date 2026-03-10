import cpu_pkg::*;

module RegisterFile(
    input logic                         clk,
    input logic                         rst,
  
    input logic  [REG_ADDR_WIDTH - 1:0] write_address,
    input logic  [DATA_WIDTH - 1:0]     write_data,
    input logic                         write_enable,
    
    input logic  [REG_ADDR_WIDTH - 1:0] read_address1,
    input logic  [REG_ADDR_WIDTH - 1:0] read_address2,
    
    output logic [DATA_WIDTH - 1:0]     read_data1,
    output logic [DATA_WIDTH - 1:0]     read_data2
);
    
    // Register File declaration
    logic [DATA_WIDTH - 1:0] RegisterFile [0:REG_FILE_SIZE - 1];
    
    integer i;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < REG_FILE_SIZE; i = i + 1)
                RegisterFile[i] <= DATA_WIDTH'(0);
        end
	end
	
    always_ff @(posedge clk) begin 
        if(write_enable && (write_address != REG_ADDR_WIDTH'(0))) begin
            RegisterFile[write_address] <= write_data;
        end
    end
    
    always_comb begin
    	read_data1 = DATA_WIDTH'(0);
    	if(read_address1 != REG_ADDR_WIDTH'(0)) begin
    		if(read_address1 == write_address) begin
    			read_data1 = write_data;
    		end
    		else begin
    			read_data1 = RegisterFile[read_address1];
    		end
    	end
    end
	
	always_comb begin
    	read_data2 = DATA_WIDTH'(0);
    	if(read_address2 != REG_ADDR_WIDTH'(0)) begin
    		if(read_address2 == write_address) begin
    			read_data2 = write_data;
    		end
    		else begin
    			read_data2 = RegisterFile[read_address2];
    		end
    	end
    end

endmodule
