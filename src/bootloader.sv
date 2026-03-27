module bootloader #(
    parameter  MEM_DEPTH = 7,
    localparam PC_SIZE   = $clog2(MEM_DEPTH + 1)
)(
    input  logic                        clk,
    input  logic                        rst,
    input  logic                        uart_rx_valid,
    input  logic [7:0]                  instruction,
    output logic [8*(MEM_DEPTH+1)-1:0]  program_mem_flat,
    output logic                        bootload_done
);

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    logic [7:0]        program_mem [MEM_DEPTH:0];
    logic [PC_SIZE-1:0] program_counter;

    // -------------------------------------------------------------------------
    // Flatten packed → unpacked for port output
    // -------------------------------------------------------------------------

    genvar i;
    generate
        for (i = 0; i <= MEM_DEPTH; i++) begin : gen_flatten
            assign program_mem_flat[i*8 +: 8] = program_mem[i];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Bootloader FSM with full reset
    // -------------------------------------------------------------------------

    logic mem_full;
    assign mem_full = (program_counter == MEM_DEPTH[PC_SIZE-1:0]);

    integer j;

    always_ff @(posedge clk) begin
        if (!rst) begin
            program_counter <= '0;
            bootload_done   <= 1'b0;

            // Reset entire memory array
            for (j = 0; j <= MEM_DEPTH; j++) begin
                program_mem[j] <= '0;
            end

        end else if (uart_rx_valid && !bootload_done) begin
            program_mem[program_counter] <= instruction;

            if (mem_full) begin
                bootload_done <= 1'b1;
            end else begin
                program_counter <= program_counter + 1'b1;
            end
        end
    end

endmodule