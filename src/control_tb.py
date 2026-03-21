#!/usr/bin/env python3

import cocotb
from testing.test_base import add_1_program, add_1_nop_program, \
                                load_add_1_store_load_program, not_add_1_not_program, \
                                add_jump_add_program

@cocotb.test()
async def control_tb_base(dut):
    #await add_1_program(dut)
    #await add_1_nop_program(dut)
    #await load_add_1_store_load_program(dut)
    await not_add_1_not_program(dut)
    #await add_jump_add_program(dut)
    