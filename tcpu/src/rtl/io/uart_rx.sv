//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
module uart_rx #(
    parameter CLKS_PER_BIT = 217 // 25 mHZ
)(
    input        i_Clock,
    input        i_Rx_Serial,
    output reg   o_Rx_DV,
    output reg [7:0] o_Rx_Byte
);

// State machine states
localparam s_IDLE         = 3'b000;
localparam s_RX_START_BIT = 3'b001;
localparam s_RX_DATA_BITS = 3'b010;
localparam s_RX_STOP_BIT  = 3'b011;
localparam s_CLEANUP      = 3'b100;

// Registers
reg r_Rx_Data_R = 1'b1;
reg r_Rx_Data   = 1'b1;

// Width for clock counter to cover CLKS_PER_BIT
localparam CLK_CNT_WIDTH = $clog2(CLKS_PER_BIT);
reg [CLK_CNT_WIDTH-1:0] r_Clock_Count = 0;

reg [2:0]  r_Bit_Index = 0;  // 8 bits total
reg [7:0]  r_Rx_Byte   = 0;
reg [2:0]  r_SM_Main   = s_IDLE;

// Double-register input to avoid metastability
always @(posedge i_Clock) begin
    r_Rx_Data_R <= i_Rx_Serial;
    r_Rx_Data   <= r_Rx_Data_R;
end

// RX state machine
always @(posedge i_Clock) begin
    case (r_SM_Main)
        s_IDLE: begin
        o_Rx_DV       <= 1'b0;
        r_Clock_Count <= 0;
        r_Bit_Index   <= 0;

        if (r_Rx_Data == 1'b0)
            r_SM_Main <= s_RX_START_BIT;
        end

        s_RX_START_BIT: begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2) begin
                if (r_Rx_Data == 1'b0) begin
                    r_Clock_Count <= 0;
                    r_SM_Main     <= s_RX_DATA_BITS;
                end else
                    r_SM_Main <= s_IDLE;
            end else begin
                r_Clock_Count <= r_Clock_Count + 'd1;
            end
        end

        s_RX_DATA_BITS: begin
            if (r_Clock_Count < CLKS_PER_BIT-1) begin
                r_Clock_Count <= r_Clock_Count + 'd1;
            end else begin
                    r_Clock_Count           <= 0;
                    r_Rx_Byte[r_Bit_Index]  <= r_Rx_Data;
                if (r_Bit_Index < 7) begin
                    r_Bit_Index <= r_Bit_Index + 'd1;
                end else begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                end
            end
        end

        s_RX_STOP_BIT: begin
            if (r_Clock_Count < CLKS_PER_BIT-'d1) begin
                r_Clock_Count <= r_Clock_Count + 'd1;
            end else begin
                o_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
            end
        end

        s_CLEANUP: begin
            r_SM_Main <= s_IDLE;
            o_Rx_DV   <= 1'b0;
            o_Rx_Byte <= r_Rx_Byte;
        end

        default: r_SM_Main <= s_IDLE;
    endcase
end

endmodule
