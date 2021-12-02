`timescale 1ns/1ns

module testbench_mult_process();
reg clk;

always
begin
    #50 clk = 0;
    #50 clk = 1;
end

reg start;

reg [7:0] A_data [0:63];
reg [7:0] B_data [0:63];
wire [15:0] result [0:63];
wire [8*64-1:0] A_data_wire;
wire [8*64-1:0] B_data_wire;
wire [16*64-1:0] result_data_wire;
wire done;


matrix_mult_process u_mult(
    .HCLK(clk),
    .HRESETn(1'b1),
    .start(start),
    .reuse(2'b00),
    // 2'b1X reuse result
    // reuse[0] use result in A
    // reuse[0] use result in B
    
    .A_data(A_data_wire),
    .B_data(B_data_wire),

    .result(result_data_wire),
    .done(done)

);


genvar  i;
for(i = 0; i <64;i = i+1) begin
    assign A_data_wire[8*i+7:8*i] = A_data[i];
    assign B_data_wire[8*i+7:8*i] = B_data[i];
    assign result[i] = result_data_wire[16*i+15:16*i];
end
integer j;
initial begin
    start = 1'b0;
    for(j = 0; j <64;j = j+1) begin
        A_data[j] <= 8'h01;
        B_data[j] <= 8'h01;
    end
    #100;
    start = 1'b1;

end

endmodule