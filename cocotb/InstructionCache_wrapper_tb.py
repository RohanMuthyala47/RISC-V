import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random
from cocotbext.axi import AxiBus, AxiRam
from cocotb.utils import get_sim_time

IDLE        = 0b000
CHECK       = 0b001
RD_REQ      = 0b101
RD_DATA     = 0b110
RD_COMPLETE = 0b111

STATE_MAP = {
    0b000: "IDLE",
    0b001: "CHECK",
    0b101: "RD_REQ",
    0b110: "RD_DATA",
    0b111: "RD_COMPLETE"
}

CLK_PERIOD = 10

CACHE_SIZE = 128

def generate_random_bytes(length):
    return bytes([random.randint(0, 255) for _ in range(length)])

@cocotb.test()
async def main_test(dut):

    axi_ram_slave = AxiRam(
        AxiBus.from_prefix(dut, "axi"),
        dut.clk,
        dut.ARESETn,
        size=4096,
        reset_active_level=False
    )

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.rst.value = 1
    dut.ARESETn.value = 0

    await Timer(5, unit="ns")

    dut.rst.value = 0
    dut.ARESETn.value = 1
    
    await RisingEdge(dut.clk)

    ref_mem = []
    for addr in range(0,4096,4):
        word = generate_random_bytes(4)
        axi_ram_slave.write(addr, word)
        ref_mem.append(word)

    for addr in range(0,4096,4):
        assert ref_mem[int(addr/4)] == axi_ram_slave.read(addr, 4)

    assert dut.icache_inst.curr_state.value == IDLE
    assert dut.icache_inst.next_state.value == IDLE

    dut.cpu_addr_req.value = 0
    dut.address.value = 0x0
    await RisingEdge(dut.clk)

    assert dut.stall.value == 0
    assert dut.icache_inst.next_state.value == 0
    
    
#######################################################################
#### READ AND MISS TEST
#######################################################################
    dut.address.value = 0x0
    dut.cpu_addr_req.value = 1
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    
    print(f"Output Instruction Value = {dut.address.value}\n")
    
    assert int(dut.address.value) == 0
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == IDLE
    assert dut.icache_inst.next_state.value == CHECK
    
##############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"Check if HIT OR MISS") 
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == CHECK
    assert dut.icache_inst.next_state.value == RD_REQ
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    
    print(f"TAG MISS -> CPU STALLED, REQUESTING READ FROM MEMORY\n") 
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n")
    
    assert int(dut.axi_arready.value) == 1
    
    assert dut.icache_inst.curr_state.value == RD_REQ
    assert dut.icache_inst.next_state.value == RD_DATA
    
    print(f"stall = {dut.stall.value}")
    assert dut.stall.value == 1
    
    araddr = dut.axi_araddr.value
    araddr_tag = araddr[31:9]
    araddr_idx = araddr[8:2]
    print(f"ARVALID value : {dut.axi_arvalid.value}")
    print(f"ARREADY value : {dut.axi_arready.value}")
    print(f"ARADDR value : {dut.axi_araddr.value}\n\n")
    
    assert dut.axi_arvalid.value == 1
    assert dut.axi_arready.value == 1
    assert dut.axi_araddr.value == 0
    assert araddr_tag == 0
    assert araddr_idx == 0
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    
    print(f"HANDSHAKE SUCCESSFUL - INITIATING DATA READ FROM MAIN MEMORY\n") 
    
    print(f"stall = {dut.stall.value}\n")
    assert dut.stall.value == 1
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n")
    
    assert dut.icache_inst.curr_state.value == RD_DATA
    assert dut.icache_inst.next_state.value == RD_DATA
    
    print(f"ARVALID value : {dut.axi_arvalid.value}")
    print(f"ARREADY value : {dut.axi_arready.value}\n")
    
    print(f"RVALID value : {dut.axi_rvalid.value}")
    print(f"RREADY value : {dut.axi_rready.value}")
    print(f"RDATA value : {dut.axi_rdata.value}\n")
    
    print(f"RRESP value : {dut.axi_rresp.value}")
    print(f"RLAST value : {dut.axi_rlast.value}\n\n")
    
    assert dut.axi_arvalid.value == 0
    assert dut.axi_arready.value == 1

    assert dut.axi_rvalid.value == 0
    assert dut.axi_rready.value == 1
    assert dut.axi_rdata.value == 0
    
    assert dut.axi_rresp.value == 0
    assert dut.axi_rlast.value == 0
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"RECEIEVED DATA FROM AXI SLAVE RAM\n") 
    
    print(f"stall = {dut.stall.value}\n")
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n")
    
    assert dut.icache_inst.curr_state.value == RD_DATA
    assert dut.icache_inst.next_state.value == RD_COMPLETE
    
    print(f"ARVALID value : {dut.axi_arvalid.value}")
    print(f"ARREADY value : {dut.axi_arready.value}\n")
    
    print(f"RVALID value : {dut.axi_rvalid.value}")
    print(f"RREADY value : {dut.axi_rready.value}")
    print(f"RDATA value : {dut.axi_rdata.value}\n")
    
    print(f"RRESP value : {dut.axi_rresp.value}")
    print(f"RLAST value : {dut.axi_rlast.value}\n\n")
    
    assert dut.axi_arvalid.value == 0
    assert dut.axi_arready.value == 1

    assert dut.axi_rvalid.value == 1
    assert dut.axi_rready.value == 1
    
    assert dut.axi_rresp.value == 0
    assert dut.axi_rlast.value == 1
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"READ OPERATION COMPLETE, CPU STALL=0\n")
    
    print(f"stall = {dut.stall.value}\n")
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n")
    
    assert dut.icache_inst.curr_state.value == RD_COMPLETE
    assert dut.icache_inst.next_state.value == CHECK
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    print(f"ARVALID value : {dut.axi_arvalid.value}\n")
    print(f"RREADY value : {dut.axi_rready.value}\n")
    
    assert dut.axi_arvalid.value == 0
    assert dut.axi_rready.value == 0
    
    print(f"Cache Value at Address 0 : {dut.icache_inst.cache_data_array[0].value}")
    assert dut.icache_inst.cache_data_array[0].value == int.from_bytes(ref_mem[0], "little")
    
###############################################################################
    dut.cpu_addr_req.value = 0
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"DEASSERT cpu_addr_req, CACHE CURRENTLY IN CHECK STATE\n")
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == CHECK
    assert dut.icache_inst.next_state.value == IDLE
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"CACHE NOW IDLE\n")
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    
    assert dut.instruction.value == 0
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == IDLE
    assert dut.icache_inst.next_state.value == IDLE
    
###############################################################################
    dut.cpu_addr_req.value = 1
    dut.address.value = 0x0
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"ASSERT cpu_addr_req for Address=0\n")
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    
    assert dut.instruction.value == 0
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == IDLE
    assert dut.icache_inst.next_state.value == CHECK
    
###############################################################################
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"TAG HIT, INSTRUCTION AT ADDRESSS=0 IS READ\n")
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
    
    assert dut.icache_inst.curr_state.value == CHECK
    assert dut.icache_inst.next_state.value == CHECK
    
###############################################################################
    dut.address.value = 0x4
    await RisingEdge(dut.clk)
    time = get_sim_time(unit="ns")
    print(f"##############################################################################")
    print(f"Simulation Time = {time} ns")
    print(f"REQUEST INSTRUCTION FROM NEW ADDRESS\n")
    
    print(f"Output Instruction Value = {dut.address.value}\n")
    
    print(f"Output Instruction Value = {dut.instruction.value}\n")
    
    print(f"Current state = {STATE_MAP.get(int(dut.icache_inst.curr_state.value), 'UNKNOWN')}")
    print(f"Next state = {STATE_MAP.get(int(dut.icache_inst.next_state.value), 'UNKNOWN')}\n\n")
