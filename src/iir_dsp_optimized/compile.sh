#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a --ieee=synopsys -fsynopsys iir_df1_dsp48.vhd
ghdl -a --ieee=synopsys -fsynopsys axis_fir_dsp48.vhd
ghdl -a --ieee=synopsys -fsynopsys tb_iir.vhd

# elaborate
ghdl -e iir_df1_dsp48
ghdl -e axis_fir_dsp48
ghdl -e tb_iir
# run
ghdl -r tb_iir --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
