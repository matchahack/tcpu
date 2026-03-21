#!/usr/bin/env python3

import cocotb
from cocotbext.uart import UartSource, UartSink
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def add_1_program(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a repeated add 1 instruction program
    await uart_source.write([0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")


async def add_1_nop_program(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a add 1 instruction and repeating nop program
    await uart_source.write([0x20,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")

async def load_add_1_store_load_program(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a load, add 1, store, load and repeating nop program
    await uart_source.write([0xC0,0x20,0xA0,0xC0,0xFF,0xFF,0xFF,0XFF])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")

async def not_add_1_not_program(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a not, add 1, not and repeating nop program 
    await uart_source.write([0x60,0x20,0x20,0x60,0x20,0x60,0xFF,0XFF])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")

async def add_jump_add_program(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    dut.rst_n.value = 1 # reset high (device active)
    for i in range(int(1e2)) : await RisingEdge(dut.clk)
    dut.rst_n.value = 0 # reset low (device active)
    
    uart_source = UartSource(dut.rx_serial, baud=115200, bits=8)
    uart_sink = UartSink(dut.tx_serial, baud=115200, bits=8)

    # this is a add, jump to 5, repeating add program 
    await uart_source.write([0x20,0x85,0x20,0x20,0x20,0x20,0x20,0X20])
    await uart_source.wait()

    for i in range(5*int(1e4)): await RisingEdge(dut.clk)

    dut._log.info(f"Sending DATA")
    data_in = dut.io_core_interface_u.chip_top_u.data_in.value
    dut._log.info(f"Data in data_in: {data_in}")

    await uart_sink.read()

    dut._log.info(f"Receiving DATA")
    data_out = dut.io_core_interface_u.chip_top_u.data_out.value
    dut._log.info(f"Data in data_out: {data_out}")