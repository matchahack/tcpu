/*
 * Copyright (c) 2026 Kai Harris
 * SPDX-License-Identifier: Apache-2.0
 *
 * This module generates a synchronous active-high reset
 * from an asynchronous active-low input reset.
 */

`default_nettype none

module sync_reset (
    input  wire clk,       // Clock
    input  wire rst_n,     // Asynchronous active-low reset
    output wire rst_sync   // Synchronous active-high reset
);

    reg [1:0] rst_ff;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rst_ff <= 2'b11;          // force reset initially
        else
            rst_ff <= {rst_ff[0], 1'b0}; // shift in 0 to de-assert reset
    end

    assign rst_sync = rst_ff[1]; // active high synchronous reset

endmodule