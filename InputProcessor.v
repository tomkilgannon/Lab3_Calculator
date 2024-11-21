module InputProcessor (
    input new_key, // One bit, from the KeyPad interface
    input [4: 0] key_code, // Five bits, from the KeyPad interface
    output [3: 0] code, // Four bit code
    output new_value, // New code is a number
    output new_op, // New code is an operation
    output equal_pressed // The key pressed was '='
);

localparam [4: 0] EQUAL_CODE = 5'b00100;
wire select;

assign equal_pressed = (key_code == EQUAL_CODE) ? new_key : 1'b0;
assign select = (key_code[4] == 1'b0);

// Demultiplexer
assign {new_value, new_op} = select ? {new_key, 1'b0} : {1'b0, new_key};

assign code = key_code[3: 0];

endmodule