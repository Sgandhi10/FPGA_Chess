////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Filename: keypress.v
// Author:   Jason Thweatt
// Date:     16 March 2023
// Revision: 1
//
// Description: This synchronous finite-state machine generates an ACTIVE-HIGH enable pulse that
//              lasts for one clock period each time an ACTIVE-LOW key is pressed and released.
//
//              Specifically, the enable pulse occurs during the clock period AFTER the key is
//              released.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////
//                                             //
// DO NOT MODIFY THIS FILE WITHOUT PERMISSION! //
//                                             //
/////////////////////////////////////////////////

module keypress(clock, reset_n, key_in, enable_out);
   input  clock, reset_n, key_in;
	output enable_out;

	reg [1:0] key_state, key_next_state;
	reg       enable_out;

// Set up parameters for the state of the pushbutton.
// For three states, we're using two bits to represent the state in a "dense" assignment.

	parameter KEY_UNPRESSED = 2'b00, KEY_PRESSED = 2'b01, KEY_RELEASED = 2'b10;
	
// REGISTER BLOCK: This block represents SEQUENTIAL LOGIC so it uses non-blocking assignment. It
// is sensitized to appropriate edges of the clock input and the reset input. Picture this block
// as two D flip-flops with common clock and reset.

	always@(posedge clock, negedge reset_n) begin

	// If reset_n is 0, there must have been a negative edge on the reset. The effect of the reset
	// occurs without a clock edge so the reset is ASYNCHRONOUS.

		if(reset_n == 1'b0)
			key_state <= KEY_UNPRESSED;
	
	// If reset_m is not zero but this always block is active, there must have been a positive 
	// clock edge. On each positive clock edge, the next state becomes the present state.

		else
			key_state <= key_next_state;
	end // end always

// EXCITATION LOGIC: This block represents COMBINATIONAL LOGIC so it uses blocking assignment. It
// is sensitized to changes in the FSM present state and the key input. Picture this block as the
// combinational logic that feeds the flip-flop inputs. It determines the next state based on the
// current state and the key value.

	always@(key_state, key_in) begin
	
	// Use the present state to determine the next state.

		case(key_state)
	
		// KEY_UNPRESSED is the state where the key is currently unpressed and was not just released.
		// In this state, if the key value is 0, make the next state KEY_PRESSED.

			KEY_UNPRESSED: begin
				if(key_in == 1'b0)
					key_next_state = KEY_PRESSED;
				else
					key_next_state = KEY_UNPRESSED;
			end // end KEY_UNPRESSED case

		// KEY_PRESSED is the state where the key is currently pressed down. In this state, if the
		// key value is 1, make the next state KEY_RELEASED.

			KEY_PRESSED: begin
				if(key_in == 1'b1)
					key_next_state = KEY_RELEASED;
				else
					key_next_state = KEY_PRESSED;
			end // end KEY_PRESSED case

		// KEY_RELEASED is the state where the key has JUST BEEN released. In this state, make the
		// next state KEY_UNPRESSED. Note that this state makes its transition independent of the
		// input value. This state lasts for exactly one clock cycle - the clock cycle right after
		// the button was released.

			KEY_RELEASED:
				key_next_state = KEY_UNPRESSED;

		// If none of the above (something that should NEVER happen) make the next state unknown.

			default: key_next_state = 2'bxx;

		endcase
	end // end always

// OUTPUT MACHINE: This block represents combinational logic so it uses blocking assignment. This
// is a Moore output so the block is sensitized only to the state. (In a Mealy machine the output
// would have been sensitized to a state and to an input.) Picture this block as a combinational
// circuit that operates on the state to determine the output.

// I have structured the output machine as an always block to provide an example of how you should
// do it in general. The behavior of this output is simple enough that a continuous assignment
// could have been used more effectively.
//
// assign enable_out = (key_state == KEY_RELEASED);

	always@(key_state) begin
	
	// Use the present state to determine the output.
	
		case(key_state)
		
		// If the key is currently unpressed and was not just released, enable_out should be 0.

			KEY_UNPRESSED: enable_out = 1'b0;

		// If the key is currently being pressed, enable_out should be 0.

			KEY_PRESSED:   enable_out = 1'b0;

		// If the key has has just been released, enable_out should be 1. This state only lasts for
		// one clock cycle, so enable_out is 1 for only one clock cycle.

			KEY_RELEASED:  enable_out = 1'b1;

		// If none of the above (something that should NEVER happen) make the output unknown.

			default:       enable_out = 1'bx;
		endcase
	end  // end always
	
endmodule
