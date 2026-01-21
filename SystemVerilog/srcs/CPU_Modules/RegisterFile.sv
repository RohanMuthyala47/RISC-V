`include "parameters.vh"

module RegisterFile(
    input logic                                    clk,
    input logic                                    rst,
    
    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] read_address1,
    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] read_address2,
        
    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] write_address,
    input logic [DATA_WIDTH - 1:0]                 data,
    input logic                                    write_enable,
    
    output logic [DATA_WIDTH - 1:0]                read_data1,
    output logic [DATA_WIDTH - 1:0]                read_data2
    );
    
    logic [DATA_WIDTH - 1:0] RegisterFile [0:REGISTER_FILE_SIZE - 1];
    integer i;
    
    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            for(i = 0;i < REGISTER_FILE_SIZE; i = i + 1)
                RegisterFile[i] <= 'b0;
        end
        
        else if(write_enable && write_address != 0)
        begin
            RegisterFile[write_address] <= data;
        end
    end
    
    always_comb begin
        read_data1 = (read_address1 == 0) ? 'b0 : RegisterFile[read_address1];
        read_data2 = (read_address2 == 0) ? 'b0 : RegisterFile[read_address2];
    end

endmodule
