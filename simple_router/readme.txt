Simple routing switch with 1 cycle of latency.
The router reads data from FIFO and passes it to the output port.
FIFO feedback is combinational, data is latched in a flip-flop.
Remove data and valid FF to achieve 0 latency.