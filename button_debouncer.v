/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 button_debouncer.v 
 
 use flops to debounce the push button input.
 when a rising edge is detected, a one clock long active high pulse is generated.
 */
`timescale 1ns / 1ps

module button_debouncer(
    input i_clk,
    input i_button,
    output o_pressed_pulse
);

reg [3:0] rf_in = 4'h0; 
reg rf_btn = 1'b0;
reg rf_prev_btn = 1'b0;
reg rf_rising_edge = 1'b0;

always @(posedge i_clk) begin  
    rf_in <=  {rf_in[2:0], i_button};
    
    if (rf_in[3:2] == 2'b11) rf_btn <=  1'b1;
    else if (rf_in[3:2] == 2'b00) rf_btn <=  1'b0;
    else rf_btn <=  rf_btn;
   
    rf_prev_btn <=  rf_btn;
     
    if (~rf_prev_btn & rf_btn) rf_rising_edge <=  1'b1;
    else rf_rising_edge <=  1'b0;
end 

assign o_pressed_pulse = rf_rising_edge;

endmodule


