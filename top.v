/*  
 ECEG 240 Final Project: Timer and Stopwatch
 Kate Strong, Kona Glenn, Gordon Rose
 4/28/2024
 top.v 
 
 This the top level block for the timer and stop watch project. The time is displayed on the 
 seven segment display, where the left two digits represent the minutes, and 
 the right two digits represent the seconds, separated by a decimal point. 
 
 Switch 9 is used to toggle between timer and stopwatch mode. 
 Led 9 is lit when in stopwatch mode.
 
 In timer mode:

 Using the left, right, up, and down push buttons, the user enters the time in minutes and seconds, 
 one digit at a time. LEDs 1, 2, 3, or 4 will be lit up depending on which digit is being set.

 The center button is used to toggle between set mode and count down mode - i.e. start/pause the timer. 
 When timer counts all the way down to "00.00" and finishes, the seven segment display flashes. 
 
 In stopwatch mode:
 
 The center button is used to toggle between pause and count up mode - i.e. start/stop the stopwatch. 
 The right button is used to reset the stopwatch to "00.00".

 LEDs 0, 5-8, and 12-15 are used for debug and can be ignored.
 
 i_ and o_ name prefixes designate input and output module ports.
 w_ prefix designates a wire.
 rc_ prefix designates a combinatorial register. 
 rf_ prefix designates a flip flopped register. 
 _l suffix designates active low. 
*/

`timescale 1ns/10ps

module top(
  input             i_clk,   // 100Mhz
  input             i_btnC,     
  input             i_btnL,     
  input             i_btnR,     
  input             i_btnU,     
  input             i_btnD,     
  input [15:0]      i_sw,       
  output [15:0]     o_led,       
  output [6:0]      o_seg_l,    
  output [3:0]      o_an_l,   
  output            o_dp_l   
);

// Define states
parameter TIMER_SET = 3'b000; 
parameter TIMER_RUN = 3'b001;
parameter TIMER_DONE = 3'b010;
parameter STOPWATCH_STOPPED = 3'b011; 
parameter STOPWATCH_RUNNING = 3'b100; 
parameter STOPWATCH_RESET =   3'b101;   

reg [2:0] state = TIMER_SET;
reg [2:0] next_state = TIMER_SET;

reg rf_mode = 1'b0; // 0 is timer mode, 1 is stop watch mode.
assign o_led[9] = rf_mode; // LED 9 reflects the state of the mode switch.

// The master clk for top.v is a 1KHz clk derived from the 100 MHz input using counter. 
wire w_clk_1KHz;
reg rf_debug = 1'b0;        // 1 sec on, 1 sec off pulse for debug.
wire w_tick_1s;             // ticks are high for 1ms. 
wire w_tick_2ms;            // ticks are high for 1ms. 
wire w_blink_500ms;         // high for 500ms, low for 500ms. Used to blink 7seg display.
reg rc_blink_enable = 1'b0; // active high blinker enable controlled by FSM.
reg rc_reset_digits = 1'b0; // active high reset for digits controlled by FSM.

clock_divider clock_divider0(
    .i_clk(i_clk),
    .i_reset_l(1'b1),
    .i_max_count(20'h0C350), 
    .o_clk(w_clk_1KHz)
);
clock_divider clock_divider1(
    .i_clk(w_clk_1KHz),
    .i_reset_l(rc_blink_enable),
    .i_max_count(20'h001F4), 
    .o_clk(w_blink_500ms)
);

tick_generator tick_generator0( 
    .i_clk(w_clk_1KHz),
    .i_max_count(20'h003E8),
    .o_tick_pulse(w_tick_1s)
);
tick_generator tick_generator1( 
    .i_clk(w_clk_1KHz),
    .i_max_count(20'h00002),
    .o_tick_pulse(w_tick_2ms)
);

// Debug only. 
always @ (posedge w_tick_1s) begin
    rf_debug <= ~rf_debug;
end 
assign o_led[0] = rf_debug; 


// Push buttons are electrically noisy and need to be debounced. 
wire w_btnC;
button_debouncer button_debouncerC(
    .i_clk(w_clk_1KHz),
    .i_button(i_btnC),
    .o_pressed_pulse(w_btnC)
);
wire w_btnL;
button_debouncer button_debouncerL(
    .i_clk(w_clk_1KHz),
    .i_button(i_btnL),
    .o_pressed_pulse(w_btnL)
);
wire w_btnR;
button_debouncer button_debouncerR(
    .i_clk(w_clk_1KHz),
    .i_button(i_btnR),
    .o_pressed_pulse(w_btnR)
);
wire w_btnU;
button_debouncer button_debouncerU(
    .i_clk(w_clk_1KHz),
    .i_button(i_btnU),
    .o_pressed_pulse(w_btnU)
);
wire w_btnD;
button_debouncer button_debouncerD(
    .i_clk(w_clk_1KHz),
    .i_button(i_btnD),
    .o_pressed_pulse(w_btnD)
);


// digit selected by using left and right buttons. 
wire [3:0] w_dsel; 
digit_shiftreg digit_shiftreg0(
    .i_clk(w_clk_1KHz),
    .i_shift_left(w_btnL),
    .i_shift_right(w_btnR),
    .o_digit_select(w_dsel)
);
assign o_led[4:1] = w_dsel; // LEDs for debug. 


// Digit values selected by using up and down buttons. 
reg [3:0] rc_cnt_up;    
reg [3:0] rc_cnt_dwn;
wire [3:0] w_dval0;     // right most digit.
wire [3:0] w_dval1;
wire [3:0] w_dval2;
wire [3:0] w_dval3;     // left most digit. 
digit_counter digit_counter0(
    .i_clk(w_clk_1KHz),
    .i_reset(rc_reset_digits),
    .i_cnt_up(rc_cnt_up[0]),
    .i_cnt_dwn(rc_cnt_dwn[0]),
    .i_max_count(4'b1001),      // wraps at 9 and 0. 
    .o_digit_val(w_dval0)       // seconds 1's place.
);
digit_counter digit_counter1(
    .i_clk(w_clk_1KHz),
    .i_reset(rc_reset_digits),
    .i_cnt_up(rc_cnt_up[1]),
    .i_cnt_dwn(rc_cnt_dwn[1]),
    .i_max_count(4'b0101),      // wraps at 5 and 0.
    .o_digit_val(w_dval1)       // seconds 10's place.
);
digit_counter digit_counter2(
    .i_clk(w_clk_1KHz),
    .i_reset(rc_reset_digits),
    .i_cnt_up(rc_cnt_up[2]),
    .i_cnt_dwn(rc_cnt_dwn[2]),
    .i_max_count(4'b1001),      // wraps at 9 and 0.
    .o_digit_val(w_dval2)       // minutes 1's place.
);
digit_counter digit_counter3(
    .i_clk(w_clk_1KHz),
    .i_reset(rc_reset_digits),
    .i_cnt_up(rc_cnt_up[3]),
    .i_cnt_dwn(rc_cnt_dwn[3]),
    .i_max_count(4'b1001),      // wraps at 9 and 0.
    .o_digit_val(w_dval3)       // minutes 10's place.
);


// Combintorial logic for digits.
// This is the FSM output always block. 
// Handles setting, counting down, and blinking of the digits. 
reg [3:0] rc_dval; // used for debug.
always @ (*) begin 
    case (w_dsel) //debug.
        4'b0001:  rc_dval = w_dval0;
        4'b0010:  rc_dval = w_dval1;
        4'b0100:  rc_dval = w_dval2;
        default:  rc_dval = w_dval3;
    endcase 
    
    rc_blink_enable = 1'b0;
    rc_reset_digits = 1'b0;
    case(state) 
        TIMER_SET: begin // user is able to set a time on the 7 segment display
            rc_cnt_dwn[0] = w_btnD & w_dsel[0];
            rc_cnt_dwn[1] = w_btnD & w_dsel[1];
            rc_cnt_dwn[2] = w_btnD & w_dsel[2];
            rc_cnt_dwn[3] = w_btnD & w_dsel[3];
  
            rc_cnt_up[0] = w_btnU & w_dsel[0];
            rc_cnt_up[1] = w_btnU & w_dsel[1];
            rc_cnt_up[2] = w_btnU & w_dsel[2];
            rc_cnt_up[3] = w_btnU & w_dsel[3];
        end
        TIMER_RUN: begin // the time counts down to 00:00
            rc_cnt_dwn[0] = w_tick_1s;
            rc_cnt_dwn[1] = w_tick_1s && (w_dval0 == 4'h0);
            rc_cnt_dwn[2] = w_tick_1s && (w_dval0 == 4'h0) && (w_dval1 == 4'h0);
            rc_cnt_dwn[3] = w_tick_1s && (w_dval0 == 4'h0) && (w_dval1 == 4'h0) && (w_dval2 == 4'h0);
  
            rc_cnt_up[3:0] = 4'h0;
        end
        TIMER_DONE: begin // the time reaches 00:00 and the display blinks
            rc_cnt_up[3:0] = 4'h0;
            rc_cnt_dwn[3:0] = 4'h0;
            rc_blink_enable = 1'b1;
        end  
        STOPWATCH_STOPPED: begin // time on the display is not changing
            rc_cnt_up[3:0] = 4'h0;
            rc_cnt_dwn[3:0] = 4'h0; 
        end 
        STOPWATCH_RUNNING: begin // time on the display is counting up every second
            rc_cnt_up[0] = w_tick_1s;
            rc_cnt_up[1] = w_tick_1s && (w_dval0 == 4'h9);
            rc_cnt_up[2] = w_tick_1s && (w_dval0 == 4'h9) && (w_dval1 == 4'h5);
            rc_cnt_up[3] = w_tick_1s && (w_dval0 == 4'h9) && (w_dval1 == 4'h5) && (w_dval2 == 4'h9);
            rc_cnt_dwn[3:0] = 4'h0; 
        end 
        STOPWATCH_RESET: begin // time is reset to 00:00
            rc_cnt_up[3:0] = 4'h0;
            rc_cnt_dwn[3:0] = 4'h0; 
            rc_reset_digits = 1'b1;
        end  
        default: begin
            rc_cnt_up[3:0] = 4'h0;
            rc_cnt_dwn[3:0] = 4'h0;
        end 
    endcase
end 
assign o_led[15:12] = rc_dval; // used for debug.


// Lower level block takes binary digits and turns them into a form appropriate for the 7seg display. 
seg_driver seg_driver0(
  .i_clk(w_clk_1KHz), 
  .i_tick(w_tick_2ms),
  .i_blink(w_blink_500ms),
  .i_digit0(w_dval0),
  .i_digit1(w_dval1),
  .i_digit2(w_dval2),
  .i_digit3(w_dval3),
  .o_seg_l(o_seg_l),    // 7seg display cathodes (active low).
  .o_an_l(o_an_l),     // 7seg display anodes (active low).
  .o_dp_l(o_dp_l)     // 7seg display decimal point (active low).
);


// Logic for FSM state transition. 
always @(*) begin 
    case(state) 
        TIMER_SET: begin 
            if (rf_mode) next_state = STOPWATCH_STOPPED; // can use switch 9 to switch to stopwatch mode
            else if (w_btnC) next_state = TIMER_RUN; // center button starts the timer
            else next_state = TIMER_SET;
        end
        TIMER_RUN: begin
            if (rf_mode) next_state = STOPWATCH_STOPPED; // can use switch 9 to switch to stopwatch mode
            else if (w_btnC) next_state = TIMER_SET; // center button stops the timer
            else if (w_dval0 == 4'h0 && w_dval1 == 4'h0 && w_dval2 == 4'h0 && w_dval3 == 4'h0) next_state = TIMER_DONE; // hits 00:00
            else next_state = TIMER_RUN;
        end
        TIMER_DONE: begin
            if (rf_mode) next_state = STOPWATCH_STOPPED; // can use switch 9 to switch to stopwatch mode
            else if (w_btnC) next_state = TIMER_SET; // can set a new timer with the center button
            else next_state = TIMER_DONE;
        end  
        STOPWATCH_STOPPED: begin
            if (~rf_mode) next_state = TIMER_SET; // can use switch 9 to switch to timer mode
            else if (w_btnC) next_state = STOPWATCH_RUNNING; // start stopwatch with center button
            else if (w_btnR) next_state = STOPWATCH_RESET; // reset stopwatch with right button
            else next_state = STOPWATCH_STOPPED;
        end 
        STOPWATCH_RUNNING: begin
            if (~rf_mode) next_state = TIMER_SET; // can use switch 9 to switch to timer mode
            else if (w_btnC) next_state = STOPWATCH_STOPPED; // pause stopwatch with center button
            else if (w_btnR) next_state = STOPWATCH_RESET; // reset stopwatch with right button
            else next_state = STOPWATCH_RUNNING;
        end 
        STOPWATCH_RESET: begin
            if (~rf_mode) next_state = TIMER_SET; // can use switch 9 to switch to timer mode
            else if (w_btnC) next_state = STOPWATCH_RUNNING; // start stopwatch with center button
            else next_state = STOPWATCH_RESET;
        end   
        default: begin
            next_state = TIMER_SET;
        end 
    endcase
end
assign o_led[7:5] = state; // used for debug.
assign o_led[8] = w_blink_500ms; // used for debug.  

// FSM state register update.
always @(posedge w_clk_1KHz) begin 
    state <= next_state; 
    rf_mode <= i_sw[9];
end
endmodule	
	
  
  
