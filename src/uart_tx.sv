//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
// Modified for proper reset and robust operation
//////////////////////////////////////////////////////////////////////

module uart_tx #(
   parameter CLKS_PER_BIT = 217 // 25 MHz clock example
)(
    input       i_Clock,
    input       i_Tx_DV,
    input       rst_n,
    input [7:0] i_Tx_Byte, 
    output      o_Tx_Active,
    output reg  o_Tx_Serial,
    output      o_Tx_Done
);

    // FSM states
    parameter s_IDLE         = 3'b000;
    parameter s_TX_START_BIT = 3'b001;
    parameter s_TX_DATA_BITS = 3'b010;
    parameter s_TX_STOP_BIT  = 3'b011;
    parameter s_CLEANUP      = 3'b100;

    // Registers
    reg [2:0]    r_SM_Main       = s_IDLE;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_Clock_Count = 0;
    reg [2:0]    r_Bit_Index     = 0;
    reg [7:0]    r_Tx_Data       = 0;
    reg          r_Tx_Done       = 0;
    reg          r_Tx_Active     = 0;

    // FSM
    always @(posedge i_Clock) begin
        if (!rst_n) begin
            // Proper synchronous reset
            o_Tx_Serial   <= 1'b1;    // Idle high
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            r_SM_Main     <= s_IDLE;
            r_Tx_Data     <= 8'd0;
            r_Tx_Active   <= 1'b0;
        end else begin
            case (r_SM_Main)
                s_IDLE : begin
                    o_Tx_Serial   <= 1'b1; // Idle line
                    r_Tx_Done     <= 1'b0;
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0;
                    
                    if (i_Tx_DV) begin
                        r_Tx_Active <= 1'b1;
                        r_Tx_Data   <= i_Tx_Byte;
                        r_SM_Main   <= s_TX_START_BIT;
                    end
                end

                // Start bit
                s_TX_START_BIT: begin
                    o_Tx_Serial <= 1'b0;

                    if (r_Clock_Count < CLKS_PER_BIT-1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        r_SM_Main     <= s_TX_DATA_BITS;
                    end
                end

                // Data bits
                s_TX_DATA_BITS: begin
                    o_Tx_Serial <= r_Tx_Data[r_Bit_Index];

                    if (r_Clock_Count < CLKS_PER_BIT-1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        if (r_Bit_Index < 7) begin
                            r_Bit_Index <= r_Bit_Index + 1;
                        end else begin
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_TX_STOP_BIT;
                        end
                    end
                end

                // Stop bit
                s_TX_STOP_BIT: begin
                    o_Tx_Serial <= 1'b1;

                    if (r_Clock_Count < CLKS_PER_BIT-1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        r_Tx_Done     <= 1'b1;
                        r_Tx_Active   <= 1'b0;
                        r_SM_Main     <= s_CLEANUP;
                    end
                end

                // Cleanup state for 1 clock cycle
                s_CLEANUP: begin
                    r_Tx_Done <= 1'b1;
                    r_SM_Main <= s_IDLE;
                end

                default: r_SM_Main <= s_IDLE;
            endcase
        end
    end

    assign o_Tx_Active = r_Tx_Active;
    assign o_Tx_Done   = r_Tx_Done;

endmodule