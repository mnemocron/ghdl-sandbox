#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a lfsr32.vhd
ghdl -a tb_lfsr32.vhd

# elaborate
ghdl -e lfsr32
ghdl -e tb_lfsr32

# run
ghdl -r tb_lfsr32 --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
