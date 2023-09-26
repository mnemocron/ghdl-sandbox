#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a pause_req_cdc_ctrl.vhd
ghdl -a tb_pause_req_cdc_ctrl.vhd

# elaborate
ghdl -e pause_req_cdc_ctrl
ghdl -e tb_pause_req_cdc_ctrl

# run
ghdl -r tb_pause_req_cdc_ctrl --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
