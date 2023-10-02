module clockgen (
 input wire clk,
 output wire ph0,
 output wire ph1,
 output wire ph2,
 output wire sec_pulse
);
 // Clock generator
 
 integer counter = 0;
 
 assign ph0 = (counter[2:0] == 0)?1:0;
 assign ph1 = (counter[2:0] == 1)?1:0;
 assign ph2 = (counter[2:0] == 2)?1:0;
 assign sec_pulse = counter[23];
 
 always @ (posedge clk)
 begin
     counter <= counter + 1;
 end
endmodule
