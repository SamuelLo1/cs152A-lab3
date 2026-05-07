module debouncer_tb;

   reg clk;
   reg rst;
   reg clk_en;
   reg btn_in;
   wire btn_out;

   reg [16:0] clk_cnt;

   // instantiate debouncer
   debouncer dut (
      .clk    (clk),
      .rst    (rst),
      .clk_en (clk_en),
      .btn_in (btn_in),
      .btn_out(btn_out)
   );

   // 100MHz clock
   always #5 clk = ~clk;

   // fake clk_en: pulse every 20 cycles
   always @ (posedge clk)
      clk_en <= (clk_cnt == 17'd20);

   always @ (posedge clk)
      if (rst)         clk_cnt <= 0;
      else if (clk_en) clk_cnt <= 0;
      else             clk_cnt <= clk_cnt + 1;

   initial begin
      $monitor("t=%0t btn_in=%b btn_out=%b", $time, btn_in, btn_out);

      // initialize
      clk    = 0;
      rst    = 1;
      clk_en = 0;
      btn_in = 0;

      #20 rst = 0;

      // clean press
      #2000 btn_in = 1;
      $display("t=%0t btn_in=1 (clean press)", $time);
      #5000 btn_in = 0;
      $display("t=%0t btn_in=0", $time);

      // bouncy press
      #2000 btn_in = 1;
      #100  btn_in = 0;  // bounce
      #100  btn_in = 1;  // bounce
      #100  btn_in = 0;  // bounce
      #100  btn_in = 1;  // settles high
      $display("t=%0t btn_in settled=1 (after bounce)", $time);
      #5000 btn_in = 0;
      $display("t=%0t btn_in=0", $time);

      #2000 $finish;
   end

endmodule // debouncer_tb