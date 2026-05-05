module counter_tb;

    // ---- inputs (regs so TB can drive them) ----
    reg clk_1hz;
    reg clk_2hz;
    reg rst;
    reg pause;
    reg adj;
    reg sel;

    // ---- outputs (wires to observe) ----
    wire [3:0] sec_ones;
    wire [3:0] sec_tens;
    wire [3:0] min_ones;
    wire [3:0] min_tens;

    // ---- instantiate the counter ----
    counter uut (
        .clk_1hz (clk_1hz),
        .clk_2hz (clk_2hz),
        .rst     (rst),
        .pause   (pause),
        .adj     (adj),
        .sel     (sel),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens)
    );

    // ---- clock generation ----
    // 1Hz clock: period = 10ns (scaled for simulation)
    initial clk_1hz = 0;
    always #5 clk_1hz = ~clk_1hz;

    // 2Hz clock: period = 5ns (twice as fast)
    initial clk_2hz = 0;
    always #2.5 clk_2hz = ~clk_2hz;

    // helper task: pulse reset
    task do_reset;
        begin
            rst = 1;
            #12;
            rst = 0;
        end
    endtask

    // helper task: pulse pause 
    task do_pause;
        begin
            pause = 1;
            #6;
            pause = 0;
        end
    endtask

    // helper task: print current time
    // revert print_time back to original, no negedge
    task print_time;
        begin
            $display("Time=%0t | %0d%0d:%0d%0d | paused=%b adj=%b sel=%b",
                $time,
                min_tens, min_ones,
                sec_tens, sec_ones,
                uut.paused, adj, sel);
        end
    endtask

    // ---- main test sequence ----
    initial begin
        // init all inputs
        rst   = 0;
        pause = 0;
        adj   = 0;
        sel   = 0;

        // TEST 1: Reset
        $display("--- TEST 1: Reset ---");
        do_reset;
        print_time;
        // expect 00:00

        // TEST 2: Normal counting for 15 seconds
        $display("--- TEST 2: Normal counting (15 ticks) ---");
        repeat(15) @(posedge clk_1hz);
        #1; // let signals settle
        print_time;
        // expect 00:15

        // TEST 3: Count to 59 seconds (rollover)
        $display("--- TEST 3: Count to 59->00 rollover ---");
        do_reset; #1;
        repeat(59) @(posedge clk_1hz); #1;
        print_time; // expect 00:59
        @(posedge clk_1hz); #6; // wait past posedge and let it settle
        print_time; // expect 01:00

        // TEST 4: Pause
        $display("--- TEST 4: Pause ---");
        do_reset;
        repeat(5) @(posedge clk_1hz);
        #1;
        print_time; // expect 00:05
        do_pause;   // pause ON
        repeat(5) @(posedge clk_1hz);
        #1;
        print_time; // should still be 00:05
        do_pause;   // pause OFF
        repeat(3) @(posedge clk_1hz);
        #1;
        print_time; // expect 00:08

        // TEST 5: Adjustment mode - seconds (sel=1)
        $display("--- TEST 5: ADJ mode, sel=1 (seconds) ---");
        do_reset;
        adj = 1;
        sel = 1;
        repeat(5) @(posedge clk_2hz);
        #1;
        print_time; // expect 00:05 via 2hz
        adj = 0;
        sel = 0;

        // TEST 6: Adjustment mode - minutes (sel=0)
        $display("--- TEST 6: ADJ mode, sel=0 (minutes) ---");
        do_reset;
        adj = 1;
        sel = 0;
        repeat(3) @(posedge clk_2hz);
        #1;
        print_time; // expect 03:00
        adj = 0;

        // TEST 7: ADJ seconds rollover (58->59->00)
        $display("--- TEST 7: ADJ seconds rollover ---");
        do_reset;
        adj = 1;
        sel = 1;
        repeat(60) @(posedge clk_2hz);
        #1;
        print_time; // expect 00:00 (rolled over)
        adj = 0;

        // TEST 8: Full minute rollover (count to 1:00)
        $display("--- TEST 8: Full minute rollover ---");
        do_reset;
        repeat(60) @(posedge clk_1hz);
        #1;
        print_time; // expect 01:00

        $display("--- All tests done ---");
        $finish;
    end

    // dump waveform for GTKWave
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);
    end

endmodule