module displayInterface (
    input clock, // 5Mhz clock
    input reset, // active high, synchronous
    input [23:0] value,
    input [5:0] dots,

    output reg [7:0] digit, // active low
    output [7:0] segment    // active low
);

    reg [2:0] count; // State counter
    
    reg [3:0] hexNumber; // The selected 4-bit group of the value signal
    reg dot; // The selected bit of the dots signal
    wire [6:0] pattern; // Output of the hex2seg block
    
    reg clock_slow; // T flip-flop that generates the clock input of the state counter
    reg [10:0] slowedCounter; // Slowed counter clock -> up to 1000

    hex2seg hex2segModule (
        .number (hexNumber),
        .pattern (pattern)
    );

    // Divide the main clock by 2000 => 2.5 kHz or 0.4 ms period
    // Meaning the display will refresh every 0.4ms * 6 = 2.4 ms
    always @ (posedge clock) begin
        if ( reset == 1'b1 ) begin // Reset the mod 1000 and T flip-flop
            clock_slow <= 0;
            slowedCounter <= 0;
        end
        else begin
            slowedCounter <= slowedCounter + 11'd1;

            if (slowedCounter == 11'd1000) begin
                slowedCounter <= 0;
                clock_slow <= ~clock_slow; // Flip the slowed clock signal every 1000 cycles of the input clock
            end
        end
    end

    // When the T flip-flop changes or the reset signal goes high
    always @ (posedge clock_slow or posedge reset) begin
        if ( reset == 1'b1 ) begin
            count <= 3'd0;
        end
        else begin // Mod 6 counter
            count <= count + 3'd1;

            if (count == 3'd5) begin
                count <= 3'd0;
            end
        end
    end

    // Multiplexer implementation
    always @ (count, value, dots) begin
        case (count)
            3'd0 : begin
                digit <= 8'b11111110;
                hexNumber <= value[3:0];
                dot <= ~dots[0];
            end

            3'd1 : begin
                digit <= 8'b11111101;
                hexNumber <= value[7:4];
                dot <= ~dots[1];
            end

            3'd2 : begin
                digit <= 8'b11111011;
                hexNumber <= value[11:8];
                dot <= ~dots[2];
            end

            3'd3 : begin
                digit <= 8'b11110111;
                hexNumber <= value[15:12];
                dot <= ~dots[3];
            end

            3'd4 : begin
                digit <= 8'b11101111;
                hexNumber <= value[19:16];
                dot <= ~dots[4];
            end

            3'd5 : begin
                digit <= 8'b11011111;
                hexNumber <= value[23:20];
                dot <= ~dots[5];
            end

            default: begin // Default: the reset isn't yet pressed - all signals LOW
                digit <= 8'b11111111;
                hexNumber <= 4'h0;
                dot <= 1'b1;
            end
        endcase
    end
    
    assign segment = {pattern, dot}; // Concatenate the pattern and dot signals to get the segment output

endmodule