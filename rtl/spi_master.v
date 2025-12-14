`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module spi_master(
    input  wire        i_clk,
    input  wire        i_rst_n,

    input  wire [7:0]  i_div_val,
    input  wire        i_cpol,
    input  wire        i_cpha,
    input  wire        i_wls,
    input  wire        i_cdte,
    input  wire [1:0]  i_ss,
    output wire        o_busy,

    input  wire [15:0] i_tx_data,
    input  wire        i_tx_empty,
    input  wire        i_tx_full,
    output wire [15:0] o_rx_data,
    input  wire        i_rx_empty,
    input  wire        i_rx_full,
    output wire        o_tx_rd,
    output wire        o_rx_wr,

    input  wire        i_MISO,
    output wire        o_MOSI,
    output wire        o_SCLK,
    output wire [3:0]  o_SS
);

    wire [1:0] w_state;
    wire       w_tx_load, w_tx_rd, w_frame_init, w_in_transfer;
    wire       w_shift_en, w_sample_en;
    wire       w_leading_edge, w_trailing_edge, w_frame_done, w_frame_active;

    wire [4:0] bit_cnt  = i_wls ? 5'd16 : 5'd8;
    wire [5:0] edge_cnt = {bit_cnt,1'b0};

    //----------------------------------------------------------------------
    // FSM
    //----------------------------------------------------------------------
    spi_fsm_ctrl FSM(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_tx_empty(i_tx_empty),
        .i_rx_full(i_rx_full),
        .i_cdte(i_cdte),
        .i_frame_done(w_frame_done),

        .o_tx_load(w_tx_load),
        .o_tx_rd(o_tx_rd),
        .o_frame_init(w_frame_init),
        .o_in_transfer(w_in_transfer),
        .o_shift_en(w_shift_en),
        .o_sample_en(w_sample_en),

        .o_state(w_state),
        .o_busy(o_busy)
    );

    //----------------------------------------------------------------------
    // SCLK generator
    //----------------------------------------------------------------------
    spi_sclk_gen SCLK_GEN(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cpol(i_cpol),
        .i_div_val(i_div_val),
        .i_edge_total(edge_cnt),

        .i_frame_init(w_frame_init),
        .i_in_transfer(w_in_transfer),

        .o_sclk(o_SCLK),
        .o_frame_done(w_frame_done),
        .o_frame_active(w_frame_active),
        .o_leading_edge(w_leading_edge),
        .o_trailing_edge(w_trailing_edge)
    );

    //----------------------------------------------------------------------
    // Shift datapath
    //----------------------------------------------------------------------
    spi_shift_datapath SHIFT(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cpha(i_cpha),
        .i_wls(i_wls),
        .i_tx_data(i_tx_data),
        .i_bit_cnt(bit_cnt),

        .i_tx_load(w_tx_load),
        .i_shift_en(w_shift_en),
        .i_sample_en(w_sample_en),
        .i_frame_done(w_frame_done),
        .i_frame_active(w_frame_active),

        .i_leading_edge(w_leading_edge),
        .i_trailing_edge(w_trailing_edge),

        .i_MISO(i_MISO),
        .o_MOSI(o_MOSI),
        .o_rx_wr(o_rx_wr),
        .o_rx_data(o_rx_data)
    );

    //----------------------------------------------------------------------
    // Chip Select
    //----------------------------------------------------------------------
    spi_cs_gen CS(
        .i_ss(i_ss),
        .i_state(w_state),
        .o_SS(o_SS)
    );

endmodule
