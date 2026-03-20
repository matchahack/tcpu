module cpu_control #(
    parameter MEM_DEPTH = 3,
    parameter PC_SIZE   = $clog2(MEM_DEPTH+1)
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       bootload_done,
    input  logic       uart_tx_ready,
    input  logic [8*(MEM_DEPTH+1)-1:0] program_mem_flat,
    output logic       data_valid,
    output logic [7:0] trace
);

    localparam  IDLE    = 2'd0,
                FETCH   = 2'd1,
                DECODE  = 2'd2,
                EXECUTE = 2'd3;
    logic [1:0] cpu_control_state;

    logic [7:0]         reg_a, reg_b, instruction_register;
    logic [PC_SIZE-1:0] program_counter;
    logic [PC_SIZE-1:0] addr;
    logic [2:0]         opcode;

    logic [7:0] data_mem    [MEM_DEPTH:0];
    logic [7:0] program_mem [MEM_DEPTH:0];

    genvar i;
    generate
        for (i = 0; i <= MEM_DEPTH; i++) begin
            assign program_mem[i] = program_mem_flat[i*8 +: 8];
        end
    endgenerate

    assign opcode = instruction_register[7:5];
    assign addr   = instruction_register[PC_SIZE-1:0];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            program_counter      <= '0;
            reg_a                <= '0;
            reg_b                <= '0;
            instruction_register <= '0;
            data_valid           <= '0;
            cpu_control_state    <= IDLE;
        end else begin
            case (cpu_control_state)

                IDLE: begin
                    case (bootload_done)
                        '1: cpu_control_state <= FETCH;
                        '0:begin
                            program_counter      <= '0;
                            reg_a                <= '0;
                            reg_b                <= '0;
                            instruction_register <= '0;
                        end
                    endcase
                end

                FETCH: begin
                    data_valid <= 1'b0;
                    if (program_counter == MEM_DEPTH) begin
                        cpu_control_state <= IDLE;
                    end else begin
                        instruction_register <= program_mem[program_counter];
                        program_counter      <= program_counter + 1;
                        cpu_control_state    <= DECODE;
                    end
                end

                DECODE: begin
                    cpu_control_state <= EXECUTE;
                end

                EXECUTE: begin
                    data_valid        <= 1'b1;
                    unique case (opcode)
                        3'b000: begin // add
                            reg_a <= reg_a + reg_b;
                            trace <= reg_a;
                        end
                        3'b001: begin // add one
                            reg_a <= reg_a + 8'd1;
                            trace <= reg_a;
                        end
                        3'b010: begin // and
                            reg_a <= reg_a & reg_b;
                            trace <= reg_a;
                        end
                        3'b011: begin // not
                            reg_a <= ~reg_a;
                            trace <= ~reg_a;
                        end
                        3'b100: begin // nop
                            program_counter <= addr;
                            trace           <= {addr, 5'b0};
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
                        default: ;
                    endcase
                    cpu_control_state <= FETCH;
                end

                default: cpu_control_state <= IDLE;
            endcase
        end
    end

endmodule