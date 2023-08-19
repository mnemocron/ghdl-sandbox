
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a mem_sin_sfix16_2048_full.vhd
ghdl -a lut_sin_sfix16_2048_full.vhd
ghdl -a tb_lut_sin_sfix16_2048_full.vhd

:: elaborate
ghdl -e mem_sin_sfix16_2048_full
ghdl -e lut_sin_sfix16_2048_full
ghdl -e tb_lut_sin_sfix16_2048_full
:: run
ghdl -r tb_lut_sin_sfix16_2048_full --vcd=wave.vcd --stop-time=12us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
