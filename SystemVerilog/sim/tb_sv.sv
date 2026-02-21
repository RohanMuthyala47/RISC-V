`timescale 1ns / 1ps
module CPU_TestBench;

    reg clk;
    reg rst;

    CPU dut(clk, rst);

    always #5 clk = ~clk;

    initial begin
        $display("CPU Simulation Results: ");

        clk = 0;
        rst = 1;
        #20;
        rst = 0;

        repeat (200) @(posedge clk);
        
        $display("x0  = %0d", CPU.RegisterFile.RegisterFile[0]);
        $display("x1  = %0d", CPU.RegisterFile.RegisterFile[1]);
        $display("x2  = %0d", CPU.RegisterFile.RegisterFile[2]);
        $display("x3  = %0d", CPU.RegisterFile.RegisterFile[3]);
        $display("x4  = %0d", CPU.RegisterFile.RegisterFile[4]);
        $display("x5  = %0d", CPU.RegisterFile.RegisterFile[5]);
        $display("x6  = %0d", CPU.RegisterFile.RegisterFile[6]);
        $display("x7  = %0d", CPU.RegisterFile.RegisterFile[7]);
        $display("x8  = %0d", CPU.RegisterFile.RegisterFile[8]);
        $display("x9  = %0d", CPU.RegisterFile.RegisterFile[9]);
        $display("x10 = %0d", CPU.RegisterFile.RegisterFile[10]);
        $display("x11 = %0d", CPU.RegisterFile.RegisterFile[11]);
        $display("x12 = %0d", CPU.RegisterFile.RegisterFile[12]);
        $display("x13 = %0d", CPU.RegisterFile.RegisterFile[13]);
        $display("x14 = %0d", CPU.RegisterFile.RegisterFile[14]);
        $display("x15 = %0d", CPU.RegisterFile.RegisterFile[15]);
        $display("x16 = %0d", CPU.RegisterFile.RegisterFile[16]);
        $display("x17 = %0d", CPU.RegisterFile.RegisterFile[17]);
        $display("x18 = %0d", CPU.RegisterFile.RegisterFile[18]);
        $display("x19 = %0d", CPU.RegisterFile.RegisterFile[19]);
        $display("x20 = %0d", CPU.RegisterFile.RegisterFile[20]);
        $display("x21 = %0d", CPU.RegisterFile.RegisterFile[21]);
        $display("x22 = %0d", CPU.RegisterFile.RegisterFile[22]);
        $display("x23 = %0d", CPU.RegisterFile.RegisterFile[23]);
        $display("x24 = %0d", CPU.RegisterFile.RegisterFile[24]);
        $display("x25 = %0d", CPU.RegisterFile.RegisterFile[25]);
        $display("x26 = %0d", CPU.RegisterFile.RegisterFile[26]);
        $display("x27 = %0d", CPU.RegisterFile.RegisterFile[27]);
        $display("x28 = %0d", CPU.RegisterFile.RegisterFile[28]);
        $display("x29 = %0d", CPU.RegisterFile.RegisterFile[29]);
        $display("x30 = %0d", CPU.RegisterFile.RegisterFile[30]);
        $display("x31 = %0d", CPU.RegisterFile.RegisterFile[31]);

        $finish;
    end
    
    reg [31:0] last_pc;

    initial last_pc = 32'hFFFFFFFF;

    always @(posedge clk) begin
        if (!rst && CPU.pc !== last_pc) begin
            $display("Time %0t | PC = 0x%08h (%0d) | INSTR=0x%08h", $time, CPU.pc, CPU.pc, CPU.instruction);
            last_pc <= CPU.pc;
        end
    end

endmodule
