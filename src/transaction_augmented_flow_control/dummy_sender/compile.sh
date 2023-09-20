#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a dummy_sender.vhd
ghdl -a tb_dummy_sender.vhd

# elaborate
ghdl -e dummy_sender
ghdl -e tb_dummy_sender

# run
ghdl -r tb_dummy_sender --vcd=wave.vcd --stop-time=3us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
