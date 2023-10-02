/* verilator lint_off PINMISSING */

`include "clockgen.v"
`include "vdu.v"
`include "vram.v"
`include "vmatrix.v"
//`include "busswitch.v"

module main (
    input wire clk,
    output wire hsync,
    output wire vsync,
    output wire r,
    output wire ri,
    output wire g,
    output wire gi,
    output wire b,
    output wire bi
);
    wire ph0;
    wire ph1;
    wire ph2;
    wire sec_pulse;
    wire de;
    wire hs;
    wire vs;
    wire [4:0] row_address;
    wire [12:0] video_address;
    wire [15:0] video_data;
    //wire [15:0] matrix_data;
    //wire [15:0] vram_data;
    wire cursor;

    clockgen clock_generator (
        .clk(clk),
        .ph0(ph0),
        .ph1(ph1),
        .ph2(ph2),
        .sec_pulse(sec_pulse)
    );

    vdu video_controller (
        .clk(ph0),
        .DE(de),
        .HS(hs),
        .VS(vs),
        .R(row_address),
        .A(video_address)
    );

    vram video_ram (
        .R_VID(ph1),
        .VA(video_address),
        .VDO(video_data),
        .cursor(cursor)
        //.DBO(vram_data)
    );

    vmatrix video_matrix (
        .DOTCLOCK(clk),
        .ph2(ph2),
        .sec_pulse(sec_pulse),
        .DE(de),
        .HS(hs),
        .VS(vs),
        .RA(row_address),
        .VDI(video_data),
        .cursor(cursor),
        .hsync(hsync),
        .vsync(vsync),
        .R(r),
        .RI(ri),
        .G(g),
        .GI(gi),
        .B(b),
        .BI(bi)
        //.DBO(matrix_data)
    );

//    busswitch switch(
//        .DI0(matrix_data),
//        .DI1(vram_data)
//    );
endmodule
