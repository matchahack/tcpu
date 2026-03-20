module data_load #(
    parameter MEM_DEPTH = 3,
    parameter PC_SIZE = $clog2(MEM_DEPTH+1)
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       uart_rx_valid,
    input  logic [7:0]                 instruction,
    output logic [8*(MEM_DEPTH+1)-1:0] program_mem_flat,
    output logic                       bootload_done
);

    logic [7:0] program_mem [MEM_DEPTH:0];

    logic [PC_SIZE-1:0] program_counter;

    genvar i;
    generate
        for (i = 0; i <= MEM_DEPTH; i++) begin
            assign program_mem_flat[i*8 +: 8] = program_mem[i];
        end
    endgenerate

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            program_counter <= '0;
            bootload_done   <= 1'b0;
        end else begin
            if (uart_rx_valid) begin
                if (bootload_done == '0) program_mem[program_counter] <= instruction;
                if (program_counter == MEM_DEPTH) begin
                    bootload_done <= 1'b1;
                end else begin
                    program_counter <= program_counter + 1;
                end
            end
        end
    end

endmodule