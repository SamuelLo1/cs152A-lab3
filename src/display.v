module display (
    input clk_sys,      // System clock for multiplexing (100MHz)
    input clk_blink,    // Clock for blinking control
    input [3:0] sec_ones,
    input [3:0] sec_tens,
    input [3:0] min_ones,
    input [3:0] min_tens,
    input sel,          // 0: minutes, 1: seconds
    input adj,          // 0: normal, 1: adjustment (blinking)
    output reg [6:0] seg,
    output reg dp,
    output reg [3:0] an
);

    // Multiplexing counter - divides system clock to cycle through digits
    reg [19:0] mux_counter;
    wire [1:0] digit_select;
    
    always @ (posedge clk_sys) begin
        mux_counter <= mux_counter + 1;
    end
    
    // Select which digit to display (cycles every ~5ms at 100MHz)
    assign digit_select = mux_counter[19:18];
    
    // Blink state controlled by blink clock
    reg blink_state;
    
    always @ (posedge clk_blink) begin
        blink_state <= ~blink_state;
    end
    
    // Determine digit to display and blanking
    reg [3:0] digit_data;
    reg digit_blank;
    
    always @ (*) begin
        case (digit_select)
            2'b00: begin  // Leftmost - min_tens
                digit_data = min_tens;
                digit_blank = (adj & ~sel) ? blink_state : 1'b0;
            end
            2'b01: begin  // Second from left - min_ones
                digit_data = min_ones;
                digit_blank = (adj & ~sel) ? blink_state : 1'b0;
            end
            2'b10: begin  // Third from left - sec_tens
                digit_data = sec_tens;
                digit_blank = (adj & sel) ? blink_state : 1'b0;
            end
            2'b11: begin  // Rightmost - sec_ones
                digit_data = sec_ones;
                digit_blank = (adj & sel) ? blink_state : 1'b0;
            end
        endcase
    end
    
    // 7-segment decoder (common anode: 0=segment ON, 1=segment OFF)
    // Segment mapping: seg[6:0] = {g, f, e, d, c, b, a}
    always @ (*) begin
        if (digit_blank) begin
            seg = 7'b1111111;  // All segments off
            dp = 1'b1;
        end else begin
            case (digit_data)
                4'h0: seg = 7'b1000000;  // 0
                4'h1: seg = 7'b1111001;  // 1
                4'h2: seg = 7'b0100100;  // 2
                4'h3: seg = 7'b0110000;  // 3
                4'h4: seg = 7'b0011001;  // 4
                4'h5: seg = 7'b0010010;  // 5
                4'h6: seg = 7'b0000010;  // 6
                4'h7: seg = 7'b1111000;  // 7
                4'h8: seg = 7'b0000000;  // 8
                4'h9: seg = 7'b0010000;  // 9
                default: seg = 7'b1111111;  // Off
            endcase
            dp = 1'b1;  // Decimal point off
        end
    end
    
    // Anode decoder (common anode: 0=digit ON, 1=digit OFF)
    always @ (*) begin
        case (digit_select)
            2'b00: an = 4'b1110;  // Enable an[0] (leftmost)
            2'b01: an = 4'b1101;  // Enable an[1]
            2'b10: an = 4'b1011;  // Enable an[2]
            2'b11: an = 4'b0111;  // Enable an[3] (rightmost)
        endcase
    end

endmodule
