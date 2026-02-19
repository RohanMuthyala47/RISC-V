#DataMemory_tb.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def data_memory_test(dut):

    cocotb.start_soon(Clock(dut.clk, 5, unit="ns").start())

    # Reset
    dut.rst.value = 1
    dut.MemRead.value = 0
    dut.MemWrite.value = 0
    dut.address.value = 0
    dut.write_data.value = 0
    dut.funct3.value = 0b010  # SW

    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    # Enable reading
    dut.MemRead.value = 1

    # Verify memory cleared
    for addr in range(0, 16, 4):
        dut.address.value = addr
        await Timer(1, unit="ns")
        assert dut.read_data.value.integer == 0

    # Test writes
    test_vector = [
        (0,  0x12345678),
        (4,  0x9ABCDEF0),
        (8,  0x44447777),
        (12, 0xA5A5A5A5),
    ]

    dut.MemRead.value = 0
    dut.funct3.value = 0b010  # SW

    for addr, data in test_vector:
        dut.address.value = addr
        dut.write_data.value = data
        dut.MemWrite.value = 1
        await RisingEdge(dut.clk)
        dut.MemWrite.value = 0

    # Read back and verify
    dut.MemRead.value = 1

    for addr, expected in test_vector:
        dut.address.value = addr
        await Timer(1, unit="ns")
        assert dut.read_data.value.integer == expected, \
            f"Read {hex(dut.read_data.value.integer)} expected {hex(expected)}"

