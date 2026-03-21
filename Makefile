TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = src/control.sv
TOPLEVEL = control
MODULE = control_tb

# For waveform generation
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: gatecount gls cocotb

cocotb:
	export COCOTB_SIM=1
	make clean
	make SIM=verilator

gls:
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); synth; stat" > gls/gatecount.txt
	python3 gls/calculate.py