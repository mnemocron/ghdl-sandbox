#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a lfsr16.vhd
ghdl -a tb_lfsr16.vhd

# elaborate
ghdl -e lfsr16
ghdl -e tb_lfsr16

# run
ghdl -r tb_lfsr16 --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
