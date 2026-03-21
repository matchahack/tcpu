#!/usr/bin/env python3

import cocotb
from cocotbext.uart import UartSource, UartSink
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

CLK_PERIOD_NS = 10          # 100 MHz
RESET_CYCLES  = int(1e2)
SETTLE_CYCLES = 5 * int(1e4)
BAUD_RATE     = 115200
UART_BITS     = 8

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

async def reset_dut(dut):
    """Assert then deassert active-low reset."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
    dut.rst_n.value = 1
    for _ in range(RESET_CYCLES):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 0


def chip_top(dut):
    return dut.io_core_interface_u.chip_top_u


async def run_program(dut, bytes_: list[int], description: str):
    """Upload *bytes_* over UART, wait for the result, and log data_in/data_out."""
    await reset_dut(dut)

    uart_source = UartSource(dut.rx_serial, baud=BAUD_RATE, bits=UART_BITS)
    uart_sink   = UartSink(dut.tx_serial,   baud=BAUD_RATE, bits=UART_BITS)

    dut._log.info(f"Running program: {description}")
    await uart_source.write(bytes_)
    await uart_source.wait()

    for _ in range(SETTLE_CYCLES):
        await RisingEdge(dut.clk)

    await uart_sink.read()