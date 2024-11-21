module WarningCtrl (
    input clock,
    input reset,
    input equal_pressed,
    input overflow_warning,

    output reg light
);

wire next_light;

always @ (posedge clock or posedge reset) begin
    if (reset == 1'b1)
        light <= 0;
    else
        light <= next_light;
end

assign next_light = (equal_pressed) ? overflow_warning : light;

endmodule