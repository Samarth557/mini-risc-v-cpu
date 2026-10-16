set_clock_latency -source -early -min -rise  -1.1367 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -early -min -fall  -1.01097 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -early -max -rise  -1.1367 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -early -max -fall  -1.01097 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -late -min -rise  -1.1367 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -late -min -fall  -1.01097 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -late -max -rise  -1.1367 [get_ports {clk_i}] -clock coreClk 
set_clock_latency -source -late -max -fall  -1.01097 [get_ports {clk_i}] -clock coreClk 
