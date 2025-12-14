`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module spi_fsm_ctrl(
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_tx_empty,
    input  wire       i_rx_full,
    input  wire       i_cdte,
    input  wire       i_frame_done,

    output reg        o_tx_load,
    output reg        o_tx_rd,
    output reg        o_frame_init,
    output reg        o_in_transfer,
    output reg        o_shift_en,
    output reg        o_sample_en,

    output reg [1:0]  o_state,
    output wire       o_busy
);

    localparam [1:0]
        ST_IDLE     = 2'b00,
        ST_LOAD     = 2'b01,
        ST_TRANSFER = 2'b10,
        ST_DONE     = 2'b11;

    reg [1:0] next_state;
    reg [2:0] gap_cnt;

    assign o_busy = (o_state != ST_IDLE);

    //----------------------------------------------------------------------
    // NEXT STATE + CONTROL SIGNALS
    //----------------------------------------------------------------------
    always @(*) begin
        // default
        next_state     = o_state;
        o_tx_load      = 1'b0;
        o_tx_rd        = 1'b0;
        o_frame_init   = 1'b0;
        o_in_transfer  = 1'b0;
        o_shift_en     = 1'b0;
        o_sample_en    = 1'b0;

        case (o_state)

            ST_IDLE: begin
                if (!i_tx_empty && !i_rx_full)
                    next_state = ST_LOAD;
            end

            ST_LOAD: begin
                o_tx_rd      = 1'b1;
                o_tx_load    = 1'b1;
                o_frame_init = 1'b1;
                next_state   = ST_TRANSFER;
            end

            ST_TRANSFER: begin
                o_in_transfer = 1'b1;
                o_shift_en    = 1'b1;
                o_sample_en   = 1'b1;

                if (i_frame_done) begin

                    if (!i_cdte)
                        next_state = ST_DONE;
                    else begin
                        if (!i_tx_empty && !i_rx_full)
                            next_state = ST_LOAD;
                        else
                            next_state = ST_IDLE;
                    end
                end
            end

            ST_DONE: begin
                if (gap_cnt == 3)
                    next_state = ST_IDLE;
            end

        endcase
    end

    //----------------------------------------------------------------------
    // STATE REGISTER & GAP COUNTER
    //----------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_state <= ST_IDLE;
            gap_cnt <= 3'd0;
        end else begin
            o_state <= next_state;

            if (o_state == ST_DONE) begin
                if (gap_cnt != 3'd3)
                    gap_cnt <= gap_cnt + 1'b1;
            end else begin
                gap_cnt <= 3'd0;
            end
        end
    end

endmodule
