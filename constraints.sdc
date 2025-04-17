create_clock -name clk -period 83.333 [get_ports clk]
set_false_path -to [get_ports tx]
