module vram (
    input wire [12:0] VA,
    input wire R_VID,
    input wire [12:0] CA,
    input wire [15:0] DBI,
    input wire W_MEM,
    input wire R_MEM,
    output reg [15:0] VDO = 16'h0,
    output reg cursor = 0,
    output reg [15:0] DBO = 16'h0
);
    // Video text RAM
    // @include verilog_memory.list
    
    reg [15:0] vram[0:4096];
    reg [12:0] cursor_address = 0;
    
    initial
    begin
        $readmemh("verilog_memory.list", vram);
    end
    
    always @ (posedge R_VID) // Clock on PH1
    begin
        VDO <= vram[VA];
        if (VA == cursor_address)
            cursor <= 1;
        else
            cursor <= 0;
    end
    
    always @ (posedge W_MEM) // Clock on memory write command
    begin
        vram[CA] <= DBI;
        cursor_address <= CA;
    end
    
    always @ (posedge R_MEM) // Clock on memory read command
    begin
        DBO <= vram[CA];
    end
endmodule

