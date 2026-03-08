# Makefile

# defaults
SIM ?= verilator
#SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Top RTL file
# DUT=CPU_Pipelined, CPU_SingleCycle, ProgramCounter, InstructionMemory, RegisterFile, ControlUnit, ImmediateSignExtender, DataMemory
DUT?=CPU_Pipelined
# make DUT=CPU_Pipelined | DUT=CPU_SingleCycle

ifndef RISC_V_DIR
    $(error Please set RISC_V_DIR to the project root)
endif

RTL = $(RISC_V_DIR)/rtl

# Common rtl files
COMMON_RTL = \
    $(RTL)/cpu_pkg.sv \
    $(RTL)/interface/AXI_Interface.sv

# Memory/Cache rtl
MEMORY_RTL = \
    $(RTL)/memory/InstructionMemory.sv \
    $(RTL)/memory/DataMemory.sv

# Pipelined core rtl
PIPELINED_CORE    = $(sort $(wildcard $(RTL)/pipelined_core/*.sv))
# Single-cycle core rtl
SINGLE_CYCLE_CORE = $(sort $(wildcard $(RTL)/single_cycle_core/*.sv))
    
ifeq ($(DUT),CPU_Pipelined)
    CORE_RTL = $(PIPELINED_CORE)
endif

ifeq ($(DUT),CPU_SingleCycle)
    CORE_RTL = $(SINGLE_CYCLE_CORE)
endif

ifndef CORE_RTL
$(error Unknown DUT "$(DUT)". Supported: CPU_Pipelined CPU_SingleCycle)
endif

VERILOG_SOURCES = $(COMMON_RTL) $(MEMORY_RTL) $(CORE_RTL)

# Set DEBUG=1 for debugging
ifdef DEBUG
$(info VERILOG_SOURCES=$(VERILOG_SOURCES))
endif

COCOTB_TOPLEVEL = $(DUT)

COCOTB_TEST_MODULES = $(DUT)_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
