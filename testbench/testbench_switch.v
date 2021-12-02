module testbench_switch();
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
wire HREADYOUT;

reg[14:0] switch;
wire irq;
SWITCH_INPUT peri(
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
			
			.HWDATA(HWDATA),//,
            .HREADYOUT(HREADYOUT),
            .SWITCH_IRQ(irq),
            .SWITCH(switch)
    );
    initial begin
        HRESETn = 0;
        switch <= 14'h0011;
        //#50;
        #100;
        HRESETn = 1;
        #100;
        HREADY =1;
        HADDR = 32'h00000000;
        HSEL = 1'b1;
        HWRITE = 1'b0;
        HTRANS = 2'b11;
        #500;
        switch <= 14'h0031;

    end

endmodule