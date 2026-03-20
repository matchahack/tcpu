#!/usr/bin/env python3

import cocotb
from testing.test_base import add_1_instruction, add_1_nop_instruction

@cocotb.test()
async def control_tb_base(dut):
    #await add_1_instruction(dut)
    await add_1_nop_instruction(dut)