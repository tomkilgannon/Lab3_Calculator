module Arithmetic_Block (
    input wire clk,    
    input wire reset,  
  input wire [23:0] X, // First operand (output of X Register)
  input wire [23:0] Y,// Second operand (output of Y Register)
  input wire [3:0] OP,// Operation code (assuming 2'b01 for addition, 2'b10 for multiplication. If Mihai uses different values just alter these)
  output reg [23:0] result, // output of either (X + Y) or (X * Y). Not sure what will happen with display if overflowed
    output wire overflow // overflow flag
);
  
  // Multiply and addition local parameters
  localparam [3: 0] MULTIPLY_CODE = 4'b0010;
  localparam [3: 0] PLUS_CODE = 4'b1010;
  
  

  wire [23:0] add_result, mul_result; // both addition and multiplication are done before one result is selected
  wire [23:0] selected_result;// Result selected by the multiplexer

    // Addition 
    assign add_result = X + Y;

    // Multiplication 
    assign mul_result = X * Y;

    // Multiplexer Logic
    assign selected_result = (OP == PLUS_CODE) ? add_result : 
                             (OP == MULTIPLY_CODE) ? mul_result : 
                             24'b0; // Default to 0 if OP is invalid (again just different to Mihai's OP codes)

    // Register for the Result
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 24'b0; // Reset result register
        end else begin
            result <= selected_result; // Storing selected result in the register
        end
    end

    //Overflow Logic
    assign overflow = (selected_result > 24'hFFFFFF);

endmodule
