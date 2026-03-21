#!/usr/bin/env python3

import cocotb
from testing.uart import run_program

# ---------------------------------------------------------------------------
# Programs
# ---------------------------------------------------------------------------

PROGRAMS = {
    "add_1":                      ([0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20], "Repeated ADD 1"),
    "add_1_nop":                  ([0x20, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF], "ADD 1 then repeating NOP"),
    "load_add_1_store":           ([0xC0, 0x20, 0xA0, 0xC0, 0xFF, 0xFF, 0xFF, 0xFF], "LOAD, ADD 1, STORE, LOAD, repeating NOP"),
    "not_add_1_not":              ([0x60, 0x20, 0x60, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF], "NOT, ADD 1, NOT, repeating NOP"),
    "add_jump_add":               ([0x20, 0x85, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20], "ADD 1, JUMP to 5, repeating ADD 1"),
    "add_1_store_add_1_load_and": ([0x20, 0xA0, 0x20, 0xC0, 0x40, 0xFF, 0xFF, 0xFF], "ADD 1, STORE, ADD 1, LOAD, AND,repeating NOP"),
    "add_1_store_add_1_load_add": ([0x20, 0xA0, 0x20, 0xC0, 0x00, 0xFF, 0xFF, 0xFF], "ADD 1, STORE, ADD 1, LOAD, ADD,repeating NOP")
}

# ---------------------------------------------------------------------------
# Test entry points
# ---------------------------------------------------------------------------

#@cocotb.test()
async def add_1_program(dut):
    await run_program(dut, *PROGRAMS["add_1"])

#@cocotb.test()
async def add_1_nop_program(dut):
    await run_program(dut, *PROGRAMS["add_1_nop"])

#@cocotb.test()
async def load_add_1_store_load_program(dut):
    await run_program(dut, *PROGRAMS["load_add_1_store"])

#@cocotb.test()
async def not_add_1_not_program(dut):
    await run_program(dut, *PROGRAMS["not_add_1_not"])

#@cocotb.test()
async def add_jump_add_program(dut):
    await run_program(dut, *PROGRAMS["add_jump_add"])

#@cocotb.test()
async def add_1_store_add_1_load_and(dut):
    await run_program(dut, *PROGRAMS["add_1_store_add_1_load_and"])

@cocotb.test()
async def add_1_store_add_1_load_add(dut):
    await run_program(dut, *PROGRAMS["add_1_store_add_1_load_add"])