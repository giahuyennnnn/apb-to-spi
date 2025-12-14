`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module spi_sclk_gen(
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_cpol,
    input  wire [7:0] i_div_val,
    input  wire [5:0] i_edge_total,

    input  wire       i_frame_init,
    input  wire       i_in_transfer,

    output reg        o_sclk,
    output reg        o_frame_done,
    output reg        o_frame_active,
    
    output wire       o_leading_edge,
    output wire       o_trailing_edge
);

    reg [8:0] div_cnt;
    reg [5:0] edge_rem;

    wire toggle = o_frame_active && (div_cnt == i_div_val);

    assign o_leading_edge  = toggle && (o_sclk == i_cpol);
    assign o_trailing_edge = toggle && (o_sclk != i_cpol);

    //----------------------------------------------------------------------
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_sclk       <= 1'b0;
            div_cnt      <= 9'd0;
            edge_rem     <= 6'd0;
            o_frame_active <= 1'b0;
            o_frame_done <= 1'b0;
        end else begin

            o_frame_done <= 1'b0;

            // bắt đầu frame
            if (i_frame_init) begin
                o_sclk       <= i_cpol;
                div_cnt      <= 9'd0;
                edge_rem     <= i_edge_total;
                o_frame_active <= 1'b1;
            end

            // không còn trong transfer
            else if (!i_in_transfer) begin
                o_sclk       = i_cpol;
                div_cnt      = 9'd0;
                edge_rem     = 6'd0;
                o_frame_active = 1'b0;
            end

            // đang tạo SCLK
            else if (o_frame_active) begin
                if (toggle) begin
                    div_cnt <= 0;
                    o_sclk  <= ~o_sclk;

                    if (edge_rem != 0) begin
                        edge_rem <= edge_rem - 1'b1;

                        if (edge_rem == 6'd1) begin
                            // kết thúc frame
                            o_frame_active <= 1'b0;
                            o_frame_done <= 1'b1;
                            o_sclk       <= i_cpol;
                        end
                    end
                end
                else begin
                    div_cnt <= div_cnt + 1'b1;
                end
            end

        end
    end
endmodule
