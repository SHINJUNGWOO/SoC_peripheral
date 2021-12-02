`timescale 1ns/1ns

module testbench_slave();
reg clk;

always
begin
    #50 clk = 0;
    #50 clk = 1;
end


reg HSEL;
//reg HCLK;
reg HRESETn;
reg HREADY;
reg [31:0] HADDR;
reg [1:0] HTRANS;
reg HWRITE;
reg [2:0] HSIZE;
reg [31:0] HWDATA;
wire out;
matrix_mult peri(
	//AHBLITE INTERFACE
			.HSEL(HSEL),
		//Global Signal
			.HCLK(clk),
			.HRESETn(HRESETn),
		//Address, Control & Write Data
			.HREADY(HREADY),
			.HADDR(HADDR),
			.HTRANS(HTRANS),
			.HWRITE(HWRITE),
			.HSIZE(HSIZE),
			
			.HWDATA(HWDATA),//,
            .HREADYOUT(out)
//			output wire [31:0] HRDATA
);
always @(posedge clk) begin
    HREADY <= out;
end
integer i;
initial begin
    HRESETn = 0;
    //#50;
    #100;
    HRESETn = 1;
    #100;
    HREADY =1;
    HADDR = 32'h00000000;
    HSEL = 1'b1;
    HWRITE = 1'b1;
    HTRANS = 2'b11;
    for(i=0;i<128*4;i=i+4) begin
        #100;
        HWDATA = 1;
        HADDR = i;
    end
    #100;
    HWDATA = 1;

    #1000;
    HADDR = 32'h00000300;
    HWRITE = 1'b0;
    #100;
    HWDATA = 15;
    //HSEL = 0;

    #10000
    $finish;
end



endmodule