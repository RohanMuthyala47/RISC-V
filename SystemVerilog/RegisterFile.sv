module RegisterFile(
    input logic clk,
    input logic rst,
    
    input logic [4:0] read_address1,
    input logic [4:0] read_address2,
    
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    
    input logic [4:0] wr_address,
    input logic [31:0] data,
    input logic write_enable
    );
    
    reg [31:0] RegisterFile [0:31];
    integer i;
    
    always @(posedge clk)
    begin
        if(!rst)
        begin
            for(i = 0;i < 32; i = i + 1)
                RegisterFile[i] <= 'b0;
        end
        
        else if(write_enable && wr_address != 0)
        begin
            RegisterFile[wr_address] <= data;
        end
    end
    
    always_comb begin
        read_data1 = RegisterFile[read_address1];
        read_data2 = RegisterFile[read_address2];
    end
endmodule
