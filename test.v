`timescale 1ns/100ps
 
`include "main.v"


module top();


reg clk = 1;

always #2 clk<=~clk;

main uut(clk
);


initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,top);
    #3000000;

    $finish;
end
    
endmodule


