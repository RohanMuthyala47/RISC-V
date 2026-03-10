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

    for i in range(15):
        print(f"///////////////////////////////////////////////////////////////////////////////////////////")
        print(f"CYCLE {i}")
        print(f"///////////////////////////////////////////////////////////////////////////////////////////")
        pc_if = int(dut.PC_IF.value)
        instr_if = int(dut.Instruction_IF.value)
        print(f"PC_IF value (cycle {i}) : 0x{pc_if:02x} -> Instruction_IF = 0x{instr_if:08x}\n\n")

        await RisingEdge(dut.clk)
      
    for i in range(200):
        dmem_val = int(dut.dmem_inst.DataMemory[i].value.to_signed())
        print(f"DataMemory[0x{(i):02x}] value : 0x{dmem_val:08x}  ({dut.dmem_inst.DataMemory[i].value.to_signed()})")


    for i in range(32):
        rf_val = int(dut.regfile_inst.RegisterFile[i].value.to_signed())
        print(f"x{i} value : 0x{rf_val:08x} ({dut.regfile_inst.RegisterFile[i].value.to_signed()})")


    print("Test Completed")
