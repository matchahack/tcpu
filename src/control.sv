/*
 * Copyright (c) 2026 Kai Harris
 * SPDX-License-Identifier: Apache-2.0
 */
 
`ifdef TCPU_ENV_EMUL
    `include "base_interface.sv"
`endif

module control (
    input   logic clk,
    input   logic rst_n,
    input   logic rx_serial,
    output  logic tx_serial
);

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 50 MHz Clock, 115200 baud UART
// (50000000)/(115200)  = 434
// (27000000)/(115200)  = 434

`ifdef TCPU_ENV_EMUL
    parameter CLKS_PER_BIT = 234;
`else
    parameter CLKS_PER_BIT = 434;
`endif

base_interface #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) base_interface_u (
    .clock(clk),
    .nreset(rst_n),
    .rx_serial_i(rx_serial),
    .tx_serial_o(tx_serial)
);

endmodule