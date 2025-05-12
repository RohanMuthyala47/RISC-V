# RISC-V-CPU-Design
Design of a RISC V CPU core, implementing all the necessary components and pipelining

I have started this project by enrolling in the Edx Course:

**LinuxFoundationX LFD111x -Building a RISC-V CPU Core**

and using the IDE **MakerChip**

The architecture for a RISC-V CPU Core is given below: 


![image](https://github.com/user-attachments/assets/1148e09d-a298-44b4-8dd3-bf0938db1d74)


![image](https://github.com/user-attachments/assets/b700d5be-2947-44e0-b340-f9e5ea1de093)

RISC-V Implements a 5 stage pipeline (Instruction Fetch, Instruction Decode, Execute, Memory Access, Write Back).

The components in/processes of a RISC-V CPU Core include : 

# PC Logic:

This logic is responsible for the program counter (PC). The PC identifies the instruction our CPU will execute next. Most instructions execute sequentially, meaning the default behavior of the PC is to increment to the following instruction each clock cycle. Branch and jump instructions, however, are non-sequential. They specify a target instruction to execute next, and the PC logic must update the PC accordingly.

Initially, we will implement only sequential fetching, so the PC update will be, for now, simply a counter. Note that:

The PC is a byte address, meaning it references the first byte of an instruction in the IMem. Instructions are 4 bytes long, so, although the PC increment is depicted as "+1" (instruction), the actual increment must be by 4 (bytes). The lowest two PC bits must always be zero in normal operation.
Instruction fetching should start from address zero, so the first **$pc** value with $reset deasserted should be zero, as is implemented in the logic diagram below.
Unlike our earlier counter circuit, for readability, we use unique names for **$pc** and **$next_pc**, by assigning **$pc** to the previous **$next_pc**.
 

# Fetch: 

The instruction memory (IMem) holds the instructions to execute. To read the IMem, or "fetch", we simply pull out the instruction pointed to by the PC.

# Decode Logic: 

Now that we have an instruction to execute, we must interpret, or decode, it. We must break it into fields based on its type. These fields would tell us which registers to read, which operation to perform, etc.

![image](https://github.com/user-attachments/assets/a43ad678-0ebb-42f2-8721-564b1e95f25e)

![image](https://github.com/user-attachments/assets/bfda98b0-d586-4352-a7dc-f9096fa9ccb3)

We need to determine the specific instruction. This is determined from the **opcode**, **instr[30]**, and **funct3** fields as follows. Note that **instr[30]** is **$funct7[5]** for R-type, or **$imm[10]** for I-type and is labeled "**funct7[5]**" in the table below.:

![image](https://github.com/user-attachments/assets/ebb41c53-c801-4127-83fa-9bc09fea742f)



# Register File Read: 

The register file is a small local storage of values the program is actively working with. We decoded the instruction to determine which registers we need to operate on. Now, we need to read those registers from the register file.

![image](https://github.com/user-attachments/assets/c3a88849-c4ff-4733-9aa9-9b1b66c88c12)


# Arithmetic Logic Unit (ALU): 

Now that we have the register values, it’s time to operate on them. This is the job of the ALU. It will add, subtract, multiply, shift, etc, based on the operation specified in the instruction.

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


# DMem: 

The Data Memory is written to by store instructions and read from by load instructions.

Both load and store instructions require an address from which to read, or to which to write. As with the IMem, this is a byte-address. Loads and stores can read/write single bytes, half-words (2 bytes), or words (4 bytes/32 bits).

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
