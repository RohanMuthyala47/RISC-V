import cpu_pkg::*;

module DataMemory (
    input  logic                    clk,
    input  logic                    rst,
    
    input  logic [2:0]              funct3,
    
    input  logic                    MemRead,
    input  logic                    MemWrite,
    
    input  logic [ADDR_WIDTH - 1:0] address,
    input  logic [DATA_WIDTH - 1:0] write_data,
    
    output logic [DATA_WIDTH - 1:0] read_data
);

    /* verilator lint_off WIDTHEXPAND */

    // Data Memory declaration
    logic [DATA_WIDTH - 1:0] DataMemory [0:MEM_DEPTH - 1];

    logic [MEM_ADDR_WIDTH - 1:0] word_addr;
    assign word_addr = address[MEM_ADDR_WIDTH + 1:2];
    
    always_ff @(posedge clk) begin
    	if(rst) begin
            for (int i = 0; i < MEM_DEPTH; i++) begin
            	DataMemory[i] = DATA_WIDTH'(0);
            end
        end
    end
    
    // Write logic
    always_ff @(posedge clk) begin
        if (MemWrite && word_addr < MEM_DEPTH) begin
            case (funct3)
                3'b000: begin // SB (store byte)
                    case (address[1:0])
                        2'b00: DataMemory[word_addr][7:0]   <= write_data[7:0];
                        2'b01: DataMemory[word_addr][15:8]  <= write_data[7:0];
                        2'b10: DataMemory[word_addr][23:16] <= write_data[7:0];
                        2'b11: DataMemory[word_addr][31:24] <= write_data[7:0];
                    endcase
                end
                
                3'b001: begin // SH (store halfword)
                    case (address[1])
                        1'b0: DataMemory[word_addr][15:0]  <= write_data[15:0];
                        1'b1: DataMemory[word_addr][31:16] <= write_data[15:0];
                    endcase
                end
                
                3'b010: DataMemory[word_addr] <= write_data; // SW (store word)
                    
                default: ;
            endcase
        end
    end
    
    // Read logic
    always_comb begin
        if (MemRead && word_addr < MEM_DEPTH) begin
            case (funct3)
                3'b000: begin // LB (load byte, sign-extended)
                    case (address[1:0])
                        2'b00: read_data = {{24{DataMemory[word_addr][7]}},  DataMemory[word_addr][7:0]};
                        2'b01: read_data = {{24{DataMemory[word_addr][15]}}, DataMemory[word_addr][15:8]};
                        2'b10: read_data = {{24{DataMemory[word_addr][23]}}, DataMemory[word_addr][23:16]};
                        2'b11: read_data = {{24{DataMemory[word_addr][31]}}, DataMemory[word_addr][31:24]};
                    endcase
                end
                
                3'b001: begin // LH (load halfword, sign-extended)
                    case (address[1])
                        1'b0: read_data = {{16{DataMemory[word_addr][15]}}, DataMemory[word_addr][15:0]};
                        1'b1: read_data = {{16{DataMemory[word_addr][31]}}, DataMemory[word_addr][31:16]};
                    endcase
                end
                
                3'b010: read_data = DataMemory[word_addr]; // LW (load word)
                    
                3'b100: begin // LBU (load byte unsigned)
                    case (address[1:0])
                        2'b00: read_data = {24'b0, DataMemory[word_addr][7:0]};
                        2'b01: read_data = {24'b0, DataMemory[word_addr][15:8]};
                        2'b10: read_data = {24'b0, DataMemory[word_addr][23:16]};
                        2'b11: read_data = {24'b0, DataMemory[word_addr][31:24]};
                    endcase
                end
                
                3'b101: begin // LHU (load halfword unsigned)
                    case (address[1])
                        1'b0: read_data = {16'b0, DataMemory[word_addr][15:0]};
                        1'b1: read_data = {16'b0, DataMemory[word_addr][31:16]};
                    endcase
                end
                
                default: ;
            endcase
        end 
        else begin
            read_data = DATA_WIDTH'(0);
        end
    end
    
endmodule
