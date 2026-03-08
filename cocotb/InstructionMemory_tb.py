import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_instruction_memory(dut):
    """Basic test for InstructionMemory"""

    # Reset 
    dut.rst.value = 1
    await Timer(10, unit="ns")
    dut.rst.value = 0
    await Timer(10, unit="ns")

    for addr in range(60):
        dut.pc.value = addr
        await Timer(1, unit="ns")
        instr = dut.instruction.value.to_unsigned()
        print(f"PC={addr} Instruction=0x{instr:08x}")
