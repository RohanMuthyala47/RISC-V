import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random
import numpy as np

#module RegisterFile (
#    input logic clk,
#    input logic rst,
    
#    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] read_address1,
#    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] read_address2,
        
#    input logic [$clog2(REGISTER_FILE_SIZE) - 1:0] write_address,
#    input logic [DATA_WIDTH - 1:0] data,
#    input logic write_enable,
    
#    output logic [DATA_WIDTH - 1:0] read_data1,
#    output logic [DATA_WIDTH - 1:0] read_data2
#    );

@cocotb.test()
async def regfile_test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await RisingEdge(dut.clk)

    dut.rst.value = 1
    dut.read_address1.value = 0
    dut.read_address2.value = 0
    dut.write_address.value = 0
    dut.data.value = 0
    dut.write_enable.value = 0

    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    ref_regfile = [0 for i in range(32)]

    for _ in range(1000):
        read_addr1 = random.randint(1,31)
        read_addr2 = random.randint(1,31)
        write_addr = random.randint(1,31)
        data = random.randint(0,0xFFFFFFFF)

        # read
        await Timer(1, unit="ns")
        dut.read_address1.value = read_addr1
        dut.read_address2.value = read_addr2
        await Timer(1, unit="ns")
        assert dut.read_data1.value == ref_regfile[read_addr1]
        assert dut.read_data2.value == ref_regfile[read_addr2]

        # write
        dut.write_address = write_addr
        dut.write_enable = 1
        dut.data.value = data
        await RisingEdge(dut.clk)
        dut.write_enable = 0
        ref_regfile[write_addr] = data
        await Timer(1, unit="ns")

    await Timer(1, unit="ns")
    dut.write_address.value = 0
    dut.write_enable.value = 1
    dut.data = 0x47474747
    await RisingEdge(dut.clk)
    dut.write_enable.value = 0
    ref_regfile[write_addr] = 0

    await Timer(1, unit="ns")
    dut.read_address1.value = 0
    await Timer(1, unit="ns")
    print(dut.read_data1.value)
    assert int(dut.read_data1.value) == 0

    print("Test completed")
