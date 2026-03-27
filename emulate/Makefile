# ===============================
# TANGNANO9K YOSYS BUILD COMMANDS
# ===============================

YOSYS ?= yosys
NEXTPNR ?= nextpnr-himbaechel
BOARD ?= tangnano9k
FAMILY ?= GW1N-9C
DEVICE ?= GW1NR-LV9QN88PC6/I5
TOP ?= project

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

gls:
	yosys -D TCPU_ENV_EMUL -p "read_verilog -sv $(TOP).sv; synth; stat" > gatecount.txt

# ==========================
# HOST2DOCKER BUILD COMMANDS
# ==========================

docker_up:
	docker run -it --privileged --device=/dev/ttyUSB0 --device=/dev/ttyUSB1 --device=/dev/ttyUSB2 $$(docker images -q bsides_tlac)

docker_build:
	docker cp ../src $$(docker ps -q --filter "ancestor=bsides_tlac"):/root/
	docker cp Makefile $$(docker ps -q --filter "ancestor=bsides_tlac"):/root/src
	docker cp tangnano9k.cst $$(docker ps -q --filter "ancestor=bsides_tlac"):/root/src
	docker exec -d -w /root/src $$(docker ps -q --filter "ancestor=bsides_tlac") make all
	docker exec -d -w /root/src $$(docker ps -q --filter "ancestor=bsides_tlac") make gls

read_gls:
	docker cp $$(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu/gatecount.txt .
	python3 gls_calc.py

fpga_flash:
	docker cp $$(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu/control.fs .
	openFPGALoader -b tangnano9k -f control.fs