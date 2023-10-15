`define COMMAND_CLEAR_VRAM 0x80


module control (
    input wire clk,
    input wire nrd,
    input wire nwr,
    input wire ncs,
    input wire [1:0] state,
    input wire [3:0] ext_address,
    input wire [7:0] ext_data_in,
    input wire [15:0] int_data_in,
    output reg [7:0] ext_data_out = 0,
    output reg [15:0] int_data_out = 0,
    output reg [15:0] int_address = 0,
    output reg [5:0] int_command = 0,
    output reg wait_sig = 0,
    output reg int_sig = 0
);

    reg [1:0] rd_detect = 0;
    reg [1:0] wr_detect = 0;
    reg [1:0] wait_detect = 0;
    reg [7:0] default_color = 8'h70;
    reg [5:0] last_command = 0;
    reg [15:0] data_buffer;
    reg [15:0] vram_addr_buffer;
    reg [15:0] color_addr_buffer;
    wire [5:0] command;

    // Construct internal command from RD, WR and external address
    assign command = (ncs == 0) ? {~nwr, ~nrd, ext_address} : 0;

    always @ (posedge clk)
    begin
        // state change detection
        rd_detect <= {rd_detect[0], ~nrd};
        wr_detect <= {wr_detect[0], ~nwr};
        wait_detect <= {wait_detect[0], wait_sig};

        // Check on CS low and a falling edge on RD, WR or WAIT to initiate command
        if ((ncs == 0) && ((rd_detect == 2'b01) || (wr_detect == 2'b01) || (wait_detect == 2'b10)))
        begin
            case (command)
                6'b010000 : begin
                    // Read status byte
                    ext_data_out <= {(state == 1), 7'b0000000};
                    last_command <= 0;
                end
                6'b100000 : begin
                    // Write command byte
                    // Temporary the only thing happening here is clear the
                    // screen
                    int_command <= 6'b110000; // Clear screen
                    vram_addr_buffer <= 0;
                    last_command <= 0;
                end
                6'b010010 : begin
                    // Read character address register
                    if (command == last_command)
                    begin
                        ext_data_out <= vram_addr_buffer[15:8];
                        last_command <= 0;
                    end
                    else
                    begin
                        ext_data_out <= vram_addr_buffer[7:0];
                        last_command <= command;
                    end
                end
                6'b100010 : begin
                    // Write character address register
                    if (command == last_command)
                    begin
                        vram_addr_buffer[15:8] <= ext_data_in;
                        last_command <= 0;
                    end
                    else
                    begin
                        vram_addr_buffer[7:0] <= ext_data_in;
                        last_command <= command;
                    end
                end
                6'b010011 : begin
                    // Read character from vram
                    // Defer to vram module
                    if (state == 1)
                    begin
                        // Something is still busy, assert WAIT signal
                        wait_sig <= 1;
                    end
                    else if (command == last_command)
                    begin
                        ext_data_out <= data_buffer[15:8];
                    end
                    else
                    begin
                        int_address <= vram_addr_buffer;
                        int_command <= command;
                    end

                    last_command <= 0;
                end
                6'b100011 : begin
                    // Write character to vram
                    // Defer to vram module
                    if (state == 1)
                    begin
                        // Something is still busy, assert WAIT signal
                        wait_sig <= 1;
                    end
                    else
                    begin
                        int_address <= vram_addr_buffer;
                        int_data_out <= {default_color, ext_data_in};
                        int_command <= command;
                    end
                end
                6'b010100 : begin
                    // Read default character color
                    ext_data_out <= default_color;
                    last_command <= 0;
                end
                6'b100100 : begin
                    // Write default character color
                    default_color <= ext_data_in;
                    last_command <= 0;
                end
                6'b010101 : begin
                    // Read cursor color and attributes
                    // Defer to vmatrix module
                    int_command <= command;
                end
                6'b100101 : begin
                    // Write cursor color and attributes
                    // Defer to vmatrix module
                    int_command <= command;
                end
            endcase
        end

        // If state[1] becomes 1, some internal command finished
        else if ((state[1]) && (int_command != 0))
        begin
            last_command <= command;
            wait_sig <= 0;
            int_command <= 0;

            case (command)
                6'b010011 : begin
                    // Read character from vram
                    if (last_command == 0)
                    begin
                        data_buffer <= int_data_in;
                        ext_data_out <= int_data_in[7:0];
                        vram_addr_buffer <= vram_addr_buffer + 1;
                    end
                end
                6'b100011 : begin
                    // Write character to vram
                    vram_addr_buffer <= vram_addr_buffer + 1;
                    last_command <= 0;
                end
                6'b010101 : begin
                    // Read cursor color and attributes
                    ext_data_out <= int_data_in[7:0];
                    last_command <= 0;
                end
                6'b100101 : begin
                    // Write cursor color and attributes
                    last_command <= 0;
                end
                default : begin
                    last_command <= 0;
                end
            endcase
                
        end
    end

endmodule
