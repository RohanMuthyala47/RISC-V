import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.utils import get_sim_time

#module ProgramCounter (
#    input  logic                    clk,
#    input  logic                    rst,
#
#    input  logic                    branch_taken,
#    input  logic [ADDR_WIDTH - 1:0] branch_target,
#    
#    input  logic                    is_jal,
#    input  logic                    is_jalr,
#    input  logic [ADDR_WIDTH - 1:0] jal_target,
#    input  logic [ADDR_WIDTH - 1:0] jalr_target,
#    
#    output logic [ADDR_WIDTH - 1:0] pc
#);

@cocotb.test()
async def program_counter_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # reset

    dut.rst.value = 1
    dut.branch_taken.value = 0
    dut.branch_target.value = 0x00000000
    dut.is_jal.value = 0
    dut.is_jalr.value = 0
    dut.jal_target.value = 0x00000000
    dut.jalr_target.value = 0x00000000

    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # test normal operation (no branches and jumps)
    for _ in range(5):
        await RisingEdge(dut.clk)
        time = get_sim_time(unit="ns")
        print(f"Cycle {_} -> sim time = {time} ns -> PC : {hex(dut.pc.value.to_unsigned())}")
    
    dut.branch_taken.value = 1
    dut.branch_target.value = 0x47474747
    await Timer(1, unit="ns")
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"Cycle {5} -> sim time = {time} ns -> PC : {hex(dut.pc.value.to_unsigned())}")

    dut.branch_taken.value = 0
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"Cycle {6} -> sim time = {time} ns -> PC : {hex(dut.pc.value.to_unsigned())}")

    dut.branch_taken.value = 1
    dut.branch_target.value = 0x5a5a5a5a

    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"Cycle {7} -> sim time = {time} ns -> PC : {hex(dut.pc.value.to_unsigned())}")

    dut.branch_taken.value = 0
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"Cycle {8} -> sim time = {time} ns -> PC : {hex(dut.pc.value.to_unsigned())}")
    
    print("Test completed")
