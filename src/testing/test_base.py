#!/usr/bin/env python3

import cocotb
from cocotbext.uart import UartSource, UartSink
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def add_1_instruction(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a repeated add 1 instruction
    await uart_source.write([0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    ## wait and then run cpu on loaded program

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")


async def add_1_nop_instruction(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a add 1 instruction and repeating nopc
    await uart_source.write([0x20,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    ## wait and then run cpu on loaded program

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")