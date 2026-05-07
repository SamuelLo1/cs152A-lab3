`timescale 1ns/1ps

module clock_tb_fast;

    // Testbench signals
    reg master_clk;
    wire clk_1Hz;
    wire clk_2Hz;
    wire clk_3Hz;
    wire clk_50Hz;

    // Variables to track the time of the last posedge
    time last_1Hz_edge = 0;
    time last_2Hz_edge = 0;
    time last_3Hz_edge = 0;
    time last_50Hz_edge = 0;
    time current_period;

    // Instantiate the clock module with drastically scaled-down parameters
    // We are scaling the target values down so we can simulate in nanoseconds instead of seconds.
    clock_module #(
        .COUNT_1HZ(49),   // Toggles every 50 master clocks -> 100 clocks/period -> 1000 ns period
        .COUNT_2HZ(24),   // Toggles every 25 master clocks -> 50 clocks/period  -> 500 ns period
        .COUNT_3HZ(16),   // Toggles every 17 master clocks -> 34 clocks/period  -> 340 ns period
        .COUNT_50HZ(0)    // Toggles every 1 master clock  -> 2 clocks/period   -> 20 ns period
    ) uut (
        .master_clk(master_clk),
        .clk_1Hz(clk_1Hz),
        .clk_2Hz(clk_2Hz),
        .clk_3Hz(clk_3Hz),
        .clk_50Hz(clk_50Hz)
    );

    // Generate 100 MHz master clock (10ns period)
    initial begin
        master_clk = 0;
        forever #5 master_clk = ~master_clk;
    end

    // --- Period Measurement and Verification Blocks ---

    always @(posedge clk_1Hz) begin
        if (last_1Hz_edge > 0) begin
            current_period = $time - last_1Hz_edge;
            $display("[%0t ns] Scaled 1Hz Period measured: %0t ns (Expected: 1000 ns)", $time, current_period);
            if (current_period != 1000) $display("  -> ERROR: Incorrect 1Hz period!");
        end
        last_1Hz_edge = $time;
    end

    always @(posedge clk_2Hz) begin
        if (last_2Hz_edge > 0) begin
            current_period = $time - last_2Hz_edge;
            $display("[%0t ns] Scaled 2Hz Period measured: %0t ns (Expected: 500 ns)", $time, current_period);
            if (current_period != 500) $display("  -> ERROR: Incorrect 2Hz period!");
        end
        last_2Hz_edge = $time;
    end

    always @(posedge clk_3Hz) begin
        if (last_3Hz_edge > 0) begin
            current_period = $time - last_3Hz_edge;
            $display("[%0t ns] Scaled 3Hz Period measured: %0t ns (Expected: 340 ns)", $time, current_period);
            if (current_period != 340) $display("  -> ERROR: Incorrect 3Hz period!");
        end
        last_3Hz_edge = $time;
    end

    always @(posedge clk_50Hz) begin
        if (last_50Hz_edge > 0) begin
            current_period = $time - last_50Hz_edge;
            $display("[%0t ns] Scaled 50Hz Period measured: %0t ns (Expected: 20 ns)", $time, current_period);
            if (current_period != 20) $display("  -> ERROR: Incorrect 50Hz period!");
        end
        last_50Hz_edge = $time;
    end

    // --- Simulation Control ---
    initial begin
        $display("Starting scaled-down clock simulation...");
        $display("----------------------------------------");
        
        // Run just long enough to see a few cycles of the slowest (1000ns) clock.
        // Instead of running for 1,000,000,000 ns, we only need 3,000 ns!
        #3000; 
        
        $display("----------------------------------------");
        $display("Simulation complete.");
        $finish;
    end

endmodule