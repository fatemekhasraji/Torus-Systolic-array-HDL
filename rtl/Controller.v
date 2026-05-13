module Controller #(
    parameter mat_size = 4

)(
    input clk,
    input reset,
    input START,
    output reg MOVE,
    output reg FINISH,
    output reg MULT_ADD
);
    localparam RESET_State    = 3'd0,
               INIT_State     = 3'd1,
               MOVE_State     = 3'd2,
               MULTADD_State  = 3'd3,
               FINISH_State   = 3'd4;

    reg [2:0] state;
    reg [$clog2(mat_size+1)-1:0] counter;

    always @(posedge clk) begin

        if(reset) begin
            state <= RESET_State;
            counter <= 0;
            MOVE <= 0;
            MULT_ADD <= 0;
            FINISH <= 0;
        end

        else begin
            MOVE <= 0;
            MULT_ADD <= 0;
            FINISH <= 0;

            case(state)
                RESET_State: begin
                    counter <= 0;
                    if(START)
                        state <= INIT_State;
                end

                INIT_State: begin
                    counter <= counter + 1;
                    state <= MULTADD_State;
                end

                MOVE_State: begin
                    MOVE <= 1;
                    counter <= counter + 1;
                    state <= MULTADD_State;
                end

                MULTADD_State: begin
                    MULT_ADD <= 1;
                    if(counter < mat_size)
                        state <= MOVE_State;
                    else
                        state <= FINISH_State;
                end

                FINISH_State: begin
                    FINISH <= 1;
                    state <= FINISH_State;
                end
            endcase
        end
    end

endmodule