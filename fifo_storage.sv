//=========================================================================
// Module: fifo_storage
// Description: 
//   A linear FIFO used for logging data. This FIFO is parameterized by address
//   width and data width, and it uses separate read and write pointers along with
//   status flags to indicate whether the FIFO is empty or full. It also includes
//   flush logic to clear stored data when required.
// 
// Parameters:
//   ADDR_WIDTH  - Determines the depth of the FIFO. The FIFO will have (2^ADDR_WIDTH - 1)
//                 entries since FIFO_DEPTH is defined as (1 << ADDR_WIDTH) - 1.
//   DATA_WIDTH  - Width (in bits) of each FIFO entry (log_file_t).
//
// Inputs:
//   clk           - System clock.
//   rst           - Synchronous reset.
//   read_en       - Enables reading data from the FIFO.
//   write_en      - Enables writing data into the FIFO.
//   line_transmitted - Signal indicating that the current line has been transmitted.
//   flush         - When asserted, clears the FIFO (flushes the data).
//   write_data    - Data to be written into the FIFO (of type log_file_t).
//
// Outputs:
//   log_empty     - High if the FIFO is empty.
//   log_full      - High if the FIFO is full.
//   line_trans_en - Pulse indicating that a line is ready for transmission.
//   read_data     - Data read from the FIFO (of type log_file_t).
//
// Notes:
//   - This FIFO is implemented as a linear buffer (no circular wrap-around).
//   - Upon flush, the FIFO is cleared and both pointers are reset.
//   - Full/empty conditions are detected using pointer comparisons.
//=========================================================================

`include "state_defs.svh"

localparam FIFO_DEPTH = 255; // Depth: 2^ADDR_WIDTH - 1
typedef logic [ADDR_WIDTH-1:0] addr_t; // Type for addressing FIFO entries
// CHANGE AFTER DEBUG
module fifo_storage (
    input logic clk,rst, read_en, write_en, line_transmitted, flush,
    input log_file_t write_data,
    output logic log_full, line_trans_en,
    output log_file_t read_data
);

//-------------------------------------------------------------------------
// Pointer and Memory Declarations
//-------------------------------------------------------------------------

addr_t read_ptr, write_ptr;
logic prev_flush;
logic log_empty;
log_file_t fifo [FIFO_DEPTH:0];

//-------------------------------------------------------------------------
// Main FIFO Logic: Handles reset, flush, writing, and reading operations.
//-------------------------------------------------------------------------

always_ff @( posedge clk) begin

    if (rst) begin 
        // Reset Logic: Initialize pointers, flags, and outputs.
        read_ptr <= 0;
        write_ptr <= 0;
        prev_flush <= 0;
        log_empty <= 1;
        log_full <= 0;
        line_trans_en <= 0;
        read_data <= 32'd0;
    end

    else if (flush) begin
        // Flush/Clear Logic: Clear current entry and mark flush.
        fifo[write_ptr] <= 0; 
        write_ptr <= write_ptr + 1;
        prev_flush <= 1;
        log_full <= 0;
        log_empty <= 1;     
    end
    else if (prev_flush && !flush) begin       
        // If a flush has just occurred, reset the pointers for a fresh start.
        write_ptr <= 0;
        prev_flush <= 0;
        read_ptr <= 0;       
    end



    else if (write_en & !log_full) begin
        // Writing Logic: Write data into FIFO if not full.
        write_ptr <= write_ptr + 1;
        log_empty <= 0;
        read_ptr <= 0; // Next read from start
        fifo[write_ptr] <= write_data;
        if (write_ptr == FIFO_DEPTH) log_full <= 1;
    end



    else if (line_trans_en) line_trans_en <= 0;
    else if (read_en & !log_empty & line_transmitted) begin
        // Reading Logic: When enabled, and a line has been transmitted,
        // output the FIFO data at the current read pointer.
        if (fifo[read_ptr] != 0) begin
            line_trans_en <= 1; // Ready for transmission
            read_data <= fifo[read_ptr];
            fifo[read_ptr] <= 0; // Clear FIFO entry after read
        end
        write_ptr <= 0; // Next write from start
        log_full <= 0;
        read_ptr <= read_ptr + 1;
        if (read_ptr == FIFO_DEPTH) log_empty <= 1;
    end
    // Ensure the line_trans_en signal is only pulsed for one clock cycle.


end

endmodule