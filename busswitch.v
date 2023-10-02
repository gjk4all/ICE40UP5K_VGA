module busswitch (
    input clk,
    input wire [15:0] DI0,
    input wire [15:0] DI1,
    input wire [3:0] CMD,
    output reg [15:0] DO
);
    // Databus matrix
    always @ (posedge clk)
    begin
        case (CMD)
            4'h2    : DO <= DI0;
            4'h3    : DO <= DI1;
            default : DO <= 0;
        endcase
    end
    
endmodule
