import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def cpu_test(dut):
    cocotb.start_soon(Clock(dut.clk, 5, unit="ns").start())

    # reset
    dut.rst.value = 1

    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    expected_register_values = [0, 4220, 64, 3, 4, 248, 256, 3,
                                4, 5, 5, 6, 6, 5, 8, 4,
                                5, 5, 1, 1, 0, 2, 4, 7,
                                3, 1, 0, 8, 4, 0xfffffff8, 0xfffffffe, 4096]

    await Timer(1000, unit="ns")

    for i in range(32):
        assert dut.RegisterFile.RegisterFile[i].value == expected_register_values[i], (f"Mismatch at Resgister {i}:"
                                                                                       f"expected = {expected_register_values[i]}, "
                                                                                       f"got={dut.RegisterFile.RegisterFile[i].value}"
                                                                                      )

    print("Test Completed")
