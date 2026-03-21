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

.PHONY: test gls

test:
	make clean
	make SIM=verilator

gls:
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); synth; stat" > gls/gatecount.txt
	python3 gls/calculate.py