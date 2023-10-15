module vram (
    input wire clk,
    input wire ph0,
    input wire sec_in,
    input wire de_in,
    input wire hs_in,
    input wire vs_in,
    input wire [4:0] row_in,
    input wire [12:0] video_address,
    input wire [15:0] int_address,
    input wire [5:0] int_command,
    input wire [15:0] int_data_in,
    output reg ph1 = 0,
    output reg sec_out = 0,
    output reg de_out = 0,
    output reg hs_out = 0,
    output reg vs_out = 0,
    output reg cursor = 0,
    output reg [1:0] state = 0,
    output reg [4:0] row_out = 0,
    output reg [15:0] vram_out = 0,
    output reg [15:0] int_data_out = 0
);
    // Video text RAM
    // @include verilog_memory.list
    
    reg [15:0] vram[0:4095];
    reg [12:0] cursor_address = 0;
    reg [1:0] ph0_detect = 0;
    integer counter = 0;

    initial
    begin
        $readmemh("verilog_memory.list", vram);
    end
    
    always @ (posedge clk)
    begin
        ph0_detect <= {ph0_detect[0], ph0};

        if (int_command == 0)
            state <= 0; // Release module from busses

        if (ph0_detect == 2'b01)
        begin
            vram_out <= vram[video_address[11:0]];
            cursor <= (video_address == cursor_address) ? 1 :  0;

            // Ripple thru
            de_out <= de_in;
            hs_out <= hs_in;
            vs_out <= vs_in;
            row_out <= row_in;
        end
        else if (state == 0)
        begin
            case (int_command)
                6'b100011 : begin
                    // write vram address
                    vram[int_address[11:0]] <= int_data_in;
                    cursor_address <= int_address[12:0] + 1;
                    state <= 2; // Ready
                end
                6'b010011 : begin
                    // Read vram address
                    int_data_out <= vram[int_address[11:0]];
                    state <= 3; // Ready and data is put on the databus
                end
                6'b110000 : begin
                    // initiate clear vram
                    counter <= 0;
                    cursor_address <= int_address[12:0];
                    state <= 1; // Ready
                end
            endcase
        end
        else if (state == 1)
        begin
            // Clear vram process
            if (counter < 4096)
            begin
                vram[counter] <= 0;
                counter <= counter + 1;
            end
            else
                state <= 2;
        end
        
        // Ripple thru
        ph1 <= ph0_detect[0];
        sec_out <= sec_in;
    end
endmodule

