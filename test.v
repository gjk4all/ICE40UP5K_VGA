`timescale 1ns/100ps
 
`include "main.v"


module top();


reg clk = 1;
reg [3:0] ex_addr = 0;
reg [7:0] db_out;
wire [7:0] db_in;
wire wait_sig;
reg ncs = 1;
reg nwr = 1;
reg nrd = 1;

always #2 clk<=~clk;

main uut(
    .clk(clk),
    .nrd(nrd),
    .nwr(nwr),
    .ncs(ncs),
    .wait_sig(wait_sig),
    .ext_address(ex_addr),
    .db_in(db_out),
    .db_out(db_in)
);

function void wrdata(input [3:0] addr, input [7:0] data);
    ex_addr = addr;
    db_out = data;
    ncs = 0;
    nwr = 0;
    #20
    ncs = 1;
    nwr = 1;
endfunction

function void rddata(input [3:0] addr);
    ex_addr = addr;
    db_out = 0;
    ncs = 0;
    nrd = 0;
    #20
    ncs = 1;
    nrd = 1;
endfunction

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,top);
    #40 wrdata(2, 8'h01);
    #40 wrdata(2, 8'h01);
    #40 rddata(2);
    #40 rddata(0);
    #40 rddata(2);
    #40 rddata(2);
    #40 wrdata(3, 8'h42);
    #40 wrdata(3, 8'h43);
    #40 rddata(0);
    #40 wrdata(3, 8'h44);
    #40 wrdata(2, 8'h01);
    #40 wrdata(2, 8'h01);
    #40 rddata(3);
    #40 rddata(0);
    #40 rddata(3);
    #40 rddata(3);
    #40 wrdata(0, 0);
    #40 rddata(0);
    #40 wrdata(3, 8'h45);
    #30000;

    $finish;
end
    
endmodule


