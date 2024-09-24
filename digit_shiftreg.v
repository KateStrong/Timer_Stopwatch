/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 digit_shiftreg.v 
 
 Circular shift register for tracking which digit is being set.
 There are 4 digits 3:0, and a 1 in the corresponding shift register
 bit indicates that the digit is being edited by the user. 
 Only 1 digit is active at a time. 
 */
`timescale 1ns / 1ps

module digit_shiftreg(
    input i_clk,
    input i_shift_left,
    input i_shift_right,
    output [3:0] o_digit_select
);

reg [3:0] rf_shiftreg = 4'b0001;

always @(posedge i_clk) begin   
    if (i_shift_left) rf_shiftreg <=  {rf_shiftreg[2:0], rf_shiftreg[3]};
    else if (i_shift_right) rf_shiftreg <=  {rf_shiftreg[0], rf_shiftreg[3:1]};
    else rf_shiftreg <=  rf_shiftreg; // hold by default. 
end 

assign o_digit_select = rf_shiftreg;

endmodule


