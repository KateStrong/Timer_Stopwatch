`timescale 1ns/1ps
/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 seg_driver.v 
 
 this block drives the 7 segment inputs to achieve the desired display.
 the tick input controls the refresh rate for the digits.
 the blink input is used to flash all digits at once. 
 the i_digit inputs determine the values.
*/


module seg_driver(
  input             i_clk, 
  input             i_tick,
  input             i_blink,
  input  [3:0]      i_digit0,
  input  [3:0]      i_digit1,
  input  [3:0]      i_digit2,
  input  [3:0]      i_digit3,
  output [6:0]      o_seg_l,    // 7seg display cathodes (active low).
  output [3:0]      o_an_l,     // 7seg display anodes (active low).
  output reg        o_dp_l      // 7seg display decimal point (active low).
);


// use a 4 bit shift register, shifting a low bit thru the 4 positions. 
// the shift register drives the active low AN outputs.
reg [3:0] rf_shifter = 4'b1110;

always @ (posedge i_clk) begin
    if (i_tick == 1'b1) begin
       rf_shifter <= {rf_shifter[2:0], rf_shifter[3]};
    end
    else begin
      rf_shifter <= rf_shifter;
    end
end 

assign o_an_l[3:0] = rf_shifter[3:0] | {i_blink, i_blink, i_blink, i_blink}; 

reg [6:0] rc_seg;
wire [6:0] rc_seg0;
wire [6:0] rc_seg1;
wire [6:0] rc_seg2;
wire [6:0] rc_seg3;

get_seg seg0(
  .i_in(i_digit0),
  .o_out(rc_seg0)
);

get_seg seg1(
  .i_in(i_digit1),
  .o_out(rc_seg1)
);

get_seg seg2(
  .i_in(i_digit2),
  .o_out(rc_seg2)
);

get_seg seg3(
  .i_in(i_digit3),
  .o_out(rc_seg3)
);

// cathode seg and dp depend on which anode is active (anode is active low).
// When blink is high, display is off.
always @ (*) begin
  case (rf_shifter)
    4'b1101: begin
        rc_seg[6:0] = rc_seg1[6:0] | {i_blink, i_blink, i_blink, i_blink, i_blink, i_blink, i_blink};
        o_dp_l = 1'b1;
    end 
    4'b1011: begin
        rc_seg[6:0] = rc_seg2[6:0] | {i_blink, i_blink, i_blink, i_blink, i_blink, i_blink, i_blink};
        o_dp_l = 1'b0;
    end
    4'b0111: begin
        rc_seg[6:0] = rc_seg3[6:0] | {i_blink, i_blink, i_blink, i_blink, i_blink, i_blink, i_blink}; 
        o_dp_l = 1'b1;
    end
    default: begin
        rc_seg[6:0] = rc_seg0[6:0] | {i_blink, i_blink, i_blink, i_blink, i_blink, i_blink, i_blink};
        o_dp_l = 1'b1;
    end 
  endcase
end 
assign o_seg_l = rc_seg;

endmodule	
	
  
  
