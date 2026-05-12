/*
output: 4 clocks: 
 - 1Hz
 - 2Hz
 - >1Hz but not 2Hz, can pick 3Hz
 - 50hz clock for denoising 

*/

module clock_module
(
    input wire master_clk,
    output reg clk_1Hz = 0,
    output reg clk_2Hz = 0,
    output reg clk_3Hz = 0,
    output reg clk_50Hz = 0
);

// Counter limits (divide by toggling at half period)
parameter COUNT_1HZ = 49_999_999;      // 100MHz / (2 * 1Hz)
parameter COUNT_2HZ = 24_999_999;      // 100MHz / (2 * 2Hz)
parameter COUNT_3HZ = 16_666_666;      // 100MHz / (2 * 3Hz) - rounded
parameter COUNT_50HZ = 1_000_000;      // 100MHz / (2 * 50Hz)

reg [31:0] counter_1Hz = 0;
reg [31:0] counter_2Hz = 0;
reg [31:0] counter_3Hz = 0;
reg [31:0] counter_50Hz = 0;

always @(posedge master_clk) begin
    // 1 Hz clock divider
    if (counter_1Hz == COUNT_1HZ) begin
        counter_1Hz <= 0;
        clk_1Hz <= ~clk_1Hz;
        // $display("[%t] clk_1Hz edge: %b", $time, ~clk_1Hz);
    end else begin
        counter_1Hz <= counter_1Hz + 1;
    end

    // 2 Hz clock divider
    if (counter_2Hz == COUNT_2HZ) begin
        counter_2Hz <= 0;
        clk_2Hz <= ~clk_2Hz;
        // $display("[%t] clk_2Hz edge: %b", $time, ~clk_2Hz);
    end else begin
        counter_2Hz <= counter_2Hz + 1;
    end

    // 3 Hz clock divider
    if (counter_3Hz == COUNT_3HZ) begin
        counter_3Hz <= 0;
        clk_3Hz <= ~clk_3Hz;
        // $display("[%t] clk_3Hz edge: %b", $time, ~clk_3Hz);
    end else begin
        counter_3Hz <= counter_3Hz + 1;
    end

    // 50 Hz clock divider
    if (counter_50Hz == COUNT_50HZ) begin
        counter_50Hz <= 0;
        clk_50Hz <= ~clk_50Hz;
        // $display("[%t] clk_50Hz edge: %b", $time, ~clk_50Hz);
    end else begin
        counter_50Hz <= counter_50Hz + 1;
    end
end

endmodule