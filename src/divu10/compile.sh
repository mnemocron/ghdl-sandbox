#!/bin/bash

ghdl --version | head -n 1

# delete
# rm -rf *.vcd &
# rm -rf *.o &
# rm -rf *.exe &
# rm -rf *.cf &

# analyze
ghdl -a divu10.vhd
ghdl -a divu10_tb.vhd

# elaborate
ghdl -e divu10
ghdl -e divu10_tb
# run
ghdl -r divu10_tb --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
# rm -rf *.o &
# rm -rf *.exe &
# rm -rf *.cf &
