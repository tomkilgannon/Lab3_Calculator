module Arithmetic_Block (
    input wire clk,    
    input wire reset,  
  input wire [5:0] X, // First operand (output of X Register)
  input wire [5:0] Y,// Second operand (output of Y Register)
  input wire [1:0] OP,// Operation code (assuming 2'b01 for addition, 2'b10 for multiplication. If Mihai uses different values just alter these)
  output reg [5:0] result, // output of either (X + Y) or (X * Y). Not sure what will happen with display if overflowed
    output wire overflow // overflow flag
);

  wire [5:0] add_result, mul_result; // both addition and multiplication are done before one result is selected
  wire [5:0] selected_result;// Result selected by the multiplexer

    // Addition 
    assign add_result = X + Y;

    // Multiplication 
    assign mul_result = X * Y;

    // Multiplexer Logic
    assign selected_result = (OP == 2'b01) ? add_result : 
                             (OP == 2'b10) ? mul_result : 
      6'b0; // Default to 0 if OP is invalid (again just different to Mihai's OP codes)

    // Register for the Result
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 6'b0; // Reset result register
        end else begin
            result <= selected_result; // Storing selected result in the register
        end
    end

    //Overflow Logic
    assign overflow = (selected_result > 6'b111111);

endmodule

