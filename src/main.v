module main(
   // Outputs
   seg, dp, an,
   // Inputs
   clk, reset, pause, adj, sel
   );

   input        clk;        // 100MHz master clock
   input        reset;      // reset button
   input        pause;      // pause button
   input        adj;        // adjustment mode switch
   input        sel;        // select minutes/seconds switch
   output [6:0] seg;        // seven segment segments
   output       dp;         // decimal point
   output [3:0] an;         // seven segment anodes

   wire rst, pause_clean, adj_clean, sel_clean;
   wire clk_1hz, clk_2hz, clk_3hz, clk_50hz;
   wire [3:0] sec_ones, sec_tens, min_ones, min_tens;

   // clock divider
   clock_module clk_mod (
      .master_clk (clk),
      .clk_1Hz    (clk_1hz),
      .clk_2Hz    (clk_2hz),
      .clk_3Hz    (clk_3hz),
      .clk_50Hz   (clk_50hz)
   );

   // debouncers
   debouncer db_reset (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(reset), .btn_out(rst));
   debouncer db_pause (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(pause), .btn_out(pause_clean));
   debouncer db_adj   (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(adj),   .btn_out(adj_clean));
   debouncer db_sel   (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(sel),   .btn_out(sel_clean));

   // counter
   counter cnt (
      .clk_1hz  (clk_1hz),
      .clk_2hz  (clk_2hz),
      .rst      (rst),
      .pause    (pause_clean),
      .adj      (adj_clean),
      .sel      (sel_clean),
      .sec_ones (sec_ones),
      .sec_tens (sec_tens),
      .min_ones (min_ones),
      .min_tens (min_tens)
   );

   // seven segment display
   display disp (
      .clk_sys  (clk),
      .clk_blink(clk_3hz),
      .sec_ones (sec_ones),
      .sec_tens (sec_tens),
      .min_ones (min_ones),
      .min_tens (min_tens),
      .sel      (sel_clean),
      .adj      (adj_clean),
      .seg      (seg),
      .dp       (dp),
      .an       (an)
   );

endmodule