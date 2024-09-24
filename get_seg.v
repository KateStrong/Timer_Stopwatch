/*  
 ECEG 240 Final Project: Timer
 Kate Strong 
 4/13/2024
 get_seg.v
 
 Converts 4 bit binary input to 7 bit segment display string output. 
*/

`timescale 1ns/10ps

module get_seg(
  input  [3:0]      i_in,      // 4 bit binary in.
  output reg [6:0]  o_out      // 7 bit segment display string.
);

//parameter    7'bgfe_dcba; 
parameter D0 = 7'b100_0000; 
parameter D1 = 7'b111_1001;
parameter D2 = 7'b010_0100;
parameter D3 = 7'b011_0000;
parameter D4 = 7'b001_1001;
parameter D5 = 7'b001_0010;
parameter D6 = 7'b000_0010;
parameter D7 = 7'b111_1000;
parameter D8 = 7'b000_0000; 
parameter D9 = 7'b001_0000;
parameter DA = 7'b000_1000;
parameter DB = 7'b000_0011;
parameter DC = 7'b100_0110;
parameter DD = 7'b010_0001;
parameter DE = 7'b000_0110;
parameter DF = 7'b000_1110;


always @ (*) begin
  case (i_in)
    4'h0:     o_out = D0;
    4'h1:     o_out = D1;
    4'h2:     o_out = D2;
    4'h3:     o_out = D3;
    4'h4:     o_out = D4;
    4'h5:     o_out = D5;
    4'h6:     o_out = D6;
    4'h7:     o_out = D7;
    4'h8:     o_out = D8;
    4'h9:     o_out = D9; 
    4'hA:     o_out = DA;
    4'hB:     o_out = DB;
    4'hC:     o_out = DC;
    4'hD:     o_out = DD;
    4'hE:     o_out = DE;
    4'hF:     o_out = DF;
    default:  o_out = 7'b0111111;
	endcase
end 
endmodule	
	
  
  
