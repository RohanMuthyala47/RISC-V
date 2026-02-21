# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# DUT = ProgramCounter, InstructionMemory, RegisterFile, ControlUnit, ImmediateSignExtender, DataMemory
DUT ?= NameofTopMOdule

VERILOG_SOURCES += path/to/rtl/srcs

VERILOG_INCLUDE_DIRS = path/to/includefile

COCOTB_TOPLEVEL = $(DUT)

COCOTB_TEST_MODULES = $(DUT)_tb

# IVERILOG_COMPILE_ARGS = -g2012 -I../rtl

include $(shell cocotb-config --makefiles)/Makefile.sim
