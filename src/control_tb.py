#!/usr/bin/env python3

import cocotb
from testing.test_base import test_base

@cocotb.test()
async def control_tb_base(dut):
    await test_base(dut)