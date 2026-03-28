# SPDX-FileCopyrightText: © 2024 Kai Harris
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotbext.uart import UartSource, UartSink
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import logging

logging.basicConfig(level=logging.DEBUG)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

CLK_PERIOD_NS = 20  # 50 MHz
RESET_CYCLES  = 20
SETTLE_CYCLES = int(5e5)
BAUD_RATE     = 115200
UART_BITS     = 8

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

async def reset_dut(dut):
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start())
    dut._log.info("Reset")

    # Initialize outputs
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.uo_out.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.uart_tx.value = 1  # force idle

    for _ in range(RESET_CYCLES):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    for _ in range(RESET_CYCLES):
        await RisingEdge(dut.clk)

    # Let outputs settle
    await ClockCycles(dut.clk, 10)

async def run_program(dut, bytes_: list[int], description: str):
    """Upload *bytes_* over UART, wait for the result, and log data."""
    await reset_dut(dut)
    dut.uart_rx.value = 1  # idle high
    await ClockCycles(dut.clk, int(2e4))

    uart_source = UartSource(dut.uart_rx, baud=BAUD_RATE, bits=UART_BITS)
    uart_sink   = UartSink(dut.uart_tx, baud=BAUD_RATE, bits=UART_BITS)
    dut._log.info(f"\nRunning program: {description}")
    dut._log.info(f"Sending {len(bytes_)} bytes: {bytes_}")
    dut._log.info(f"Using baud rate: {BAUD_RATE}")

    # -----------------------------------------------------------------------
    # Send program
    # -----------------------------------------------------------------------
    await uart_source.write(bytes_)
    await uart_source.wait()
    dut._log.info("UART write complete")

    # -----------------------------------------------------------------------
    # Debug tracking
    # -----------------------------------------------------------------------
    last_tx = None

    for cycle in range(SETTLE_CYCLES):
        await RisingEdge(dut.clk)

        try:
            tx_val = int(dut.uart_tx.value)
        except:
            tx_val = 0

        # 🔍 Log ALL TX values occasionally (not just transitions)
        if cycle % 10000 == 0:
            dut._log.debug(f"[cycle {cycle}] TX={tx_val}")

        # 🔍 Log transitions
        if tx_val != last_tx:
            dut._log.debug(f"[cycle {cycle}] uart_tx changed -> {tx_val}")
            last_tx = tx_val

        # 🔍 Log received bytes
        rx_count = uart_sink.count()
        if rx_count > 0:
            dut._log.debug(f"[cycle {cycle}] RX count = {rx_count}")

        # Exit condition
        if rx_count >= 7:
            dut._log.info(f"Received 7 bytes after {cycle} cycles")
            break

    else:
        # -------------------------------------------------------------------
        # Timeout diagnostics
        # -------------------------------------------------------------------
        dut._log.info("Timeout waiting for UART data")
        dut._log.info(f"Bytes received: {uart_sink.count()}")

        # Dump partial data if any
        partial = []
        while uart_sink.count() > 0:
            partial.append(uart_sink.read_nowait(1)[0])

        dut._log.info(f"Partial data: {partial}")

    # -----------------------------------------------------------------------
    # Read final data
    # -----------------------------------------------------------------------
    try :
        data = uart_sink.read_nowait(7)
    except:
        data = 0
    dut._log.info(f"Final received data: {data}")

    return data