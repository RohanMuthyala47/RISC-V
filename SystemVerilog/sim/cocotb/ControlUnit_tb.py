import cocotb
from cocotb.triggers import Timer

# ALU Operations
# R-type and I-type
ALU_ADD   = 0
ALU_SUB   = 1
ALU_XOR   = 2
ALU_OR    = 3
ALU_AND   = 4
ALU_SLL   = 5
ALU_SRL   = 6
ALU_SRA   = 7
ALU_SLT   = 8
ALU_SLTU  = 9

# B-type
ALU_BEQ   = 10
ALU_BNE   = 11
ALU_BLT   = 12
ALU_BGE   = 13
ALU_BLTU  = 14
ALU_BGEU  = 15

# U-type
ALU_AUIPC = 16
ALU_LUI   = 17

# JAL and JALR
ALU_JAL   = 18
ALU_JALR  = 19

# Default
ALU_DEF   = 31

@cocotb.test()
async def test_control_unit(dut):
    """Test all ControlUnit instruction types"""

    test_vectors = [
        # opcode, funct3, funct7, MemRead, MemtoReg, MemWrite, ALU_Src, RegWrite, ALU_Op
        (0b0110011, 0b000, 0b0000000, 0,0,0,0,1, ALU_ADD),
        (0b0110011, 0b000, 0b0100000, 0,0,0,0,1, ALU_SUB),
        (0b0110011, 0b100, 0b0000000, 0,0,0,0,1, ALU_XOR),
        (0b0110011, 0b110, 0b0000000, 0,0,0,0,1, ALU_OR),
        (0b0110011, 0b111, 0b0000000, 0,0,0,0,1, ALU_AND),
        (0b0110011, 0b001, 0b0000000, 0,0,0,0,1, ALU_SLL),
        (0b0110011, 0b101, 0b0000000, 0,0,0,0,1, ALU_SRL),
        (0b0110011, 0b101, 0b0100000, 0,0,0,0,1, ALU_SRA),
        (0b0110011, 0b010, 0b0000000, 0,0,0,0,1, ALU_SLT),
        (0b0110011, 0b011, 0b0000000, 0,0,0,0,1, ALU_SLTU),
        (0b0010011, 0b000, 0b0000000, 0,0,0,1,1, ALU_ADD),
        (0b0010011, 0b100, 0b0000000, 0,0,0,1,1, ALU_XOR),
        (0b0010011, 0b110, 0b0000000, 0,0,0,1,1, ALU_OR),
        (0b0010011, 0b111, 0b0000000, 0,0,0,1,1, ALU_AND),
        (0b0010011, 0b001, 0b0000000, 0,0,0,1,1, ALU_SLL),
        (0b0010011, 0b101, 0b0000000, 0,0,0,1,1, ALU_SRL),
        (0b0010011, 0b101, 0b0100000, 0,0,0,1,1, ALU_SRA),
        (0b0010011, 0b010, 0b0000000, 0,0,0,1,1, ALU_SLT),
        (0b0010011, 0b011, 0b0000000, 0,0,0,1,1, ALU_SLTU),
        (0b0000011, 0b000, 0b0000000, 1,1,0,1,1, ALU_ADD),
        (0b0100011, 0b000, 0b0000000, 0,0,1,1,0, ALU_ADD),
        (0b1100011, 0b000, 0b0000000, 0,0,0,1,0, ALU_BEQ),
        (0b1100011, 0b001, 0b0000000, 0,0,0,1,0, ALU_BNE),
        (0b1100011, 0b100, 0b0000000, 0,0,0,1,0, ALU_BLT),
        (0b1100011, 0b101, 0b0000000, 0,0,0,1,0, ALU_BGE),
        (0b1100011, 0b110, 0b0000000, 0,0,0,1,0, ALU_BLTU),
        (0b1100011, 0b111, 0b0000000, 0,0,0,1,0, ALU_BGEU),
        (0b1101111, 0b000, 0b0000000, 0,0,0,1,1, ALU_JAL),
        (0b1100111, 0b000, 0b0000000, 0,0,0,1,1, ALU_JALR),
        (0b0010111, 0b000, 0b0000000, 0,0,0,1,1, ALU_AUIPC),
        (0b0110111, 0b000, 0b0000000, 0,0,0,1,1, ALU_LUI),
        (0b1111111, 0b000, 0b0000000, 0,0,0,0,0, ALU_DEF),
    ]

    for vec in test_vectors:
        opcode, funct3, funct7, MemRead, MemtoReg, MemWrite, ALU_Src, RegWrite, ALU_Op = vec
        dut.opcode.value = opcode
        dut.funct3.value = funct3
        dut.funct7.value = funct7

        await Timer(1, unit="ns")

        assert dut.MemRead.value == MemRead, f"MemRead mismatch for opcode={opcode:07b}"
        assert dut.MemtoReg.value == MemtoReg, f"MemtoReg mismatch for opcode={opcode:07b}"
        assert dut.MemWrite.value == MemWrite, f"MemWrite mismatch for opcode={opcode:07b}"
        assert dut.ALU_Src.value == ALU_Src, f"ALU_Src mismatch for opcode={opcode:07b}"
        assert dut.RegWrite.value == RegWrite, f"RegWrite mismatch for opcode={opcode:07b}"
        assert dut.ALU_Op.value == ALU_Op, f"ALU_Op mismatch for opcode={opcode:07b}"

        dut._log.info(f"Test passed for opcode={opcode:07b}, funct3={funct3:03b}, funct7={funct7:07b}")
