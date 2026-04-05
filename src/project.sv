/*
 * Copyright (c) 2026 Kai Harris
 * SPDX-License-Identifier: Apache-2.0
 */

`ifdef TCPU_ENV_EMUL
    `include "base_interface.sv"
    `include "sync_reset.sv"
`endif

`default_nettype none

`ifdef TCPU_ENV_EMUL
  module project (
    input  wire       uart_rx,    // Dedicated inputs
    output wire       uart_tx,   // Dedicated outputs
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
`else
  module tt_um_tcpu_alienflip (
    input  wire       uart_rx,    // Dedicated inputs
    output wire       uart_tx,   // Dedicated outputs
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
`endif

  // CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
  //// 50 MHz Clock, 115200 baud UART
  //// (50000000)/(115200)  = 434
  `ifdef TCPU_ENV_EMUL
    parameter CLKS_PER_BIT = 234;
  `else
    parameter CLKS_PER_BIT = 434;
    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out[7:5] = 'b0;
    assign uo_out[3:0] = 'b0;
    assign uio_out     = '0;
    assign uio_oe      = '0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[7:0], ui_in[7:4], ui_in[2:0], 1'b0};
  `endif

  // -----------------------------
  // Synchronous reset generation
  // -----------------------------
  wire rst_sync;
  sync_reset sync_reset_u (
      .clk(clk),
      .rst_n(rst_n),
      .rst_sync(rst_sync)
  );

  base_interface #(
      .CLKS_PER_BIT(CLKS_PER_BIT)
  ) base_interface_u (
      .clk(clk),
      .rst_n(~rst_sync),
      .rx_serial_i(uart_rx),
      .tx_serial_o(uart_tx)
  );

endmodule