/* verilator lint_off CASEINCOMPLETE */

module vdu #(
	parameter hfront_porch = 2,
	parameter hsync_length = 12,
	parameter hback_porch = 6,
	parameter hactive_video = 80,
	parameter row_character = 16,
	parameter visible_lines = 30,
	parameter vfront_porch = 10,
	parameter vsync_length = 2,
	parameter vback_porch = 33
) (
	input wire clk,
    input wire ph0,
    input wire sec_in,
    output reg ph1 = 0,
    output reg sec_out = 0,
	output reg de = 0,
	output reg hs = 0,
	output reg vs = 0,
	output wire [4:0] row_out,
	output reg [12:0] video_address
);
	// 6845 VDU
	
	reg [7:0] column = 0;
	reg [4:0] row = 0;
	reg [7:0] line = 0;
	reg [10:0] scanline = 0;
    reg [1:0] ph0_detect = 0;
	
	assign row_out = row;             // Character row address
	
	always @ (posedge clk)
	begin
        ph0_detect <= {ph0_detect[0], ph0};
        
        case (ph0_detect)
            2'b01 : begin
	                    video_address <= {line[6:0], 6'b0} + {1'b0, line, 4'b0} + {5'b0, column};  // Ram address of current position
	                    de <= ((column < hactive_video)?1:0) & ((line < visible_lines)?1:0);

                	    // Set horizontal signals
                	    if (column < hactive_video + hfront_porch)
                	        hs <= 0;
                	    else if (column < hactive_video + hfront_porch + hsync_length)
                	        hs <= 1;
                	    else
                	        hs <= 0;
	    
                	    // Set vertical signals
                	    if (scanline < (row_character * visible_lines) + vfront_porch)
                	        vs <= 0;
                	    else if (scanline < (row_character * visible_lines) + vfront_porch + vsync_length)
                	        vs <= 1;
                	    else
                	        vs <= 0;
/*                    end

            2'b10 : begin */
                   	    // update counters
	                    if (column < hactive_video + hfront_porch + hsync_length + hback_porch - 1)
                	        column <= column + 1;
                	    else
                        begin
                	        column <= 0;
                	        if (row < row_character - 1)
                	            row <= row + 1;
                	        else
                	        begin
                	            row <= 0;
                	            if (line < visible_lines - 1)
                	                line <= line + 1;
                	        end

                            if (scanline < (row_character * visible_lines) + vfront_porch + vsync_length + vback_porch - 1)
                                scanline <= scanline + 1;
                            else
                            begin
                                scanline <= 0;
                                row <= 0;
                                line <= 0;
                            end
                	    end
                    end
        endcase

        // ripple tru latches
        ph1 <= ph0_detect[0];
        sec_out <= sec_in;
	end
endmodule
