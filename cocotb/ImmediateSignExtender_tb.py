import cocotb
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def sign_extender_test(dut):
    dut.instruction.value = 0

    await Timer(5, unit="ns")

    # RV32I instructions in hex format
    instructions = [
        0x00100093, 0x00200113, 0x00300193, 0x00400213, 0x00500293,
        0x00600313, 0x00700393, 0x00800413, 0x00900493, 0x00A00513,
        0x002085B3, 0x40328633, 0x0033C6B3, 0x0033E733, 0x0033F7B3,
        0x00111833, 0x001458B3, 0x401C5933, 0x0020A9B3, 0x00113A33,
        0xFFD28A93, 0x0033CB13, 0x0013EB93, 0x0033FC13, 0x0050AC93,
        0x0000BD13, 0x00211D93, 0x00145E13, 0xFF800E93, 0x402EDF13,
        0x00001FB7, 0x00001097, 0x04000113,
        0x00312023, 0x00412223, 0x00510423, 0x00610523,
        0x00012383, 0x00412403, 0x00810483, 0x00810503,
        0x00A10583, 0x00A10603,
        0x00108463, 0x00000013, 0x00209463, 0x00000013,
        0x0020C463, 0x00000013, 0x00115463, 0x00000013,
        0x0020E463, 0x00000013, 0x00117463, 0x00000013,
        0x00168693, 0x00170713, 0x00178793, 0x00180813,
        0x00188893, 0x00190913,
        0x01C002EF, 0x00000013, 0x00028367,
        0x00198993, 0xFF000A13, 0x403A5A93,
        0x0000006F, 0xFEDFF06F
    ]

    # Corresponding sign-extended immediates
    immediates = [
         1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        -3, 3, 1, 3, 5,
         0, 2, 1, -8, 1026,
         0x00001000, 0x00001000, 64,
         0, 4, 8, 10,
         0, 4, 8, 8,
         10, 10,
         8, 0, 8, 0,
         8, 0, 8, 0,
         8, 0, 8, 0,
         1, 1, 1, 1, 1, 1,
         28, 0, 0,
         1, -16, 1027,
         0, -20
    ]

    for i in range(len(instructions)):
        dut.instruction.value = instructions[i]
        await Timer(5, unit="ns")

        imm = int(dut.immediate.value)

        expected = immediates[i] & oxFFFFFFFF
        assert dut.immediate.value == expected, (f"Mismatch at index {i}:"
                                                 f"instr = 0x{instructions[i]:08X}, "
                                                 f"expected = 0x(expected:08X}, "
                                                 f"got=0x{imm:08X}"
                                                 )  

    print("Test completed")
