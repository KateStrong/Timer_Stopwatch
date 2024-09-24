Digital System Design Final Project: Verilog Timer/Sotopwach
Notes on use and code convention:

 The time is displayed on the seven segment display, where the left two digits represent the minutes, and 
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
