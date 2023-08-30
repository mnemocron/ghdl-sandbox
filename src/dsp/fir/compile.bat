
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a fir_tap.vhd
ghdl -a fir_unoptimized.vhd
ghdl -a tb_fir_unoptimized.vhd
ghdl -a ../dds/phase_accumulator/phase_accumulator.vhd
ghdl -a ../dds/lut/lut_cos_sfix16_2048_full/mem_cos_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_cos_sfix16_2048_full/lut_cos_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_sin_sfix16_2048_full/mem_sin_sfix16_2048_full.vhd
ghdl -a ../dds/lut/lut_sin_sfix16_2048_full/lut_sin_sfix16_2048_full.vhd
ghdl -a ../dds/dds.vhd
ghdl -a ../lfsr/lfsr16/lfsr16.vhd

:: elaborate
ghdl -e fir_tap
ghdl -e fir_unoptimized
ghdl -e tb_fir_unoptimized
ghdl -e phase_accumulator
ghdl -e mem_cos_sfix16_2048_full
ghdl -e lut_cos_sfix16_2048_full
ghdl -e mem_sin_sfix16_2048_full
ghdl -e lut_sin_sfix16_2048_full
ghdl -e dds
ghdl -e lfsr16

:: run
ghdl -r tb_fir_unoptimized --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
