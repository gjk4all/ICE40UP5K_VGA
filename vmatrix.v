/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off MULTIDRIVEN */

module vmatrix #(
    parameter curs_startrow = 14,
    parameter hsync_neg = 1,
    parameter vsync_neg = 1
) (
    input wire clk,
    input wire ph0,
    input wire sec_pulse,
    input wire de_in,
    input wire hs_in,
    input wire vs_in,
    input wire [4:0] row_in,
    input wire cursor_in,
    input wire [15:0] characterline_in,
    input wire [15:0] DBI,
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
    reg [7:0] color_latch = 0;
    reg [7:0] video_latch = 0;
    reg [1:0] ph2_detect = 0;
    reg [1:0] crd_detect = 0;
    reg [1:0] cwr_detect = 0;

    reg curs = 0;
    reg de2 = 0;
    wire [3:0] ccol, fcol, bcol;

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
    end
    
    always @ (posedge clk)
    begin
        // Load next character line
        if (ph0)
        begin
            //de2 <= de_in;

            if (de_in)
            begin
                // Within visible display
                {color_latch, video_latch} <= characterline_in;
                curs <= cursor_in;
            end
            else
            begin
                // Outside visible display
                {color_latch, video_latch} <= 16'd0;
                curs <= 0;
            end
        end
        else
            video_latch <= {video_latch[6:0], 1'b0};   // Shift left

        // Do controller commands
        crd_detect <= {crd_detect[0], R_CCOL};
        cwr_detect <= {cwr_detect[0], W_CCOL};

        if (crd_detect == 2'b01)
            DBO <= {8'd0, cursor_color_latch};

        if (cwr_detect == 2'b01)
            cursor_color_latch <= DBI[7:0];
    end
    
    always @ (negedge clk)
    begin
        // Output video
        if (de_in)
        begin 
            if (curs && (row_in >= curs_startrow))
                {R, RI, G, GI, B, BI} <= color_table[ccol][5:0];  // Cursor color
            else if (video_latch[7])
                {R, RI, G, GI, B, BI} <= color_table[fcol][5:0];  // FG color
            else
                {R, RI, G, GI, B, BI} <= color_table[bcol][5:0];  // BG color
        end
        else
            {R, RI, G, GI, B, BI} <= 6'd0;  // Black

        hsync <= hs_in ^ hsync_neg;
        vsync <= vs_in ^ vsync_neg;
    end
endmodule

