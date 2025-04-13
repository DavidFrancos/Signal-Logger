typedef logic [13:0] ms_counter; // 14-bit counter for ~1ms delay with 12 MHz clock
localparam ms_timer = 12000;       // ~1ms debounce threshold (assuming 12MHz clock)

//=======================================================================
// Module: switch_debounce
// Description:
//   This module debounces a noisy mechanical switch input using a timing
//   filter. It waits for a stable signal over a fixed delay before
//   accepting a change in state. Prevents switch bounce from causing
//   false triggering.
//=======================================================================

module switch_debounce (
    input logic clk, rst, raw_switch,          // System clock, reset, and raw mechanical input
    output logic debounced_switch              // Cleaned, debounced output
);

    logic debounced;                           // Internal signal: 1 if switch can be sampled again
    ms_counter debounce_delay;                 // Counter to track debounce time

    //===================================================================
    // Debounce Logic
    //===================================================================
    always_ff @( posedge clk) begin : debounce_logic
        if (rst) begin
            // Initialize output and state
            debounced_switch <= raw_switch;
            debounced <= 1;
            debounce_delay <= 0;
        end
        else if ((debounced_switch != raw_switch) && debounced) begin
            // Detected a change in switch, begin debounce window
            debounced_switch <= raw_switch;
            debounced <= 0;
        end
        else if (!debounced) begin
            // Wait out debounce period
            debounce_delay <= debounce_delay + 1;
            if (debounce_delay >= ms_timer) begin
                debounce_delay <= 0; // Reset delay counter
                debounced <= 1;      // Enable next edge detection
            end
        end
    end

endmodule