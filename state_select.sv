`include "state_defs.svh"

//=======================================================================
// Module: state_select
// Description:
//   This module decodes an 8-bit ASCII command (`log_input`) and maps it to a
//   corresponding state in the logger FSM. If the input doesn't match a known
//   command, the state remains unchanged.
//=======================================================================

module state_select (
    input byte_t log_input,              // 8-bit ASCII input command
    input state_t logger_state,          // Current FSM state
    output state_t new_logger_state      // Next FSM state based on input
);

    // Combinational logic to determine the next state from the input byte
    always_comb begin
        case (log_input)
            8'h53: new_logger_state = START;  // 'S' → Start logging
            8'h54: new_logger_state = STOP;   // 'T' → Stop logging
            8'h44: new_logger_state = DUMP;   // 'D' → Dump FIFO
            8'h43: new_logger_state = CLEAR;  // 'C' → Clear FIFO
            default: new_logger_state = logger_state; // Maintain current state
        endcase
    end

endmodule