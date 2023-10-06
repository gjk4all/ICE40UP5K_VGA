module vram (
    input wire clk,
    input wire ph0,
    input wire sec_in,
    input wire de_in,
    input wire hs_in,
    input wire vs_in,
    input wire [4:0] row_in,
    input wire [12:0] video_address,
    input wire [12:0] command_address,
    input wire [15:0] databus_in,
    input wire write_vram,
    input wire read_vram,
    output reg ph1 = 0,
    output reg sec_out = 0,
    output reg de_out = 0,
    output reg hs_out = 0,
    output reg vs_out = 0,
    output reg cursor = 0,
    output reg [4:0] row_out = 0,
    output reg [15:0] vram_out = 16'h0,
    output reg [15:0] databus_out = 16'h0
);
    // Video text RAM
    // @include verilog_memory.list
    
    reg [15:0] vram[0:4096];
    reg [12:0] cursor_address = 0;
    reg [1:0] ph0_detect = 0;
    
    initial
    begin
        $readmemh("verilog_memory.list", vram);
    end
    
    always @ (posedge clk)
    begin
        ph0_detect <= {ph0_detect[0], ph0};

        case (ph0_detect)
            2'b01 : begin
                        vram_out <= vram[video_address];
                        cursor <= (video_address == cursor_address) ? 1 :  0;

                        // Ripple tru
                        de_out <= de_in;
                        hs_out <= hs_in;
                        vs_out <= vs_in;
                        row_out <= row_in;
                    end

            default : begin
                        if (write_vram)
                        begin
                            vram[command_address] <= databus_in;
                            cursor_address <= command_address;
                        end
                        else if (read_vram)
                            databus_out <= vram[command_address];
                    end
        endcase
        
        // Ripple tru
        ph1 <= ph0_detect[0];
        sec_out <= sec_in;
    end
endmodule

