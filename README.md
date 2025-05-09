# RISC-V-CPU-Design
Design of a RISC V CPU core, implementing all the necessary components and pipelining


![image](https://github.com/user-attachments/assets/1148e09d-a298-44b4-8dd3-bf0938db1d74)


![image](https://github.com/user-attachments/assets/b700d5be-2947-44e0-b340-f9e5ea1de093)


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

Now we need to determine the specific instruction. This is determined from the **opcode**, **instr[30]**, and **funct3** fields as follows. Note that **instr[30]** is **$funct7[5]** for R-type, or **$imm[10]** for I-type and is labeled "**funct7[5]**" in the table below.:

![image](https://github.com/user-attachments/assets/ebb41c53-c801-4127-83fa-9bc09fea742f)



# Register File Read: 

The register file is a small local storage of values the program is actively working with. We decoded the instruction to determine which registers we need to operate on. Now, we need to read those registers from the register file.

![image](https://github.com/user-attachments/assets/c3a88849-c4ff-4733-9aa9-9b1b66c88c12)


# Arithmetic Logic Unit (ALU): 

Now that we have the register values, it’s time to operate on them. This is the job of the ALU. It will add, subtract, multiply, shift, etc, based on the operation specified in the instruction.

# Register File Write: 

Now the result value from the ALU can be written back to the destination register specified in the instruction.

# DMem: 

Our test program executes entirely out of the register file and does not require a data memory (DMem). But no CPU is complete without one. The DMem is written to by store instructions and read from by load instructions.
