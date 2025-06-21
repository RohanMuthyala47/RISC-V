module DataMemory (
    input  logic        clk,
    input  logic        rst,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic [2:0]  funct3,
    
    output logic [31:0] read_data
);

    parameter Memory_Depth = 1024;

    logic [31:0] DataMemory[0:Memory_Depth - 1];
    
    logic [$clog2(Memory_Depth) - 1:0] word_addr;
    assign word_addr = address[$clog2(Memory_Depth) + 1:2];
    
    initial begin
        for (int i = 0; i < Memory_Depth; i++) begin
            DataMemory[i] = 32'h0;
        end
    end
    
    // Write logic
    always_ff @(posedge clk) begin
        if (MemWrite && word_addr < Memory_Depth) begin
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
                3'b010: // SW (store word)
                    DataMemory[word_addr] <= write_data;
                default:
                    DataMemory[word_addr] <= write_data;
            endcase
        end
    end
    
    // Read logic
    always_comb begin
        if (MemRead && word_addr < Memory_Depth) begin
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
                3'b010: // LW (load word)
                    read_data = DataMemory[word_addr];
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
                default:
                    read_data = DataMemory[word_addr];
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
    
endmodule