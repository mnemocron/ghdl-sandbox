
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a phase_accumulator/phase_accumulator.vhd
ghdl -a lut/mem_cos_sfix16_2048_full.vhd
ghdl -a lut/lut_cos_sfix16_2048_full.vhd
ghdl -a dds.vhd
ghdl -a tb_dds.vhd

:: elaborate
ghdl -e phase_accumulator
ghdl -e mem_cos_sfix16_2048_full
ghdl -e lut_cos_sfix16_2048_full
ghdl -e dds
ghdl -e tb_dds
:: run
ghdl -r tb_dds --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
