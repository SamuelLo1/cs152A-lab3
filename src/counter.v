module counter (
    input clk_1hz,
    input clk_2hz,
    input rst,
    input pause,
    input adj,
    input sel,
    output reg [3:0] sec_ones,
    output reg [3:0] sec_tens,
    output reg [3:0] min_ones,
    output reg [3:0] min_tens
);

    reg paused; 

    always @ (posedge pause or posedge rst) begin
        if (rst)
            paused <= 0;
        else
            paused <= ~paused;
    end

    // select active clk
    wire clk = adj ? clk_2hz : clk_1hz;

    // counter logic
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            sec_ones <= 0;
            sec_tens <= 0;
            min_ones <= 0;
            min_tens <= 0;
        
        // adjustment mode
        end else if (adj) begin
            if (sel) begin // sel = 1 => adjust seconds
                if (sec_ones == 9) begin
                    sec_ones <= 0;
                    sec_tens <= (sec_tens == 5) ? 0 : sec_tens + 1;
                end else
                    sec_ones <= sec_ones + 1;
            end else begin // sel = 0 => adjust minutes
                if (min_ones == 9) begin
                    min_ones <= 0;
                    min_tens <= (min_tens == 5) ? 0 : min_tens + 1;
                end else
                    min_ones <= min_ones + 1;
            end

        end else if (!paused) begin // Nomral Counting
            if (sec_ones == 9)  begin
                sec_ones <= 0;
                if (sec_tens == 5) begin
                    sec_tens <= 0;
                    if (min_ones == 9) begin
                        min_ones <= 0;
                        if (min_tens == 5) 
                            min_tens <= 0;
                        else
                            min_tens <= min_tens + 1;
                    end else
                        min_ones <= min_ones + 1;
                end else
                    sec_tens <= sec_tens + 1;
            end else
                sec_ones <= sec_ones + 1;
        end
    end


endmodule