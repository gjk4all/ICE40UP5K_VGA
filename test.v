`timescale 1ns/1ps
 
`include "main.v"


module top();


reg clk = 1;

always #2 clk<=~clk;

main uut(clk
);


initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,top);
    #1000000;

    $finish;
end
    
endmodule


