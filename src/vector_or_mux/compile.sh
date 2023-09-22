#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a vector_or_mux.vhd
ghdl -a tb_vector_or_mux.vhd

# elaborate
ghdl -e vector_or_mux
ghdl -e tb_vector_or_mux

# run
ghdl -r tb_vector_or_mux --vcd=wave.vcd --stop-time=3us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
