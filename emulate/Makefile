YOSYS ?= yosys
NEXTPNR ?= nextpnr-himbaechel
BOARD ?= tangnano9k
FAMILY ?= GW1N-9C
DEVICE ?= GW1NR-LV9QN88PC6/I5
TOP ?= control

.DEFAULT_GOAL := all

all: \
	$(TOP).fs

unpacked:\
	$(TOP)-unpacked.sv

load:
	make all

clean: 
	rm -f *.json *.fs *-unpacked.sv sim *.svcd
	
.PHONY: unpacked clean

%.fs: %.json
	gowin_pack -d $(FAMILY) -o $@ $^

%.json: %-synth.json $(BOARD).cst
	$(NEXTPNR) --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(BOARD).cst

%-synth.json: %.sv
	$(YOSYS) -D TCPU_ENV_EMUL -D LEDS_NR=6 -D OSC_TYPE_OSC -D INV_BTN=0 -D CPU_FREQ=27 -D BAUD_RATE=115200 -D NUM_HCLK=5 -D HAS_FLASH608K -p "read_verilog -sv $^; synth_gowin -json $@"

%-unpacked.sv: %.fs
	gowin_unpack -d $(FAMILY) -o $@ $^