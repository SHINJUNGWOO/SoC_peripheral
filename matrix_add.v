

module matrix_add(
	//AHBLITE INTERFACE
			input wire HSEL,
		//Global Signal
			input wire HCLK,
			input wire HRESETn,
		//Address, Control & Write Data
			input wire HREADY,
			input wire [31:0] HADDR,
			input wire [1:0] HTRANS,
			input wire HWRITE,
			input wire [2:0] HSIZE,
			
			input wire [31:0] HWDATA,
			output reg HREADYOUT,
			output reg [31:0] HRDATA

            // Test
);
//8*8 Mult
reg rHSEL;
reg [31:0] rHADDR;
reg [1:0] rHTRANS;
reg rHWRITE;
reg [2:0] rHSIZE;

reg [1:0] state;

reg [31:0] A_data [0:63];
reg [31:0] B_data [0:63];
reg [31:0] result [0:63];

localparam idle = 2'b00, calc = 2'b01, done = 2'b10;
integer i;

always @(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn) begin
		rHSEL	<= 1'b0;
		rHADDR	<= 32'h0;
		rHTRANS	<= 2'b00;
		rHWRITE	<= 1'b0;
		rHSIZE	<= 3'b000;
        HREADYOUT <= 1'b1;

	end
    // State Phase
    else if (state == calc) begin
        HREADYOUT <= 1'b0;
        state <= done;

        for(i = 0; i <64;i=i+1)begin
            result[i] <= A_data[i] + B_data[i];
        end
    end
    else if (state == done) begin
        
        HREADYOUT <= 1'b1;
        state <= idle;
        HRDATA <= 32'h00000001;
        // can removable, but reamin for study
    end
    else if(HREADY) begin
        rHSEL   <= HSEL;
		rHADDR	<= HADDR;
		rHTRANS	<= HTRANS;
		rHWRITE	<= HWRITE;
		rHSIZE	<= HSIZE;

        // Read Phase
        if(HSEL & !HWRITE) begin
            
            if (HADDR[9:8] == 2'b11) begin
                HREADYOUT <= 1'b0;
                state <= calc;
                
            end
            else if(HADDR[9:8] == 2'b10) begin

                // read phase
                HRDATA <=result[HADDR[7:2]];
                HREADYOUT <= 1'b1;

            end
        end
        else begin
            HREADYOUT <= 1'b1;
        end

    end
end


// Write phase
always @(posedge HCLK)
begin
    if(rHSEL & rHWRITE & rHTRANS[1]) begin
        if(rHADDR[9:8] == 2'b00 & state == idle) begin
            A_data[rHADDR[7:2]] <= HWDATA;
            //HREADYOUT <= 1'b1;
        end 
        else if(rHADDR[9:8] == 2'b01 & state == idle)  begin
            B_data[rHADDR[7:2]] <= HWDATA;
            //HREADYOUT <= 1'b1;
        end

    end
end

endmodule