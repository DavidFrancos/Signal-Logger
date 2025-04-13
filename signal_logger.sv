`include "state_defs.svh"

//=======================================================================
// Module: signal_logger
// Description:
//   Finite State Machine responsible for logging switch activity into
//   a FIFO with timestamps. Includes logic to handle FIFO overflow
//   and time-based DUMP. Accepts external state control.
//=======================================================================

localparam ms_1000 = CLOCK_FREQ_HZ; // Defines a DUMP timeout threshold (1 second)

typedef logic [24:0] overflow_timer_t; // Custom width timer for overflow handling

module signal_logger (
    input logic  clk, rst,                    // Clock and synchronous reset
    input logic  debounced_switch0,          // Debounced input from switch 0
    input logic  debounced_switch1,          // Debounced input from switch 1
    input logic  log_full,                   // FIFO full status
    input state_t new_logger_state,          // Incoming FSM state from decoder

    output logic write_en,                   // Enables write to FIFO
    output logic read_en,                    // Enables read from FIFO
    output logic flush,                      // Triggers FIFO reset
    output state_t logger_state,             // Current FSM state
    output log_file_t write_data             // Data word to be written to FIFO
);

    log_timestamp_t log_timestamp;           // Monotonic timestamp counter
    overflow_timer_t overflow_timer;         // Timer for managing DUMP window
    logic sampled_value0, sampled_value1;    // Stored values of last switch state

    //=======================================================================
    // FSM and Logging Behavior
    //=======================================================================

    always_ff @(posedge clk) begin
        if (rst) begin // INITIALIZE VALUES
            logger_state <= CLEAR;
            sampled_value0 <= debounced_switch0;
            sampled_value1 <= debounced_switch1;
            log_timestamp <= 0;
            write_en <= 0;
            read_en <= 0;
            write_data <= 0;
            flush <= 0;
            overflow_timer <= 0;
        end
        else begin
            if (log_timestamp >= ((1 << (DATA_WIDTH - 2)) - 1) || log_full || overflow_timer > 0) begin
                // DUMP WHEN TIMESTAMP OVERFLOWS OR FIFO IS FULL    
                logger_state <= DUMP;  
                overflow_timer <= overflow_timer + 1;

                // END DUMP AFTER TIMEOUT
                if (overflow_timer >= ms_1000) begin
                    overflow_timer <= 0;
                    log_timestamp <= 0;
                end       
            end 
            else logger_state <= new_logger_state;
            case (logger_state)
                START: begin // Log switch edges with timestamps
                    flush <= 0;
                    read_en <= 0;
                    log_timestamp <= log_timestamp + 1;
                    if ((debounced_switch0 != sampled_value0) || (debounced_switch1 != sampled_value1)) begin
                        if (!log_full) begin
                            sampled_value0 <= debounced_switch0;
                            sampled_value1 <= debounced_switch1;
                            write_data <= {log_timestamp, debounced_switch1, debounced_switch0};
                            write_en <= 1;   
                        end
                    end
                    else write_en <= 0;
                end
                STOP: begin // Stop logging
                    write_en <= 0;
                    read_en <= 0;
                    flush <= 0;
                    log_timestamp <= log_timestamp + 1;
                end
                DUMP: begin // Dump FIFO to UART
                    write_en <= 0;
                    read_en <= 1;
                    flush <= 0;
                    log_timestamp <= 0;
                end
                CLEAR: begin // Reset FIFO
                    write_en <= 0;
                    read_en <= 0;
                    flush <= 1;
                    log_timestamp <= 0;
                end
            endcase
        end
    end
endmodule
