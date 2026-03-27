`ifdef TCPU_ENV_EMUL
    `include "bootloader.sv"
    `include "cpu_control.sv"
`endif

module compute_top #(
    parameter MEM_DEPTH = 7
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       uart_rx_valid,
    input  logic       uart_tx_done,
    input  logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic       data_valid
);

    logic bootload_done;
    logic [8*(MEM_DEPTH+1)-1:0] program_mem_flat;

    bootloader #(
        .MEM_DEPTH(MEM_DEPTH)
    ) bootloader_u (
        .clk(clk),
        .rst(rst),
        .bootload_done(bootload_done),
        .uart_rx_valid(uart_rx_valid),
        .instruction(data_in),
        .program_mem_flat(program_mem_flat)
    );

    cpu_control #(
        .MEM_DEPTH(MEM_DEPTH)
    ) cpu_control_u (
        .clk(clk),
        .rst(rst),
        .bootload_done(bootload_done),
        .uart_tx_done(uart_tx_done),
        .program_mem_flat(program_mem_flat),
        .data_valid(data_valid),
        .trace(data_out)
    );

endmodule