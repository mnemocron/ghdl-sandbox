
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

:: elaborate
ghdl -e fir_tap
ghdl -e fir_unoptimized
ghdl -e tb_fir_unoptimized

:: run
ghdl -r tb_fir_unoptimized --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
