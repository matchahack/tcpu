`include "rtl/io_core_interface.sv"

module control (
    input   logic clk,
    input   logic rst_n,
    input   logic mode,
    input   logic rx_serial,
    output  logic tx_serial
);

io_core_interface #(
    .CLK_FREQ(100_000_000),
    .BAUD(115_200)
) io_core_interface_u (
    .clock(clk),
    .nreset(rst_n),
    .mode(mode),
    .rx_serial_i(rx_serial),
    .tx_serial_o(tx_serial)
);

endmodule