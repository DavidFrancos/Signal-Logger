`include "state_defs.svh"

//=======================================================================
// Module: transmitter_decoder
// Description:
//   This module decodes a 32-bit FIFO log entry (`read_data`) into a stream of
//   bytes to be sent over UART. It extracts the timestamp and switch signal from
//   the log entry and outputs them sequentially using a byte-wide UART interface.
//   It manages state via a bit counter and controls UART transmission enable logic.
//=======================================================================

module transmitter_decoder (
    input logic clk, rst,                    // System clock and reset
    input logic tx_ready,                    // UART transmitter is ready to send
    input logic line_trans_en,              // Trigger to begin sending a line
    input log_file_t read_data,             // 32-bit data from FIFO (timestamp + switches)

    output logic tx_enable,                 // Triggers UART to transmit one byte
    output logic line_transmitted,          // Indicates that the full log line was transmitted
    output byte_t log_output                // Byte to be sent over UART
);

    log_timestamp_t temp_data;              // Temporary register for timestamp portion
    byte_t bit_counter;                     // Counter to track number of bytes sent
    logic [1:0] signal;                     // Captures 2-bit switch signal from read_data

    //=======================================================================
    // Byte-wise UART Transmission Logic
    //=======================================================================

always_ff @(posedge clk) begin
    if (rst) begin // REINITIALIZE VALUES
        line_transmitted <= 1;
        bit_counter <= 0;
        temp_data <= 0;
        log_output <= 0;
        tx_enable <= 0;
        signal <= 0;
    end
    else begin
        if (line_trans_en) begin // START TRANSMITTING LOG LINE
            temp_data <= read_data[DATA_WIDTH-1:2]; // Extract timestamp
            signal <= read_data[1:0];               // Extract switch signal bits
            line_transmitted <= 0;
            tx_enable <= 0;
        end
        else if (bit_counter > DATA_WIDTH + 14) begin // End of transmission window
            line_transmitted <= 1;
            bit_counter <= 0;
            tx_enable <= 0;
        end
        else if (tx_enable) tx_enable <= 0; // Drop tx_enable after one cycle
        else if (tx_ready && !line_transmitted) begin // TRANSMITTING BIT by BIT
            tx_enable <= 1;
            bit_counter <= bit_counter + 1;
            case (bit_counter) //TRANSMISSION FORMAT: "TS: '30 timestamp bits(HEX)', S: '2 bit signal'"
                8'd0: log_output <= 8'd84; // "T"

                8'd1: log_output <= 8'd83; // "S"

                8'd2: log_output <= 8'd58; // ":"

                8'd3: log_output <= 8'd32; // " "

                8'd4: log_output <= 8'd48; // "0"

                8'd5: log_output <= 8'd120; // "x "
                                                    // TIMESTAMP
                DATA_WIDTH + 6: log_output <= 8'd44; // ","

                DATA_WIDTH + 7: log_output <= 8'd32; // " "

                DATA_WIDTH + 8: log_output <= 8'd83; // "S"

                DATA_WIDTH + 9: log_output <= 8'd58; // ":"

                DATA_WIDTH + 10: log_output <= 8'd32; // " "

                DATA_WIDTH + 11: log_output <= signal[1] + 8'd48; // SIGNAL

                DATA_WIDTH + 12: log_output <= signal[0] + 8'd48; // SIGNAL

                DATA_WIDTH + 13: log_output <= 8'd10;  // New line after log line

                DATA_WIDTH + 14: log_output <= 8'd13;  // Start new line from the beggining

                default: begin
                    if (temp_data[DATA_WIDTH-3:DATA_WIDTH-6] <= 4'd9) begin
                        log_output <= temp_data[DATA_WIDTH-3:DATA_WIDTH-6] + 8'd48; // Transmit HEX in ASCII
                    end
                    else if (temp_data[DATA_WIDTH-3:DATA_WIDTH-6] > 4'd9) begin
                        log_output <= temp_data[DATA_WIDTH-3:DATA_WIDTH-6] + 8'd55;
                    end
                    bit_counter <= bit_counter + 4;
                    temp_data <=  temp_data << 4;
                end
            endcase
        end
        
    end
end

endmodule