
ghdl --version

:: delete
del /Q *.vcd &
del /Q *.o &
del /Q *.exe &
del /Q *.cf &

:: analyze
ghdl -a phase_accumulator.vhd
ghdl -a tb_phase_accumulator.vhd

:: elaborate
ghdl -e phase_accumulator
ghdl -e tb_phase_accumulator
:: run
ghdl -r tb_phase_accumulator --vcd=wave.vcd --stop-time=1us
gtkwave wave.vcd waveform.gtkw

:: delete
del /Q *.o &
del /Q *.exe &
del /Q *.cf &
