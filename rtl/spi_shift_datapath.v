`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module spi_shift_datapath(
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_cpha,
    input  wire        i_wls,
    input  wire [15:0] i_tx_data,
    input  wire [4:0]  i_bit_cnt,

    input  wire        i_tx_load,
    input  wire        i_shift_en,
    input  wire        i_sample_en,
    input  wire        i_frame_done,
    input  wire        i_frame_active,

    input  wire        i_leading_edge,
    input  wire        i_trailing_edge,

    input  wire        i_MISO,

    output reg         o_MOSI,
    output reg         o_rx_wr,
    output reg [15:0]  o_rx_data
);

    reg [15:0] tx_shift;
    reg [15:0] rx_shift;
    reg [4:0]  tx_idx;
    reg [3:0]  rx_idx;

    wire w_shift_edge  = i_cpha ? i_leading_edge  : i_trailing_edge;
    wire w_sample_edge = i_cpha ? i_trailing_edge : i_leading_edge;

    //----------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            tx_shift <= 16'h0000;
            rx_shift <= 16'h0000;
            tx_idx   <= 0;
            rx_idx   <= 0;
            o_MOSI   <= 1'b0;
            o_rx_wr  <= 1'b0;
            o_rx_data<= 16'h0000;
        end else begin
            o_rx_wr <= 1'b0;

            // LOAD TX data
            if (i_tx_load) begin
                tx_shift <= i_wls ? i_tx_data
                                  : {8'h00, i_tx_data[7:0]};
                rx_shift <= 16'h0000;
                rx_idx   <= 0;

                if (!i_cpha) begin
                    tx_idx  <= i_bit_cnt - 1;
                    o_MOSI  <= i_tx_data[i_bit_cnt-1];
                end
                else begin
                    tx_idx <= i_bit_cnt;
                end
            end

            // SHIFT MOSI
            if (i_shift_en && w_shift_edge && i_frame_active) begin
                if (tx_idx != 0) begin
                    tx_idx <= tx_idx - 1;
                    o_MOSI <= tx_shift[tx_idx-1];
                end
            end

            // SAMPLE MISO
            if (i_sample_en && w_sample_edge && i_frame_active) begin
                rx_shift <= {rx_shift[14:0], i_MISO};

                if (rx_idx != (i_bit_cnt - 1))
                    rx_idx <= rx_idx + 1'b1;
            end

            // LATCH RX
            if (i_frame_done) begin
                o_rx_data <= i_wls ? rx_shift
                                   : {8'h00, rx_shift[7:0]};
                o_rx_wr   <= 1'b1;
            end
        end
    end

endmodule
