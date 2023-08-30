#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a transaction_flow_control.vhd
ghdl -a tb_transaction_flow_control.vhd

# elaborate
ghdl -e transaction_flow_control
ghdl -e tb_transaction_flow_control

# run
ghdl -r tb_transaction_flow_control --vcd=wave.vcd --stop-time=3us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
