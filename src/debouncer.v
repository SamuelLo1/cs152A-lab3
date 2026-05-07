module debouncer(
   // Outputs
   btn_out,
   // Inputs
   clk, rst, clk_en, btn_in
   );

   input        clk;
   input        rst;
   input        clk_en;
   input        btn_in;
   output       btn_out;

   reg [2:0]    step_d;

   always @ (posedge clk)
     if (rst)
       begin
          step_d[2:0] <= 0;
       end
     else if (clk_en)
       begin
          step_d[2:0] <= {btn_in, step_d[2:1]};
       end

   assign btn_out = step_d[0];

endmodule