`timescale 1ns / 1ps
module PE#(
parameter bit_width = 32,
parameter mat_size = 4
)(
input reset, clk,
input [bit_width-1:0] pos_row ,
input [bit_width-1:0] pos_col ,
input signed [bit_width-1:0] up,
input signed [bit_width-1:0] left,
input START,MULT_ADD,
output reg signed [bit_width-1:0] down,
output reg signed [bit_width-1:0] right,
output reg signed [bit_width-1:0] prod
 );
always @(posedge clk) begin
    if (reset) begin
        prod = 0;
        right = 0;
        down = 0;
    end else begin
        if (MULT_ADD) begin    
            if(pos_row < mat_size) begin
                if (pos_col < mat_size) begin
                    prod = prod + (left * up);
                    right = left;
                    down = up;  
                end
            end           
        end
    end 
end
endmodule
