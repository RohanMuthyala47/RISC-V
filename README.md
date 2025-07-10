# RISC-V
Design of a RISC V CPU core.

References:

https://learning.edx.org/course/course-v1:LinuxFoundationX+LFD111x+1T2024/home

https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core


RISC V CPU Architecture: 


![image](https://github.com/user-attachments/assets/06c1fcff-929a-411b-a37b-b8da5fcc02e1)


![image](https://github.com/user-attachments/assets/e83e5379-076f-4a0b-b7ae-b6c68489d35f)

RISC-V Implements a 5 stage pipeline (Instruction Fetch, Instruction Decode, Execute, Memory Access, Write Back).

The components in/processes of a RISC-V CPU Core include : 

# PC Logic:

This logic is responsible for the program counter (PC). The PC identifies the instruction our CPU will execute next. Most instructions execute sequentially, meaning the default behavior of the PC is to increment to the following instruction each clock cycle. Branch and jump instructions, however, are non-sequential. They specify a target instruction to execute next, and the PC logic must update the PC accordingly.

The PC is a byte address, meaning it references the first byte of an instruction in the IMem. Instructions are 4 bytes long, so, although the PC increment is depicted as "+1" (instruction), the actual increment must be by 4 (bytes). The lowest two PC bits must always be zero in normal operation.
Instruction fetching should start from address zero, so the first **$pc** value with $reset deasserted should be zero, as is implemented in the logic diagram below.
Unlike our earlier counter circuit, for readability, we use unique names for **$pc** and **$next_pc**, by assigning **$pc** to the previous **$next_pc**.
 

# Fetch: 

The instruction memory (IMem) holds the instructions to execute. To read the IMem, or "fetch", we simply pull out the instruction pointed to by the PC.

# Decode Logic: 


![image](https://github.com/user-attachments/assets/a43ad678-0ebb-42f2-8721-564b1e95f25e)

![image](https://github.com/user-attachments/assets/bfda98b0-d586-4352-a7dc-f9096fa9ccb3)

**Calculation of Immediate Value based on specific instructions :**


| Instruction Type | Immediate Field Bits                         | Expression Format | Used for                  |
| ---------------- | -------------------------------------------- | ----------------- | ------------------------- |
| I-type           | `{ {21{[31]} }, [30:20] }`                   |  sign_extend(11)  | Immediate Arithmetic/Load |
| S-type           | `{ {21{[31]} }, [30:25], [11:7] }`           |  sign_extend(12)  | Store                     |
| B-type           | `{ {20{[31]} }, [7], [30:25], [11:8], 0 }`   |  sign_extend(13)  | Branch                    |
| U-type           | `{ [31:12], 12'b0 }`                         | No sign-extension | Upper Immediate           |
| J-type           | `{ {12{[31]} }, [19:12], [20], [30:21], 0 }` |  sign_extend(21)  | Jump                      |


The specific instruction is determined from the **opcode**, **instr[30]**, and **funct3** fields as follows:

 ![image](https://github.com/user-attachments/assets/7df419f0-c835-485b-b4b7-e6fc9d9b23e6)


# Register File Read: 

The register file is a small local storage of values the program is actively working with. The instruction determines which registers we need to operate on. Those registers are read from the register file.

![image](https://github.com/user-attachments/assets/deac098b-a4a5-419c-8b32-18476a2bf513)


# Arithmetic Logic Unit (ALU): 


**R-type ALU Instructions :**

| Instruction | Mnemonic            | Operation                | ALU Function               |
| ----------- | ------------------- | ------------------------ | -------------------------- |
| `ADD`       | `add rd, rs1, rs2`  | Add                      | `rd = rs1 + rs2`           |
| `SUB`       | `sub rd, rs1, rs2`  | Subtract                 | `rd = rs1 - rs2`           |
| `SLL`       | `sll rd, rs1, rs2`  | Shift Left Logical       | `rd = rs1 << rs2[4:0]`     |
| `SLT`       | `slt rd, rs1, rs2`  | Set Less Than (signed)   | `rd = (rs1 < rs2) ? 1 : 0` |
| `SLTU`      | `sltu rd, rs1, rs2` | Set Less Than (unsigned) | `rd = (rs1 < rs2) ? 1 : 0` |
| `XOR`       | `xor rd, rs1, rs2`  | Bitwise XOR              | `rd = rs1 ^ rs2`           |
| `SRL`       | `srl rd, rs1, rs2`  | Shift Right Logical      | `rd = rs1 >> rs2[4:0]`     |
| `SRA`       | `sra rd, rs1, rs2`  | Shift Right Arithmetic   | `rd = rs1 >>> rs2[4:0]`    |
| `OR`        | `or rd, rs1, rs2`   | Bitwise OR               | `rd = rs1 \| rs2`          |
| `AND`       | `and rd, rs1, rs2`  | Bitwise AND              | `rd = rs1 & rs2`           |


**I-type ALU Instructions :**

| Instruction | Mnemonic              | Operation                          | ALU Function               |
| ----------- | --------------------- | ---------------------------------- | -------------------------- |
| `ADDI`      | `addi rd, rs1, imm`   | Add Immediate                      | `rd = rs1 + imm`           |
| `SLTI`      | `slti rd, rs1, imm`   | Set Less Than Immediate (signed)   | `rd = (rs1 < imm) ? 1 : 0` |
| `SLTIU`     | `sltiu rd, rs1, imm`  | Set Less Than Immediate (unsigned) | `rd = (rs1 < imm) ? 1 : 0` |
| `XORI`      | `xori rd, rs1, imm`   | Bitwise XOR Immediate              | `rd = rs1 ^ imm`           |
| `ORI`       | `ori rd, rs1, imm`    | Bitwise OR Immediate               | `rd = rs1 \| imm`          |
| `ANDI`      | `andi rd, rs1, imm`   | Bitwise AND Immediate              | `rd = rs1 & imm`           |
| `SLLI`      | `slli rd, rs1, shamt` | Shift Left Logical Immediate       | `rd = rs1 << shamt`        |
| `SRLI`      | `srli rd, rs1, shamt` | Shift Right Logical Immediate      | `rd = rs1 >> shamt`        |
| `SRAI`      | `srai rd, rs1, shamt` | Shift Right Arithmetic Immediate   | `rd = rs1 >>> shamt`       |



# Register File Write: 

Now the result value from the ALU can be written back to the destination register specified in the instruction.

# Branching Logic: 

![image](https://github.com/user-attachments/assets/d09dd864-f6dc-476e-8726-a184850094b2)

BEQ - Branch if equal -	x1 == x2

BNE -	Branch if not equal -	x1 != x2

BLT -	Branch if less than -	(x1 < x2) ^ (x1[31] != x2[31])

BGE -	Branch if greater than or equal -	(x1 >= x2) ^ (x1[31] != x2[31])

BLTU -	Branch if less than, unsigned -	x1 < x2

BGEU -	Branch if greater than or equal - unsigned;	x1 >= x2


**Jump Instructions** : 
The ISA, in addition to conditional branches, also supports jump instructions (which some other ISAs refer to as "unconditional branches"). RISC-V has two forms of jump instructions:

**JAL**

Jump and link. Jumps to PC + IMM (like branches, so this target is $br_tgt_pc, already assigned).

**JALR**

Jump and link register. Jumps to SRC1 + IMM.
"And link" refers to the fact that these instructions capture their original PC + 4 in a destination register.


# Data Memory: 

![image](https://github.com/user-attachments/assets/182aec24-17d7-4e65-9a20-84cc575fee90)

The Data Memory is written to by store instructions and read from by load instructions.

Both load and store instructions require an address from which to read, or to which to write. As with the IMem, this is a byte-address. 
Loads and stores can read/write single bytes, half-words (2 bytes), or words (4 bytes/32 bits).

We will, however, avoid this nuance and implement all load/store instructions to operate on words, assuming that the lowest two address bits are zero. In other words, we are assuming work loads/stores with naturally-aligned addresses.

The address for loads/stores is computed based on the value from a source register and an offset value (often zero) provided as the immediate.

addr = rs1 + imm

----------
Load:
A load instruction (LW,LH,LB,LHU,LBU) takes the form:

LOAD rd, imm(rs1)

It uses the I-type instruction format:

![image](https://github.com/user-attachments/assets/c052533c-e229-44db-b699-d41cc2a3425b)

It writes its destination register with a value read from the specified address of memory, which we can denote as:

rd <= DMem[addr] (where, addr = rs1 + imm)

----------
Store:
A store instruction (SW,SH,SB) takes the form:

STORE rs2, imm(rs1)

It has its own S-type instruction format:

![image](https://github.com/user-attachments/assets/440906a8-d034-431f-9856-b772cd016817)


It writes the specified address of memory with a value from the rs2 source register:

DMem[addr] <= rs2 (where, addr = rs1 + imm)
