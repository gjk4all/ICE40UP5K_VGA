module charrom (
    input wire clk,
    input wire ph0,
    input wire sec_in,
    input wire de_in,
    input wire hs_in,
    input wire vs_in,
    input wire [4:0] row_in,
    input wire cursor_in,
    input wire [15:0] vramdata_in,
    output reg ph1 = 0,
    output reg sec_out = 0,
    output reg cursor = 0,
    output reg de_out = 0,
    output reg hs_out = 0,
    output reg vs_out = 0,
    output reg [4:0] row_out = 0,
    output reg cursor_out,
    output reg [15:0] characterline_out
);

    // @include verilog_charrom.list

    reg [7:0] chargen[0:4095];
    reg [1:0] ph0_detect = 0;

    initial
    begin
        $readmemh("verilog_charrom.list", chargen);
    end

    always @ (posedge clk)
    begin
        ph0_detect <= {ph0_detect[0], ph0};

        if (ph0_detect == 2'b01)
        begin
            characterline_out <= {vramdata_in[15:8], chargen[{vramdata_in[7:0], row_in[3:0]}]};

            // Ripple tru
            de_out <= de_in;
            hs_out <= hs_in;
            vs_out <= vs_in;
            row_out <= row_in;
            cursor_out <= cursor_in;

        end
            
        // Ripple tru
        ph1 <= ph0_detect[0];
        sec_out <= sec_in;
    end
endmodule
