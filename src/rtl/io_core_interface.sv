`include "src/rtl/core/chip_top.sv"
`include "src/rtl/io/uart_tx.sv"
`include "src/rtl/io/uart_rx.sv"

module io_core_interface #(
    parameter BAUD = 115_200, 
    parameter CLK_FREQ = 100_000_000
)(
    input  logic clock,
    input  logic nreset,
    input  logic mode,
    input  logic rx_serial_i,
    output logic tx_serial_o
);

logic tx_valid_i, tx_active_o, tx_done_o, rx_valid_o;
logic [7:0] rx_data_o, tx_data_i;

uart_rx #(
    .CLKS_PER_BIT (868) // CLK_FREQ/BAUD
) uart_rx_u (
    .i_Clock(clock),
    .i_Rx_Serial(rx_serial_i),
    .o_Rx_DV(rx_valid_o),
    .o_Rx_Byte(rx_data_o)
);

chip_top #(
    .MEM_DEPTH(7)
) chip_top_u (
    .clk(clock),
    .rst(nreset),
    .uart_rx_valid(rx_valid_o),
    .uart_tx_done(tx_done_o),
    .uart_tx_active(tx_active_o),
    .data_in(rx_data_o),
    .data_out(tx_data_i),
    .data_valid(tx_valid_i)
);

uart_tx #(
    .CLKS_PER_BIT (868) // CLK_FREQ/BAUD
) uart_tx_u (
    .i_Clock(clock),
    .i_Tx_DV(tx_valid_i),
    .i_Tx_Byte(tx_data_i),
    .o_Tx_Serial(tx_serial_o),
    .o_Tx_Active(tx_active_o),
    .o_Tx_Done(tx_done_o)
);

endmodule