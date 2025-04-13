🚀 UART-Based Signal Logger on FPGA

📌 Project Overview

This FPGA project implements a UART-based digital signal logger using a modular Verilog architecture. The system:

- Monitors digital switch activity with hardware debouncing
- Logs transitions with a timestamp into an internal FIFO buffer
- Transmits log entries over UART to a connected PC
- Supports command-based control (start, stop, dump, clear) via UART input
- Is fully synthesizable and deployable on the ICEBreaker FPGA

⚡ Features

✅ Finite State Machine (FSM) Logger Control  
✅ UART Receiver (Command Input)  
✅ UART Transmitter (Log Output in ASCII)  
✅ FIFO Buffer for Timestamped Event Storage  
✅ Debounced Dual-Switch Edge Detection  
✅ Fully Synthesizable on ICEBreaker FPGA

📜 Hardware Requirements

🖥️ ICEBreaker FPGA (Lattice iCE40UP5K)  
🔘 2 Switches (Monitored Inputs)  
💡 3 LEDs (Optional Debug/State Display)  
🖧 USB-UART Interface (FTDI/CH340)  
💻 PC with a Serial Monitor (Tera Term, Minicom, PuTTY)

🛠️ File Structure

FPGA_Projects/signal_logger_fpga/ │ ├── top_module.sv # Top-level module integrating all components ├── signal_logger.sv # FSM for logging and state transitions ├── fifo_storage.sv # FIFO buffer for storing log entries ├── transmitter_decoder.sv # Converts FIFO log into UART-readable ASCII ├── signal_tx.sv # UART transmitter (8N1, 115200 baud) ├── signal_rx.sv # UART receiver (interprets user commands) ├── state_select.sv # Decodes UART input to FSM states ├── switch_debounce.sv # Debounce logic for both monitored switches ├── state_defs.svh # Global parameters and type definitions ├── constraints.pcf # FPGA pin assignments └── top_module_tb.sv # Simulation testbench (behavioral UART tests)

💾 Synthesis & Programming (ICEBreaker FPGA)

Use the following commands to synthesize and upload the design:

yosys -p "read_verilog -sv state_defs.svh; read_verilog -sv top_module.sv; read_verilog -sv signal_logger.sv; read_verilog -sv signal_tx.sv; read_verilog -sv signal_rx.sv; read_verilog -sv transmitter_decoder.sv; read_verilog -sv fifo_storage.sv; read_verilog -sv state_select.sv; read_verilog -sv switch_debounce.sv; synth_ice40 -top top_module -json top_module.json"

nextpnr-ice40 --up5k --package sg48 --json top_module.json --pcf constraints.pcf --asc top_module.asc --freq 12

icepack top_module.asc top_module.bin

iceprog top_module.bin

📡 UART Communication

The system uses a 115200 baud, 8N1 UART protocol to receive commands and transmit log data in human-readable ASCII.

ASCII | Command	Action

S        Start Logging

T        Stop Logging

D	       Dump Log via UART

C	       Clear FIFO Buffer


📤 Log Format (ASCII Output)

TS: 0x00012345, S: 10
TS: 0x000123A7, S: 01
TS: 0x00012410, S: 00

Each line represents a logged switch event:

TS is the 30-bit timestamp

S is the 2-bit switch state (SW1, SW0)

🔍 How It Works

On power-up, the system waits for a UART "S" command to begin logging

When a switch edge is detected, the current timestamp and switch state are stored in the FIFO

The "D" command sends all FIFO contents over UART

The "C" command flushes the FIFO and resets the logger

The "T" command pauses event logging until restarted

👤 Created by David Francos
🛠️ Built on Verilog using the ICEBreaker FPGA
