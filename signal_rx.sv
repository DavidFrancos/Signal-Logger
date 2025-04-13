`include "state_defs.svh"

//=======================================================================
// Module: signal_rx
// Description:
//   UART receiver module. Deserializes an incoming byte from a serial `rx`
//   line using standard 8N1 UART format and
//   stores the received byte into `log_input`.
//=======================================================================

typedef enum logic [1:0] {RX_IDLE, RECEIVING, ERROR} rx_state_t; // FSM states

module signal_rx (
    input logic clk, rx, rst,              // System clock, UART input, and synchronous reset
    output byte_t log_input                // Received byte value
);

    rx_state_t current_rx_state = RX_IDLE;     // FSM state tracking
    byte_t rx_shift_reg = 8'd0;                // Serial to parallel shift register
    logic signed [24:0] baud_counter = 0;      // Baud rate divider counter
    logic [3:0] bit_counter = 0;               // Bit reception counter

    //===================================================================
    // UART Reception Logic (FSM)
    //===================================================================

always_ff @( posedge clk ) begin : rx_logic
    if (rst) begin // INITIALIZE VALUES
        current_rx_state <= RX_IDLE;
        baud_counter <= 0;
        bit_counter <= 0;
        rx_shift_reg <= 0;
        log_input<= 8'h43; // ASCII 'C' default fallback | "CLEAR"
    end
    else begin
        if (current_rx_state == RX_IDLE && rx == 0) begin
            baud_counter <= (CLOCK_FREQ_HZ/BAUD_RATE) + 1; // CHECK WHEN TRANSMISSION STARTS
        end
        else baud_counter <= baud_counter + 1;
        if (baud_counter >= CLOCK_FREQ_HZ/BAUD_RATE) begin
            baud_counter <= 0;
            case (current_rx_state)
                RX_IDLE: begin
                    if (rx == 0) begin
                        rx_shift_reg <= 0;
                        current_rx_state <= RECEIVING;
                        baud_counter <= -(CLOCK_FREQ_HZ/(2*BAUD_RATE)); // Wait half a bit to log RX
                    end
                end
                RECEIVING: begin
                    if (bit_counter < 8) begin
                        rx_shift_reg <= {rx, rx_shift_reg[7:1]};
                        bit_counter <= bit_counter + 1;
                    end
                    else begin
                        current_rx_state <= RX_IDLE;
                        bit_counter <= 0;
                        if (rx == 1) begin
                            log_input <= rx_shift_reg; // Successful transmission
                        end
                        else begin
                            current_rx_state <= ERROR;
                        end
                    end
                end
                ERROR: begin
                    if (rx == 1) begin // Error in transmission, waiting for rx to stabilize
                        current_rx_state <= RX_IDLE; 
                        baud_counter <= 0;
                        bit_counter <= 0;
                        rx_shift_reg <= 0;
                    end
                end
            endcase
        end        
    end
end
endmodule