/*
 * Copyright (c) 2026 Kai Harris
 * SPDX-License-Identifier: Apache-2.0
 */
 
`ifdef TCPU_ENV_EMUL
    `include "compute_top.sv"
    `include "uart_tx.sv"
    `include "uart_rx.sv"
`endif

module base_interface #(
    parameter CLKS_PER_BIT = 217
)(
    input  logic clock,
    input  logic nreset,
    input  logic rx_serial_i,
    output logic tx_serial_o
);

logic tx_valid_i, tx_active_o, tx_done_o, rx_valid_o;
logic [7:0] rx_data_o, tx_data_i;

wire _unused_txa = &{tx_active_o, 1'b0};

uart_rx #(
    .CLKS_PER_BIT(CLKS_PER_BIT) // CLK_FREQ/BAUD
) uart_rx_u (
    .i_Clock(clock),
    .rst_n(nreset),
    .i_Rx_Serial(rx_serial_i),
    .o_Rx_DV(rx_valid_o),
    .o_Rx_Byte(rx_data_o)
);

compute_top #(
    .MEM_DEPTH(7)
) compute_top_u (
    .clk(clock),
    .rst(nreset),
    .uart_rx_valid(rx_valid_o),
    .uart_tx_done(tx_done_o),
    .data_in(rx_data_o),
    .data_out(tx_data_i),
    .data_valid(tx_valid_i)
);

uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) uart_tx_u (
    .i_Clock(clock),
    .rst_n(nreset),
    .i_Tx_DV(tx_valid_i),
    .i_Tx_Byte(tx_data_i),
    .o_Tx_Serial(tx_serial_o),
    .o_Tx_Active(tx_active_o),
    .o_Tx_Done(tx_done_o)
);

endmodule