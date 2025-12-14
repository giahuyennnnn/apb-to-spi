`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Gia Huyen
// 
// Create Date: 11/26/2025 04:55:30 PM
// Design Name: 
// Module Name: interrupt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interrupt(
	output o_int,
	
	//TX
	input tx_empty,
	input tx_full,
	
	//RX
	input rx_empty,
	input rx_full,
	
	//Register
	input en_tx_empty,
	input en_tx_full,
	input en_rx_empty,
	input en_rx_full
    );
    wire int_tx_empty;   // ngat khi tx empty & enable
    wire int_tx_full;    // ngat khi tx full  & enable
    wire int_rx_empty;   // ngat khi rx empty & enable
    wire int_rx_full;    // ngat khi rx full  & enable
    assign int_tx_empty = tx_empty & en_tx_empty;
    assign int_tx_full = tx_full & en_tx_full;
    assign int_rx_empty = rx_empty & en_rx_empty;
    assign int_rx_full = rx_full & en_rx_full;
    
    assign int = int_tx_empty | int_tx_full | int_rx_empty | int_rx_full;
endmodule

