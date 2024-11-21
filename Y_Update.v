module Y_Update (
    input wire clk,              
    input wire reset,            
    input wire load, // Load signal to update Y
  input wire [23:0] X, // Current value of X (to copy into Y)
  output reg [23:0] Y // value of Y in the register
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Y <= 24'b0; // Reset Y register to 0 upon reset
        end else if (load) begin
            Y <= X; // Copy the value of X into Y when load=1
        end
    end
  
endmodule
