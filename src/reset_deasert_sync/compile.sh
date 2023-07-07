#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a reset_deasert_sync.vhd
ghdl -a tb_reset_sync.vhd

# elaborate
ghdl -e reset_deasert_sync
ghdl -e tb_reset_sync
# run
ghdl -r tb_reset_sync --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
