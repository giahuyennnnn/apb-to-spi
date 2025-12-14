`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module spi_cs_gen(
    input  wire [1:0] i_ss,
    input  wire [1:0] i_state,

    output wire [3:0] o_SS
);

    wire [3:0] w_sel =
        (i_ss == 2'd0) ? 4'b0001 :
        (i_ss == 2'd1) ? 4'b0010 :
        (i_ss == 2'd2) ? 4'b0100 :
                         4'b1000;

    assign o_SS =
        (i_state == 2'b01 || // LOAD
         i_state == 2'b10 )  // TRANSFER
         ? ~w_sel            // active low
         : 4'b1111;

endmodule
