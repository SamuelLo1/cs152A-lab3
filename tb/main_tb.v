module main_tb;

   reg clk;
   reg clk_display;
   reg reset;
   reg pause;
   reg adj;
   reg sel;
   wire [6:0] seg;
   wire dp;
   wire [3:0] an;

   wire rst, pause_clean, adj_clean, sel_clean;
   wire clk_1hz, clk_2hz, clk_3hz, clk_50hz;
   wire [3:0] sec_ones, sec_tens, min_ones, min_tens;

   // 100MHz clock
   always #5 clk = ~clk;

   // faster clock for display mux
   always #1 clk_display = ~clk_display;

   clock_module #(
      .COUNT_1HZ  (4),
      .COUNT_2HZ  (2),
      .COUNT_3HZ  (1),
      .COUNT_50HZ (1)
   ) clk_mod (
      .master_clk (clk),
      .clk_1Hz    (clk_1hz),
      .clk_2Hz    (clk_2hz),
      .clk_3Hz    (clk_3hz),
      .clk_50Hz   (clk_50hz)
   );

   debouncer db_reset (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(reset), .btn_out(rst));
   debouncer db_pause (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(pause), .btn_out(pause_clean));
   debouncer db_adj   (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(adj),   .btn_out(adj_clean));
   debouncer db_sel   (.clk(clk), .rst(1'b0), .clk_en(clk_50hz), .btn_in(sel),   .btn_out(sel_clean));

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

   display disp (
      .clk_sys  (clk_display),
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

   initial begin
      clk         = 0;
      clk_display = 0;
      reset       = 0;
      pause       = 0;
      adj         = 0;
      sel         = 0;

      #100 reset = 1;
      #100 reset = 0;
      $display("--- reset released ---");

      #5000 $display("--- normal counting, sec=%0d%0d min=%0d%0d ---", sec_tens, sec_ones, min_tens, min_ones);

      // display mux check
      $display("--- display mux check ---");
      $display("an=%b seg=%b", an, seg);
      #8; $display("an=%b seg=%b", an, seg);
      #8; $display("an=%b seg=%b", an, seg);
      #8; $display("an=%b seg=%b", an, seg);

      #1000 pause = 1;
      #500  pause = 0;
      $display("--- paused, sec=%0d%0d ---", sec_tens, sec_ones);
      #3000 $display("--- still paused, sec=%0d%0d ---", sec_tens, sec_ones);

      #1000 pause = 1;
      #500  pause = 0;
      $display("--- unpaused ---");

      #2000 adj = 1; sel = 1;
      $display("--- adj mode, adjusting seconds ---");
      #5000 $display("sec after adj=%0d%0d", sec_tens, sec_ones);
      adj = 0; sel = 0;
      $display("--- back to normal ---");

      #2000 adj = 1; sel = 0;
      $display("--- adj mode, adjusting minutes ---");
      #5000 $display("min after adj=%0d%0d", min_tens, min_ones);
      adj = 0;
      $display("--- back to normal ---");

      #2000 reset = 1;
      #100  reset = 0;
      $display("--- reset mid-count, sec=%0d%0d min=%0d%0d ---", sec_tens, sec_ones, min_tens, min_ones);

      #5000 $finish;
   end

endmodule // main_tb