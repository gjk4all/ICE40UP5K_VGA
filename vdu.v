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
	output wire DE,
	output reg HS = 0,
	output reg VS = 0,
	output wire [4:0] R,
	output wire [12:0] A
);
	// 6845 VDU
	
	reg [7:0] column = 0;
	reg [4:0] row = 0;
	reg [7:0] line = 0;
	reg [10:0] scanline = 0;
	
	//assign DE = h_en & v_en;    // Display enable, visible area is valid
	assign DE = ((column < hactive_video)?1:0) & ((line < visible_lines)?1:0);
	assign R = row;             // Character row address
	assign A = {line[6:0], 6'b0} + {1'b0, line, 4'b0} + {5'b0, column};  // Ram address of current position
	
	always @ (posedge clk)
	begin
	    // Set horizontal signals
	    if (column < hactive_video + hfront_porch - 1)
	        HS <= 0;
	    else if (column < hactive_video + hfront_porch + hsync_length - 1)
	        HS <= 1;
	    else
	        HS <= 0;
	    
	    // Set vertical signals
	    if (scanline < (row_character * visible_lines) + vfront_porch)
	        VS <= 0;
	    else if (scanline < (row_character * visible_lines) + vfront_porch + vsync_length)
	        VS <= 1;
	    else
	        VS <= 0;
	    
	end

	always @ (negedge clk)
	begin
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
	            if (line < visible_lines)
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
endmodule
