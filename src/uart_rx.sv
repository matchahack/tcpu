//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
// Modified for proper reset and robust operation
//////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter CLKS_PER_BIT = 217 // 25 MHz clock example
)(
    input        i_Clock,
    input        rst_n,
    input        i_Rx_Serial,
    output reg   o_Rx_DV,
    output reg [7:0] o_Rx_Byte
);

    // FSM states
    localparam s_IDLE         = 3'b000;
    localparam s_RX_START_BIT = 3'b001;
    localparam s_RX_DATA_BITS = 3'b010;
    localparam s_RX_STOP_BIT  = 3'b011;
    localparam s_CLEANUP      = 3'b100;

    // Synchronize input to avoid metastability
    reg r_Rx_Data_R = 1'b1;
    reg r_Rx_Data   = 1'b1;

    always @(posedge i_Clock) begin
        r_Rx_Data_R <= i_Rx_Serial;
        r_Rx_Data   <= r_Rx_Data_R;
    end

    // Clock counter width
    localparam CLK_CNT_WIDTH = $clog2(CLKS_PER_BIT);
    reg [CLK_CNT_WIDTH-1:0] r_Clock_Count = 0;

    // Bit index and temporary storage
    reg [2:0]  r_Bit_Index = 0;
    reg [7:0]  r_Rx_Byte   = 0;
    reg [2:0]  r_SM_Main   = s_IDLE;

    // RX state machine
    always @(posedge i_Clock) begin
        if (!rst_n) begin
            // Proper synchronous reset
            o_Rx_Byte     <= 8'd0;
            o_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            r_Rx_Byte     <= 8'd0;
            r_SM_Main     <= s_IDLE;
        end else begin
            case (r_SM_Main)
                s_IDLE: begin
                    o_Rx_DV       <= 1'b0;
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0;

                    if (r_Rx_Data == 1'b0) // Detect start bit
                        r_SM_Main <= s_RX_START_BIT;
                end

                s_RX_START_BIT: begin
                    // Sample at middle of start bit
                    if (r_Clock_Count == (CLKS_PER_BIT-1)/2) begin
                        if (r_Rx_Data == 1'b0) begin
                            r_Clock_Count <= 0;
                            r_SM_Main     <= s_RX_DATA_BITS;
                        end else begin
                            r_SM_Main <= s_IDLE; // False start
                        end
                    end else begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end
                end

                s_RX_DATA_BITS: begin
                    if (r_Clock_Count < CLKS_PER_BIT-1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count          <= 0;
                        r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;

                        if (r_Bit_Index < 7) begin
                            r_Bit_Index <= r_Bit_Index + 1;
                        end else begin
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_RX_STOP_BIT;
                        end
                    end
                end

                s_RX_STOP_BIT: begin
                    if (r_Clock_Count < CLKS_PER_BIT-1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        o_Rx_DV       <= 1'b1;      // Data valid pulse
                        r_Clock_Count <= 0;
                        r_SM_Main     <= s_CLEANUP;
                    end
                end

                s_CLEANUP: begin
                    o_Rx_Byte <= r_Rx_Byte;        // Latch received byte
                    o_Rx_DV   <= 1'b0;             // End of pulse
                    r_SM_Main <= s_IDLE;
                end

                default: r_SM_Main <= s_IDLE;
            endcase
        end
    end

endmodule