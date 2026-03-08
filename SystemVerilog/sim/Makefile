# Makefile

# defaults
SIM ?= verilator
#SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# DUT=CPU, CPU_Pipelined, ProgramCounter, InstructionMemory, RegisterFile, ControlUnit, ImmediateSignExtender, DataMemory

DUT?=CPU_Pipelined

VERILOG_SOURCES += /path/to/cpu_pkg.sv
VERILOG_SOURCES += /path/to/CPU_Pipelined.sv
VERILOG_SOURCES += /path/to/CPU.sv
VERILOG_SOURCES += /path/to/ALU.sv
VERILOG_SOURCES += /path/to/ControlUnit.sv
VERILOG_SOURCES += /path/to/ProgramCounter.sv
VERILOG_SOURCES += /path/to/RegisterFile.sv
VERILOG_SOURCES += /path/to/InstructionMemory.sv
VERILOG_SOURCES += /path/to/DataMemory.sv
VERILOG_SOURCES += /path/to/ImmediateSignExtender.sv
VERILOG_SOURCES += /path/to/ForwardingUnit.sv
VERILOG_SOURCES += /path/to/AXI_if.sv

#VERILOG_SOURCES += $(wildcard /path/to/rtl/*.sv)

VERILOG_INCLUDE_DIRS = /path/to/includes/

COCOTB_TOPLEVEL = $(DUT)

COCOTB_TEST_MODULES = $(DUT)_tb

#IVERILOG_COMPILE_ARGS = -g2012 -I../rtl

include $(shell cocotb-config --makefiles)/Makefile.sim
