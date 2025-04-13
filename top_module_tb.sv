`timescale 1ns/1ps

module top_module_tb;

    // Testbench-controlled inputs to DUT
    logic clk = 0;
    logic rst = 1;
    logic rx = 1;                  // Idle state of UART line is high
    logic raw_switch0 = 0;
    logic raw_switch1 = 0;

    // Output from DUT
    logic tx;

    // Clock generation (12 MHz clock = ~83.3ns period)
    always #41.66 clk = ~clk;

    // Instantiate the DUT
    top_module dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .raw_switch0(raw_switch0),
        .raw_switch1(raw_switch1),
        .tx(tx)
    );

    // Stimulus block
    initial begin
        // Initial reset
        #100;
        rst = 0;

        // Toggle switch to simulate an edge
        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000

        // Send "D" (0x44 = 8'b01000100) over UART (LSB first)
        // UART frame: start(0), data(LSB first), stop(1)
        rx = 0;        // Start bit
        #8680;

        rx = 0;        // Bit 0 (LSB)
        #8680;
        rx = 0;        // Bit 1
        #8680;
        rx = 1;        // Bit 2
        #8680;
        rx = 0;        // Bit 3
        #8680;
        rx = 0;        // Bit 4
        #8680;
        rx = 0;        // Bit 5
        #8680;
        rx = 1;        // Bit 6
        #8680;
        rx = 0;        // Bit 7 (MSB)
        #8680;

        rx = 1;        // Stop bit
        #8680;

        // Idle
        #36000000;

        // Send "S" (0x53 = 8'b01010011) over UART (LSB first)
        // UART frame: start(0), data(LSB first), stop(1)

        rx = 0;   // Start bit
        #8680;

        rx = 1;   // Bit 0 (LSB)
        #8680;
        rx = 1;   // Bit 1
        #8680;
        rx = 0;   // Bit 2
        #8680;
        rx = 0;   // Bit 3
        #8680;
        rx = 1;   // Bit 4
        #8680;
        rx = 0;   // Bit 5
        #8680;
        rx = 1;   // Bit 6
        #8680;
        rx = 0;   // Bit 7 (MSB)
        #8680;

        rx = 1;   // Stop bit
        #8680;

        // Idle
        #60000000;

        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000

        // Send "C" (0x43 = 8'b01000011) over UART (LSB first)
        // UART frame: start(0), data(LSB first), stop(1)

        rx = 0;   // Start bit
        #8680;

        rx = 1;   // Bit 0 (LSB)
        #8680;
        rx = 1;   // Bit 1
        #8680;
        rx = 0;   // Bit 2
        #8680;
        rx = 0;   // Bit 3
        #8680;
        rx = 0;   // Bit 4
        #8680;
        rx = 0;   // Bit 5
        #8680;
        rx = 1;   // Bit 6
        #8680;
        rx = 0;   // Bit 7 (MSB)
        #8680;

        rx = 1;   // Stop bit
        #8680;

        // Idle
        #12000000;

        // Send "T" (0x54 = 8'b01010100) over UART (LSB first)
        // UART frame: start(0), data(LSB first), stop(1)

        rx = 0;   // Start bit
        #8680;

        rx = 0;   // Bit 0 (LSB)
        #8680;
        rx = 0;   // Bit 1
        #8680;
        rx = 1;   // Bit 2
        #8680;
        rx = 0;   // Bit 3
        #8680;
        rx = 1;   // Bit 4
        #8680;
        rx = 0;   // Bit 5
        #8680;
        rx = 1;   // Bit 6
        #8680;
        rx = 0;   // Bit 7 (MSB)
        #8680;

        rx = 1;   // Stop bit
        #8680;

        // Idle
        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch0 = 1;
        raw_switch1 = 1;
        #60000000;
        raw_switch0 = 0;
        #60000000;
        raw_switch1 = 0;
        #60000000;
        raw_switch1 = 1;
        #60000000;
        raw_switch1 = 0;
        #60000000

        $stop;
    end

endmodule
