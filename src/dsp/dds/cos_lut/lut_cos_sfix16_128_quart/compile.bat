
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a mem_cos_sfix16_128_quart.vhd
ghdl -a cos_lut.vhd
ghdl -a lut_cos_sfix16_128_quart.vhd
ghdl -a tb_lut_cos_sfix16_128_quart.vhd

:: elaborate
ghdl -e mem_cos_sfix16_128_quart
ghdl -e cos_lut
ghdl -e lut_cos_sfix16_128_quart
ghdl -e tb_lut_cos_sfix16_128_quart
:: run
ghdl -r tb_lut_cos_sfix16_128_quart --vcd=wave.vcd --stop-time=5us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
