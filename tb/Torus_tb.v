`timescale 1ns / 1ps

module Torus_tb;
    parameter bit_width = 32;
    parameter mat_size = 4;    
    parameter torus_row_size = 10;
    parameter torus_col_size = 5;
    reg clk, reset, START;
    wire signed [(bit_width * mat_size * mat_size) - 1 : 0] Matrix_C;

    reg signed [bit_width-1:0] Matrix_A [0:mat_size-1][0:mat_size-1];
    reg signed [bit_width-1:0] Matrix_B [0:mat_size-1][0:mat_size-1];

    wire [(bit_width * mat_size * mat_size) - 1 : 0] flat_A;
    wire [(bit_width * mat_size * mat_size) - 1 : 0] flat_B;
    wire FINISH;
    genvar i, j;
    generate
        for (i = 0; i < mat_size; i = i + 1) begin : rows
            for (j = 0; j < mat_size; j = j + 1) begin : cols
                assign flat_A[(i*mat_size + j)*bit_width +: bit_width] = Matrix_A[i][j];
                assign flat_B[(i*mat_size + j)*bit_width +: bit_width] = Matrix_B[i][j];
            end
        end
    endgenerate

    Torus #(
        .bit_width(bit_width),
        .mat_size(mat_size),
        .torus_row_size(torus_row_size),
        .torus_col_size(torus_col_size)
    ) dut (
        .reset(reset), 
        .clk(clk),
        .flat_A(flat_A),
        .flat_B(flat_B),
        .Matrix_C(Matrix_C),
        .START(START),
        .FINISH(FINISH)
    );
    integer row,col;
    initial begin
       clk = 1'b0;
       forever #5 clk = ~clk;
    end

    initial begin
        START = 1'b0;
 
        Matrix_A[0][0] = 32'd1;   Matrix_A[0][1] = 32'd10;  Matrix_A[0][2] = 32'd20;  Matrix_A[0][3] = 32'd30;
        Matrix_A[1][0] = 32'd40;  Matrix_A[1][1] = 32'd50;  Matrix_A[1][2] = 32'd60;  Matrix_A[1][3] = 32'd70;
        Matrix_A[2][0] = 32'd100; Matrix_A[2][1] = 32'd110; Matrix_A[2][2] = 32'd120; Matrix_A[2][3] = 32'd130;
        Matrix_A[3][0] = 32'd100; Matrix_A[3][1] = 32'd200; Matrix_A[3][2] = 32'd300; Matrix_A[3][3] = 32'd400;
        
        Matrix_B[0][0] = 32'd1;   Matrix_B[0][1] = 32'd10;  Matrix_B[0][2] = 32'd20;  Matrix_B[0][3] = 32'd30;
        Matrix_B[1][0] = 32'd40;  Matrix_B[1][1] = 32'd50;  Matrix_B[1][2] = 32'd60;  Matrix_B[1][3] = 32'd70;
        Matrix_B[2][0] = 32'd100; Matrix_B[2][1] = 32'd110; Matrix_B[2][2] = 32'd120; Matrix_B[2][3] = 32'd130;
        Matrix_B[3][0] = 32'd100; Matrix_B[3][1] = 32'd200; Matrix_B[3][2] = 32'd300; Matrix_B[3][3] = 32'd400;

        reset = 1'b1;
        #15;
        reset = 1'b0;
        START = 1'b1;
        #15;
        START = 1'b0;
        wait(FINISH);
        #15;

        $display("\nFinal Matrix_C Results");
        for (row = 0; row < mat_size; row = row + 1) begin
            for (col = 0; col < mat_size; col = col + 1) begin
                $write("%8d ", $signed(Matrix_C[(row * mat_size + col) * bit_width +: bit_width]));
            end
        end
        $finish;
    end
endmodule
