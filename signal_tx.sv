`include "state_defs.svh"

//=======================================================================
// Module: signal_tx
// Description:
//   UART transmitter module. Serializes a single byte (`log_output`) into
//   10 UART bits (start + data + stop) and sends it over the `tx` line.
//   Manages baud rate timing and ready signaling.
//=======================================================================

localparam TOTAL_BITS = 10; // Total UART frame: 1 start + 8 data + 1 stop bit

typedef enum logic {TX_IDLE, TRANSMITTING} tx_state_t; // FSM states
typedef logic [TOTAL_BITS-1:0] uart_byte_t;

module signal_tx (
    input logic clk, rst, tx_enable,        // Clock, reset, and enable signal
    input byte_t log_output,                // Byte to be transmitted
    output logic tx,                        // Serial output line
    output logic tx_ready                   // High when transmitter is idle and ready
);

    tx_state_t current_tx_state;            // Current FSM state
    uart_byte_t tx_shift_reg ;              // Shift register for UART bits
    logic signed [23:0] baud_counter;       // Baud rate divider counter
    logic [3:0] tx_bit_counter;             // Bit index counter (0 to 9)

    assign tx_ready = ~current_tx_state;    // Ready when in IDLE state

    //===================================================================
    // UART Transmit FSM and Bit Timing Logic
    //===================================================================

always_ff @(posedge clk) begin : tx_logic 
    if (rst) begin // INITIALIZE VALUES
        current_tx_state <= TX_IDLE;
        tx_shift_reg <= 10'b1111111111;
        baud_counter <= 0;
        tx_bit_counter <= 0;
        tx <= 1;
    end
    else if (tx_enable & current_tx_state == TX_IDLE) begin
        current_tx_state <= TRANSMITTING; // Receive info and permission from tx_enable.
        tx_shift_reg <= {1'b1,log_output,1'b0}; // New requests while transmitting are ignored.
    end
    else begin
        baud_counter <= baud_counter + 1;
        if (baud_counter >= CLOCK_FREQ_HZ/BAUD_RATE) begin
            baud_counter <= 0;
            case (current_tx_state)
                TX_IDLE: begin
                    tx <= 1;
                end
                TRANSMITTING: begin
                    if (tx_bit_counter == TOTAL_BITS) begin // Transmission SUCCESSFUL.
                        current_tx_state <= TX_IDLE;
                        tx_bit_counter <= 0;
                    end
                    else begin
                        tx <= tx_shift_reg[0]; // Transmit LSB and shift right for next bit.
                        tx_shift_reg <= {1,tx_shift_reg[9:1]};
                        tx_bit_counter <= tx_bit_counter + 1;
                    end
                end
            endcase
        end
    end
end

endmodule
