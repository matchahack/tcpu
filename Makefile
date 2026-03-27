# =====================
# COCOTB BUILD COMMANDS
# =====================

TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = src/project.sv
TOPLEVEL = tt_um_tcpu_alienflip
MODULE = control_tb

EXTRA_ARGS += --trace --trace-structs -Isrc

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: verif

verif:
	make clean
	make SIM=verilator