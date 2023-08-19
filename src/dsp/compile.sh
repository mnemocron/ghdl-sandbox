#!/usr/bin/bash

ghdl --version | head -n 1

# delete
rm -rf *.vcd &
rm -rf *.cf &

# analyze
ghdl -a dds/phase_accumulator/phase_accumulator.vhd
ghdl -a dds/lut/lut_cos_sfix16_2048_full/mem_cos_sfix16_2048_full.vhd
ghdl -a dds/lut/lut_cos_sfix16_2048_full/lut_cos_sfix16_2048_full.vhd
ghdl -a dds/lut/lut_sin_sfix16_2048_full/mem_sin_sfix16_2048_full.vhd
ghdl -a dds/lut/lut_sin_sfix16_2048_full/lut_sin_sfix16_2048_full.vhd
ghdl -a dds/dds.vhd
ghdl -a testbench_dsp.vhd

# elaborate
ghdl -e phase_accumulator
ghdl -e mem_cos_sfix16_2048_full
ghdl -e lut_cos_sfix16_2048_full
ghdl -e mem_sin_sfix16_2048_full
ghdl -e lut_sin_sfix16_2048_full
ghdl -e dds
ghdl -e testbench_dsp

# run
ghdl -r testbench_dsp --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

# delete
rm -rf *.vcd &
rm -rf *.cf &
