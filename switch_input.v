module SWITCH_INPUT(  
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [31:0] HWDATA,
    input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire HREADY,
    input wire HSEL,

    output wire HREADYOUT,
    output reg [31:0] HRDATA,
    output wire SWITCH_IRQ,

    input wire [14:0] SWITCH
    );
    
    reg rHSEL;
    reg rHWRITE;
    reg [1:0] rHTRANS;
    reg [14:0] switch_reg;

    // sequential part
    assign SWITCH_IRQ = (switch_reg == SWITCH) ? 0: 1;
    assign HREADYOUT =1'b1; 
    always @(posedge HCLK or negedge HRESETn) begin
        if(!HRESETn) begin
            switch_reg <= 14'h0000;
        end
        else begin
            if(HSEL & !HWRITE) begin
                HRDATA <= SWITCH;
                switch_reg <= SWITCH;
            end
        end
    end

endmodule
