/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 clock_divider.v 
 
 Output clock frequency has 50% duty cycle and is lower than the input clock frequecy.
 The output frequency uses a counter to divide down the input clock.
 The counter counts up to the value specified by the max_count input,
 and then the output clock is toggled.  
 Output_frequency = input_frequency / (2*max_count). 
 */

`timescale 1ns / 1ps

module clock_divider(
    input i_clk,
    input i_reset_l,
    input [19:0] i_max_count,
    output o_clk
);

reg [19:0] rf_count = 20'h00000;
reg clk = 1'b0; 

always @ (posedge i_clk) begin
    if (~i_reset_l) begin
        clk <= 1'b0;
        rf_count <= 20'h00000;
    end    
    else begin 
        if (rf_count == i_max_count) begin
            rf_count <= 20'h00000;
            clk  <= ~clk;
        end
        else begin
            rf_count <= rf_count + 1'b1;
            clk  <= clk;
        end
    end 
end 

assign o_clk = clk;

endmodule


