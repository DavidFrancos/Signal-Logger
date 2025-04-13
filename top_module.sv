`include "state_defs.svh"

//=======================================================================
// Module: top_module
// Description:
//   Top-level integration module for the signal logging system.
//   Handles instantiation and wiring of the logger FSM, FIFO, debouncer,
//   and UART communication logic. Acts as the central glue logic for
//   signal acquisition, logging, and transmission.
//=======================================================================
module top_module (
    input logic clk, rst,             // System clock and synchronous reset
    input logic rx,                  // UART receive input
    input logic raw_switch0,         // Raw switch input 0 (to be debounced)
    input logic raw_switch1,         // Raw switch input 1 (to be debounced)
    output logic tx                 // UART transmit output
);

    //===================================================================
    // Internal Signal Declarations
    //===================================================================
    log_file_t read_data, write_data;       // FIFO read/write data bus
    state_t logger_state;                   // Current state of the logger FSM
    state_t new_logger_state;               // Next state of the logger FSM

    byte_t log_input, log_output;           // UART communication data buffers

    logic tx_ready, line_trans_en;          // UART transmission control
    logic tx_enable, rx_enable;             // UART control enables
    logic line_transmitted;                 // UART transmission complete flag

    logic debounced_switch0, debounced_switch1; // Debounced switch outputs

    logic log_empty, log_full;              // FIFO status signals
    logic write_en, read_en, flush;         // FIFO control signals

    //===================================================================
    // Logger Finite State Machine (FSM)
    //===================================================================
    signal_logger logger_FSM ( 
        .clk(clk),
        .rst(rst),
        .debounced_switch0(debounced_switch0),
        .debounced_switch1(debounced_switch1),
        .write_data(write_data),
        .log_full(log_full),
        .write_en(write_en),
        .new_logger_state(new_logger_state),
        .logger_state(logger_state),
        .read_en(read_en),
        .flush(flush)
    );

    //===================================================================
    // Log file to UART byte decoder
    //===================================================================
    transmitter_decoder decoder ( 
        .clk(clk),
        .rst(rst),
        .tx_ready(tx_ready),
        .line_trans_en(line_trans_en),
        .read_data(read_data),
        .tx_enable(tx_enable),
        .line_transmitted(line_transmitted),
        .log_output(log_output)
    );

    //===================================================================
    // State machine input decoder
    //===================================================================
    state_select state_machine ( 
        .log_input(log_input),
        .logger_state(logger_state),
        .new_logger_state(new_logger_state)
    );

    //===================================================================
    // RX UART Signal receiver
    //===================================================================
    signal_rx signal_receiver (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_enable(rx_enable),
        .log_input(log_input)
    );

    //===================================================================
    // TX UART Signal transmitter
    //===================================================================
    signal_tx signal_transmitter (
        .clk(clk),
        .rst(rst),
        .tx(tx),
        .tx_enable(tx_enable),
        .tx_ready(tx_ready),
        .log_output(log_output)
    );

    //===================================================================
    // Debouncer for LSB switch
    //===================================================================
    switch_debounce debouncer0 ( 
        .clk(clk), 
        .rst(rst),
        .raw_switch(raw_switch0),
        .debounced_switch(debounced_switch0)
    );

    //===================================================================
    // Debouncer for MSB switch
    //===================================================================
    switch_debounce debouncer1 ( 
        .clk(clk), 
        .rst(rst),
        .raw_switch(raw_switch1),
        .debounced_switch(debounced_switch1)
    );

    //===================================================================
    // FIFO Storage for LOG FILES
    //===================================================================
    fifo_storage fifo ( 
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .read_data(read_data),
        .write_data(write_data),
        .log_empty(log_empty),
        .log_full(log_full),
        .write_en(write_en),
        .line_trans_en(line_trans_en),
        .line_transmitted(line_transmitted),
        .read_en(read_en)
    );

endmodule