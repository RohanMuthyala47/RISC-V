# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

DUT?=ControlUnit

VERILOG_SOURCES += /home/rohan/risc_v/rtl/$(DUT).sv

VERILOG_INCLUDE_DIRS = /home/rohan/risc_v/rtl/

COCOTB_TOPLEVEL = $(DUT)

COCOTB_TEST_MODULES = $(DUT)_tb

# IVERILOG_COMPILE_ARGS = -g2012 -I../rtl

include $(shell cocotb-config --makefiles)/Makefile.sim
