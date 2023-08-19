
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a dds/phase_accumulator/phase_accumulator.vhd
ghdl -a dds/lut/mem_cos_sfix16_2048_full.vhd
ghdl -a dds/lut/lut_cos_sfix16_2048_full.vhd
ghdl -a dds/dds.vhd
ghdl -a tb_dsp_dut.vhd

:: elaborate
ghdl -e phase_accumulator
ghdl -e mem_cos_sfix16_2048_full
ghdl -e lut_cos_sfix16_2048_full
ghdl -e dds
ghdl -e tb_dds_dut
:: run
ghdl -r tb_dds_dut --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
