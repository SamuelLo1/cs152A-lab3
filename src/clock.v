module debouncer(
    input clk,
    input btn_in,
    output reg btn_out
);
    // two-stage synchronizer: handles metastability and filters bounce noise
    reg [1:0] shift_reg;

    always @(posedge clk) begin
        shift_reg <= {shift_reg[0], btn_in};
        btn_out <= shift_reg[1];
    end
endmodule