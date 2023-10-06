/* verilator lint_off PINMISSING */

//`include "pll.v"
`include "clockgen.v"
`include "vdu.v"
`include "vram.v"
`include "charrom.v"
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
    wire clk2;
    wire ph0;
    wire ph1;
    wire ph2;
    wire ph3;
    wire sec_pulse0;
    wire sec_pulse1;
    wire sec_pulse2;
    wire sec_pulse3;
    wire de1;
    wire de2;
    wire de3;
    wire hs1;
    wire hs2;
    wire hs3;
    wire vs1;
    wire vs2;
    wire vs3;
    wire cursor2;
    wire cursor3;
    wire [4:0] row_address1;
    wire [4:0] row_address2;
    wire [4:0] row_address3;
    wire [12:0] video_address;
    wire [15:0] character_data;
    wire [15:0] videoline_data;

//    pll clock_doubler (
//        .clock_in(clk),
//        .clock_out(clk2)
//    );

    clockgen clock_generator (
        .clk(clk),
        .ph0(ph0),
        .sec_pulse(sec_pulse0)
    );

    vdu video_controller (
        .clk(clk),
        .ph0(ph0),
        .sec_in(sec_pulse0),

        .ph1(ph1),
        .sec_out(sec_pulse1),
        .de(de1),
        .hs(hs1),
        .vs(vs1),
        .row_out(row_address1),
        .video_address(video_address)
    );

    vram video_ram (
        .clk(clk),
        .ph0(ph1),
        .sec_in(sec_pulse1),
        .de_in(de1),
        .hs_in(hs1),
        .vs_in(vs1),
        .row_in(row_address1),
        .video_address(video_address),

        .ph1(ph2),
        .sec_out(sec_pulse2),
        .de_out(de2),
        .hs_out(hs2),
        .vs_out(vs2),
        .row_out(row_address2),
        .cursor(cursor2),
        .vram_out(character_data)
        //.DBO(vram_data)
    );

    charrom character_rom (
        .clk(clk),
        .ph0(ph2),
        .sec_in(sec_pulse2),
        .de_in(de2),
        .hs_in(hs2),
        .vs_in(vs2),
        .row_in(row_address2),
        .cursor_in(cursor2),
        .vramdata_in(character_data),

        .ph1(ph3),
        .sec_out(sec_pulse3),
        .de_out(de3),
        .hs_out(hs3),
        .vs_out(vs3),
        .row_out(row_address3),
        .cursor_out(cursor3),
        .characterline_out(videoline_data)
    );

    vmatrix video_matrix (
        .clk(clk),
        .ph0(ph3),
        .sec_pulse(sec_pulse3),
        .de_in(de3),
        .hs_in(hs3),
        .vs_in(vs3),
        .row_in(row_address3),
        .cursor_in(cursor3),
        .characterline_in(videoline_data),
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
