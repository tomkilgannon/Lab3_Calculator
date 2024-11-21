module Operation_Update (
    input wire clk,       
    input wire reset,         
    input wire new_op, // Select for multiplexer
  input wire [3:0] code,// operation code from the input 
  output reg [3:0] OP // Registered operation code
);

  wire [3:0] selected_op; 

  // Multiplexer Logic (pointless? - diagram seems to say so)
    assign selected_op = (new_op) ? code : OP;

    // Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
          OP <= 4'b00; // Reset OP register to value different to operation values - in this case 0
        end else begin
            OP <= selected_op; // Updating OP with the selected operation
        end
    end

endmodule
