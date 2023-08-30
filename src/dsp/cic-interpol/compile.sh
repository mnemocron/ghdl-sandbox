#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a common.vhd
ghdl -a --ieee=synopsys -Whide integrate.vhd
ghdl -a --ieee=synopsys comb.vhd
ghdl -a --ieee=synopsys cic.vhd
ghdl -a tb_cic_filter.vhd
ghdl -a ../dds/phase_accumulator/phase_accumulator.vhd
ghdl -a ../dds/lut/lut_cos_sfix16_2048_full/mem_cos_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_cos_sfix16_2048_full/lut_cos_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_sin_sfix16_2048_full/mem_sin_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_sin_sfix16_2048_full/lut_sin_sfix16_2048_full.vhd
ghdl -a ../dds/dds.vhd
ghdl -a ../lfsr/lfsr16/lfsr16.vhd

# elaborate
#ghdl -e --ieee=synopsys integrate
#ghdl -e --ieee=synopsys comb
#ghdl -e --ieee=synopsys cic
#ghdl -e phase_accumulator
#ghdl -e mem_cos_sfix16_2048_full
#ghdl -e lut_cos_sfix16_2048_full
#ghdl -e mem_sin_sfix16_2048_full
#ghdl -e lut_sin_sfix16_2048_full
#ghdl -e dds
#ghdl -e lfsr16
ghdl -e tb_cic_filter

# run
ghdl -r tb_cic_filter --vcd=wave.vcd --stop-time=10us
#gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &