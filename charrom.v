module charrom (
    input wire ph1,
    input wire [4:0] row_address,
    input wire [15:0] vdi,
    output reg [15:0] vdo
);

    // @include verilog_charrom.list

    reg [7:0] chargen[0:4095];

    initial
    begin
        $readmemh("verilog_charrom.list", chargen);
    end

    always @ (negedge ph1)
        vdo <= {vdi[15:8], chargen[{vdi[7:0], row_address[3:0]}]};

endmodule
