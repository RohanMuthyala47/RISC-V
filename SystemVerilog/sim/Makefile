# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# DUT=CPU, ProgramCounter, InstructionMemory, RegisterFile, ControlUnit, ImmediateSignExtender, DataMemory

DUT?=CPU

#VERILOG_SOURCES += /path/to/rtl/$(DUT).sv
VERILOG_SOURCES += $(wildcard /path/to/rtl/*.sv)

VERILOG_INCLUDE_DIRS = /path/to/includes/

COCOTB_TOPLEVEL = $(DUT)

COCOTB_TEST_MODULES = $(DUT)_tb

# IVERILOG_COMPILE_ARGS = -g2012 -I../rtl

include $(shell cocotb-config --makefiles)/Makefile.sim
