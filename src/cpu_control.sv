/*
 * Copyright (c) 2026 Kai Harris
 * SPDX-License-Identifier: Apache-2.0
 */
 
module cpu_control #(
    parameter MEM_DEPTH = 7,
    parameter PC_SIZE   = 3 // $clog2(MEM_DEPTH + 1)
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       bootload_done,
    input  logic                       uart_tx_done,
    input  logic [8*(MEM_DEPTH+1)-1:0] program_mem_flat,
    output logic                       data_valid,
    output logic [7:0]                 trace
);

    // ========================
    // State encoding
    // ========================
    localparam   IDLE      = 3'd0,
                 FETCH     = 3'd1,
                 DECODE    = 3'd2,
                 EXECUTE   = 3'd3,
                 WAIT_UART = 3'd4,
                 DONE      = 3'd5;
    reg [2:0] state, next_state;

    // ========================
    // Registers
    // ========================
    logic [7:0]         reg_a, reg_b;
    logic [7:0]         instruction_register;
    logic [PC_SIZE-1:0] program_counter;
    logic [PC_SIZE-1:0] addr;
    logic [2:0]         opcode;

    logic [7:0] data_mem    [MEM_DEPTH:0];
    logic [7:0] program_mem [MEM_DEPTH:0];

    // ========================
    // Program memory unpack
    // ========================
    wire _unused_ir = &{instruction_register[4:3], 1'b0};

    genvar i;
    generate
        for (i = 0; i <= MEM_DEPTH; i++) begin
            assign program_mem[i] = program_mem_flat[i*8 +: 8];
        end
    endgenerate

    assign opcode = instruction_register[7:5];
    assign addr   = instruction_register[PC_SIZE-1:0];

    // ========================
    // Sequential logic
    // ========================
    always_ff @(posedge clk) begin
        if (!rst) begin
            state                <= IDLE;
            program_counter      <= '0;
            reg_a                <= '0;
            reg_b                <= '0;
            instruction_register <= '0;
            data_valid           <= 1'b0;
            trace                <= 8'd0;
            data_mem[0]          <='0;
            data_mem[1]          <='0;
            data_mem[2]          <='0;
            data_mem[3]          <='0;
            data_mem[4]          <='0;
            data_mem[5]          <='0;
            data_mem[6]          <='0;
            data_mem[7]          <='0;
        end else begin
            state <= next_state;
            data_valid <= 1'b0;
            case (state)
                FETCH: begin
                    instruction_register <= program_mem[program_counter];
                    program_counter      <= program_counter + 1;
                end
                EXECUTE: begin
                    unique case (opcode)
                        3'b000: begin // add
                            reg_a <= reg_a + reg_b;
                            trace <= reg_a + reg_b;
                        end
                        3'b001: begin // add one
                            if (reg_a === 8'hFF) begin
                                reg_a <= 8'b1;
                                trace <= 8'b1;
                            end else begin
                                reg_a <= reg_a + 8'd1;
                                trace <= reg_a + 8'd1;
                            end
                        end
                        3'b010: begin // and
                            reg_a <= reg_a & reg_b;
                            trace <= reg_a & reg_b;
                        end
                        3'b011: begin // not
                            reg_a <= ~reg_a;
                            trace <= ~reg_a;
                        end
                        3'b100: begin // jmp
                            program_counter <= addr;
                            trace           <= {5'b0, addr};
                        end
                        3'b101: begin // store
                            data_mem[addr] <= reg_a;
                            trace          <= reg_a;
                        end
                        3'b110: begin // load
                            reg_b <= data_mem[addr];
                            trace <= data_mem[addr];
                        end

                        3'b111: begin // nop
                        end
                        default:; // nop
                    endcase
                    data_valid <= 1'b1;
                end
                default: ;
            endcase
        end
    end

    // ========================
    // Next-state logic
    // ========================
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (bootload_done)
                    next_state = FETCH;
            end
            FETCH: begin
                if (program_counter == MEM_DEPTH)
                    next_state = DONE;
                else
                    next_state = DECODE;
            end
            DECODE: begin
                next_state = EXECUTE;
            end
            EXECUTE: begin
                next_state = WAIT_UART;
            end
            WAIT_UART: begin
                if (uart_tx_done)
                    next_state = FETCH;
            end
            DONE: begin
                next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule