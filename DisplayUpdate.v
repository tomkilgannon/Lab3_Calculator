module DisplayUpdate (
    input clock,
    input reset, // Async
    input load, // Flag - new value should be loaded in the X register
    input [23: 0] load_val, // Value to be loaded in the X register
    input new_digit, // Flag - new digit was pressed on the keypad
    input [3: 0] code, // Code of the pressed digit

    output reg [23: 0] X, // Value to be displayed
    output reg [2: 0] digit_count // Number of digits to be displayed
);

wire [23: 0] new_X;
wire [23: 0] shifted_X;
wire [23: 0] proc_X;

reg [2: 0] new_digit_count;

wire max_digits;
wire value_to_add;

// X register
always @ (posedge clock or posedge reset) begin
    if (reset == 1'b1)
        X <= 0;
    else
        X <= new_X;
end

assign shifted_X = {X[19: 0], code};
//   If there's a new digit and there is still space on the screen
assign proc_X = (new_digit & ~max_digits) ? shifted_X : X;

assign new_X = (load == 1'b1) ? load_val : proc_X;

// Digit counter register
always @ (posedge clock or posedge reset) begin
    if (reset == 1'b1)
        digit_count <= 0;
    else
        digit_count <= new_digit_count;
end

always @ (load, value_to_add, digit_count) begin
    if (load == 1'b1) begin
        new_digit_count = 3'd6;
    end
    else begin
        new_digit_count = digit_count + value_to_add;
    end
end

assign max_digits = (digit_count == 3'd6);

assign value_to_add = (new_digit == 1'b1) ? (max_digits == 1'b1 ? 1'b0 : 1'b1) : 0;

endmodule