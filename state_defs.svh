`ifndef STATE_DEFS_SVH
`define STATE_DEFS_SVH

  //=======================================================================
  // File: state_defs.svh
  // Description:
  //   Global parameter and type definitions shared across logger modules.
  //   Includes data/address width settings, UART configuration, and
  //   logger FSM state enumeration.
  //=======================================================================

  // General system parameters
  parameter int DATA_WIDTH   = 32;         // Width of a log entry (timestamp + metadata)
  parameter int ADDR_WIDTH   = 8;          // FIFO address width (for 2^8 = 256 entries)
  parameter int CLOCK_FREQ_HZ = 12_000_000; // System clock frequency (12 MHz)
  parameter int BAUD_RATE    = 115_200;    // UART baud rate for transmission

  // Logger FSM states
  typedef enum logic [1:0] {
    START,   // Start logging
    STOP,    // Pause logging
    DUMP,    // Dump FIFO contents over UART
    CLEAR    // Clear FIFO and reset state
  } state_t;

  // Common logic types
  typedef logic [7:0] byte_t;                        // 8-bit data byte
  typedef logic [DATA_WIDTH-1:0] log_file_t;         // Full log entry (timestamp + signal)
  typedef logic [DATA_WIDTH-3:0] log_timestamp_t;    // Timestamp field (30 bits out of 32)

`endif