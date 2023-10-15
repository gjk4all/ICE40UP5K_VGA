module datamux (
    input clk,
    input wire [15:0] int_data_1,
    input wire [1:0] state_1,
    input wire [15:0] int_data_2,
    input wire [1:0] state_2,
    output reg [15:0] int_data_out,
    output wire [1:0] state
);

    assign state = state_1 | state_2;

    // Databus matrix
    always @ (posedge clk)
    begin
        if (state_1 != 0)
            int_data_out = int_data_1;
        else if (state_2 != 0)
            int_data_out = int_data_2;
    end
    
endmodule
