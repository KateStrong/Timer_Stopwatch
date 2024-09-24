/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 digit_counter.v 
 
 4 bit counter holds the binary value for a digit
 */
`timescale 1ns / 1ps

module digit_counter(
    input i_clk,
    input i_reset, // active high reset
    input i_cnt_up,
    input i_cnt_dwn,
    input [3:0] i_max_count,
    output [3:0] o_digit_val
);

reg [3:0] rf_count = 4'b0000;

always @(posedge i_clk) begin 
    if (i_reset) rf_count <= 4'b0000;   
    else if (i_cnt_up) begin
         if (rf_count == i_max_count) rf_count <= 4'b0000;
         else rf_count <=  rf_count + 1'b1;
    end
    else if (i_cnt_dwn) begin
         if (rf_count == 4'b000) rf_count <= i_max_count;
         else rf_count <=  rf_count - 1'b1;
    end
    else rf_count <=  rf_count; // hold by default 
end 

assign o_digit_val = rf_count;

endmodule


