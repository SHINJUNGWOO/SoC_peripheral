module matrix_mult_pe(
    input wire HCLK,
    input wire reset,
    input wire work,
    input wire [7:0] A_data,
    input wire [7:0] B_data,


    //output reg [31:0] A_data_out,
    //output reg [31:0] B_data_out,
    output reg [15:0] result
);

always @(posedge HCLK) begin
    if(reset) begin
        result <= 32'h0000;
    end
    else begin
        if(work) begin
            result <= result + A_data * B_data;
        end
    end
end

endmodule




module matrix_mult_process(
    input wire HCLK,
    input wire HRESETn,
    input wire start,
    input wire [1:0] reuse,
    // 2'b1X reuse result
    // reuse[0] use result in A
    // reuse[0] use result in B
    
    input wire [8*64-1:0] A_data ,
    input wire [8*64-1:0] B_data ,
    // big endian
    output wire [16*64-1:0] result,
    output reg done

);

integer  i;

reg[1:0] state;
reg[3:0] counter;
reg work;
reg reset;



reg [7:0] A_tmp[0:7];
reg [7:0] B_tmp[0:7]; 
wire [15:0] result_tmp[0:63];

wire [7:0] A_in[0:63];
wire [7:0] B_in[0:63];
reg [15:0] result_in[0:63];


genvar j;
for(j=0;j<64;j=j+1) begin
    matrix_mult_pe pe_assem(
    .HCLK(HCLK),
    .reset(reset),
    .work(work),
    .A_data(A_tmp[j/8]),
    .B_data(B_tmp[j%8]),

    .result(result_tmp[j])
    );
end
for(j=0;j<64;j=j+1) begin
    assign A_in[j] = A_data[8*j+7:8*j];
    assign B_in[j] = B_data[8*j+7:8*j];
    assign result[16*j+15:16*j] = result_in[j];
end



localparam idle = 2'b00, set = 2'b01, calc = 2'b10, calc_done = 2'b11 ;

localparam count_min = 4'b0000,count_max = 4'b1000;
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
        state <= idle;
        counter <= count_min;
        work <= 1'b0;
        reset <= 1'b0;
    end
    else begin
        case(state)
            idle: begin
                done <= 1'b0;
                if(start == 1'b1) begin
                    state <= set;
                    reset <= 1'b1;
                    work <= 1'b0;
                    counter <= count_min;
                end
                else begin
                    work <= 1'b0;
                    reset <= 1'b0;
                end

            end
            set: begin
                reset <= 1'b0;
                work  <= 1'b1;
                counter <= counter + 1;

                if(counter == count_max) begin

                    state <= calc;
                    counter<= count_min;
                    work <=1'b1;
                end
                else if(reuse) begin
                end
                else begin
                    for(i=0;i<8;i=i+1)begin
                        A_tmp[i] = A_in[8*i + counter];
                        B_tmp[i] = B_in[i + 8*counter];
                    end
                end
            end
            calc: begin
                done <=1'b1;
                state <= calc_done;
                for(i=0;i<64;i=i+1)begin
                    result_in[i] <= result_tmp[i];
                end
                
            end
            calc_done: begin
                done <= 1'b0;
                state <= idle;
            end
            default: begin
                state <= idle;
            end

        endcase
    end
end

endmodule