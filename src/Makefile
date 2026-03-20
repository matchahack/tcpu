TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = control.sv
TOPLEVEL = control
MODULE = control_tb

# For waveform generation
EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: wave gatecount gls

wave:
	gtkwave control.vcd

gls:
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); synth; stat" > gls/gatecount.txt
	python3 gls/calculate.py