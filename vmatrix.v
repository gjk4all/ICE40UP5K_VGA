/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off MULTIDRIVEN */

module vmatrix #(
    parameter curs_startrow = 14
) (
    input wire DOTCLOCK,
    input wire ph2,
    input wire sec_pulse,
    input wire DE,
    input wire HS,
    input wire VS,
    input wire [4:0] RA,
    input wire [15:0] DBI,
    input wire [15:0] VDI,
    input wire cursor,
    input wire W_CCOL,
    input wire R_CCOL,
    output reg hsync,
    output reg vsync,
    output reg R,
    output reg RI,
    output reg G,
    output reg GI,
    output reg B,
    output reg BI,
    output reg [15:0] DBO
);
    // Video matrix
    // @include verilog_charrom.list
    
    reg [7:0] cursor_color_latch = 8'h70;
    reg [5:0] color_table[0:15];
    reg [7:0] chargen[0:4095];
    reg [7:0] color_latch = 0;
    reg [7:0] video_latch = 0;
    reg [1:0] ph2_detect = 0;
    reg [1:0] crd_detect = 0;
    reg [1:0] cwr_detect = 0;
    wire [11:0] char_addr;

    reg curs = 0;
    wire [3:0] ccol, fcol, bcol;

    assign char_addr = {VDI[7:0], RA[3:0]};
    assign ccol = cursor_color_latch[7:4];
    assign fcol = color_latch[7:4];
    assign bcol = color_latch[3:0];
    
    initial
    begin
        // Initialize color translation table
        color_table[0] = 6'h00;
        color_table[1] = 6'h02;
        color_table[2] = 6'h08;
        color_table[3] = 6'h0A;
        color_table[4] = 6'h20;
        color_table[5] = 6'h22;
        color_table[6] = 6'h28;
        color_table[7] = 6'h2A;
        color_table[8] = 6'h15;
        color_table[9] = 6'h03;
        color_table[10] = 6'h0C;
        color_table[11] = 6'h0F;
        color_table[12] = 6'h30;
        color_table[13] = 6'h33;
        color_table[14] = 6'h3C;
        color_table[15] = 6'h3F;
        // Initialize character generator
        $readmemh("verilog_charrom.list", chargen);
    end
    
    always @ (posedge DOTCLOCK)
    begin
        // Load next character line
        if (ph2)
        begin
            if (DE == 1)
            begin
                // Within visible display
                video_latch <= chargen[char_addr];
                color_latch <= VDI[15:8];
                curs <= cursor;
            end
            else
            begin
                // Outside visible display
                video_latch <= 8'd0;
                color_latch <= 8'd0;
                curs <= 0;
            end
        end

        // Do controller commands
        crd_detect <= {crd_detect[0], R_CCOL};
        cwr_detect <= {cwr_detect[0], W_CCOL};

        if (crd_detect == 2'b01)
            DBO <= {8'd0, cursor_color_latch};

        if (cwr_detect == 2'b01)
            cursor_color_latch <= DBI[7:0];
    end
    
    always @ (negedge DOTCLOCK)
    begin
        // Output video
        if (DE)
        begin
            if (curs && (RA >= curs_startrow))
                {R, RI, G, GI, B, BI} <= color_table[ccol][5:0];  // Cursor color
            else if ((video_latch & 8'b10000000) == 8'b10000000)
                {R, RI, G, GI, B, BI} <= color_table[fcol][5:0];    // FG color
            else
                {R, RI, G, GI, B, BI} <= color_table[bcol][5:0];    // BG color

            video_latch <= {video_latch[6:0], 1'b0};   // Shift left
        end
        else
            {R, RI, G, GI, B, BI} <= 6'd0;  // Black

        hsync <= HS;
        vsync <= VS;
    end
endmodule

