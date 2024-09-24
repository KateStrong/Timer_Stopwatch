/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 tick_generator.v 
 
 tick pulse output when counter hits max count.
 counter is reset to zero and counts up again when max count is hit.
 the tick pulse is high for one cycle of i_clk.
 */

`timescale 1ns / 1ps

module tick_generator(
    input i_clk,
    input [19:0] i_max_count,
    output o_tick_pulse
);

reg [19:0] rf_count = 20'h00000;
reg rf_tick = 1'b0; 

always @ (posedge i_clk) begin
  if (rf_count == i_max_count) begin
      rf_count <=  20'h00000;
      rf_tick  <=  1'b1;
  end
  else begin
      rf_count <=  rf_count + 1'b1;
      rf_tick  <=  1'b0;
  end
end 

assign o_tick_pulse = rf_tick;

endmodule


