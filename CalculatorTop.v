//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Brian Mulkeen
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Top-level module for calculator design.
//                Defines top-level input and output signals.
//                Instantiates clock and reset generator block, for 5 MHz clock
//                Instantiates keypad, and display interface modules.
//                
//  Created: 30 October 2015
//  Tidied 12 December 2018
//  Updated 16 November 2023 for new version of assignment.
//////////////////////////////////////////////////////////////////////////////////
module calculator_top(
        input clk100,		 // 100 MHz clock from oscillator on board
        input rstPBn,		 // reset signal, active low, from CPU RESET pushbutton
        input [5:0] kpcol,   // keypad column signals
        output [3:0] kprow,  // keypad row signals
        output [7:0] digit,  // digit controls - active low (7 on left, 0 on right)
        output [7:0] segment // segment controls - active low (a b c d e f g p)
        );

// =================================================================================
// Interconnecting Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire reset;             // active high reset, for use in all design blocks
    wire newkey;            // pulse to indicate new key pressed, keycode valid
    wire [4:0] keycode;     // 5-bit code to identify which key pressed
    wire [23:0] calcOut;    // 20-bit output from calculator, to be displayed

// =================================================================================
// Instantiate clock and reset generator, connect to signals
    clockReset  clkGen  (
            .clk100 (clk100),  // 100 MHz clock from oscillator on Nexys 4 board
            .rstPBn (rstPBn),  // active low reset from pushbutton on Nexys 4 board
            .clk5   (clk5),    // 5 MHz clock output for use in the design
            .reset  (reset) ); // reset output, active high, for use in design

//==================================================================================
// Instantiate keypad interface to scan the keypad and return valid keycode
    keypad keypd (
        .clk(clk5),            // clock for keypad module is 5 MHz
        .rst(reset),            // reset is internal reset signal
        .kpcol(kpcol),            // 6 keypad column inputs
        .kprow(kprow),            // 4 keypad row outputs
        .newkey(newkey),        // new key signal
        .keycode(keycode)        // 5-bit code representing key
        );

//==================================================================================
// Display interface - replace with your display interface
	displayInterface disp (
           .clock   (clk5), 		// 5 MHz clock
	       .reset   (reset),        // active high reset
	       .value   (calcOut),		// input value to be displayed
		   .dots    (6'b0),         // keep all dots off for simplest version
		   .digit   (digit), 		// outputs to the display on the Nexys-4 board
		   .segment (segment)
		   );

//==================================================================================
/* Instantiate your calculator here, and connect its ports to signals in this module:
    Use the 5 MHz clock signal, clk5.
	Use the active-high reset signal, reset.
	Use the keycode and newkey signals from the keypad interface.
	Connect the output to the calcOut signal - change the number of bits if necessary. */
	
	wire [3:0] code, OP;
	wire new_value, new_op, equal_pressed;
	
	wire [23: 0] X, Y, R;
	
	assign calcOut = X;
	
	InputProcessor inputProc (
	   .new_key(newkey),
	   .key_code(keycode),
	   
	   .code(code),
	   .new_value(new_value),
	   .new_op(new_op),
	   .equal_pressed(equal_pressed)
	);

    DisplayUpdate dispUp (
        .clock(clk5),
        .reset(reset),
        .load(equal_pressed), // Flag - new value should be loaded in the X register
        .load_val(R), // Value to be loaded in the X register
        .new_digit(new_value), // Flag - new digit was pressed on the keypad
        .code(code), // Code of the pressed digit
        .new_op(new_op),
        
        .X(X), // Value to be displayed
        .digit_count() // Number of digits to be displayed
    );
    
    Y_Update YReg (
        .clk(clk5),              
        .reset(reset),            
        .load(new_op), // Load signal to update Y
        .X(X), // Current value of X (to copy into Y)
      
        .Y(Y) // value of Y in the register
    );
    
    Operation_Update OpReg (
        .clk(clk5),       
        .reset(reset),         
        .new_op(new_op), // Select for multiplexer
        .code(code),// operation code from the input 
        .OP(OP) // Registered operation code
    );
    
    Arithmetic_Block arithmetic (
        .clk(clk5),    
        .reset(reset),  
        .X(X), // First operand (output of X Register)
        .Y(Y),// Second operand (output of Y Register)
        .OP(OP),// Operation code (assuming 2'b01 for addition, 2'b10 for multiplication. If Mihai uses different values just alter these)
        .result(R), // output of either (X + Y) or (X * Y). Not sure what will happen with display if overflowed
        .overflow() // overflow flag
    );
 	   
endmodule
