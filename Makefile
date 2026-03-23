# =====================
# COCOTB BUILD COMMANDS
# =====================

TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = tcpu/control.sv
TOPLEVEL = control
MODULE = control_tb

EXTRA_ARGS += --trace --trace-structs \
						-Itcpu/src/rtl \
						-Itcpu/src/rtl/io \
						-Itcpu/src/rtl/core \
						-Itcpu/src/rtl/core/drivers

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: verif gls

verif:
	make clean
	make SIM=verilator