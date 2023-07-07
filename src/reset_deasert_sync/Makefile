# Makefile

# defaults
SIM ?= ghdl 
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/reset_deasert_sync.vhd
# use VERILOG_SOURCES for verilog

# to get waveform
WAVEFORM_VIEWER = gtkwave
WAVEFILE = wave
SIM_ARGS+=--vcd=$(WAVEFILE).vcd

# TOPLEVEL is the name of the toplevel module in your verilog or VHDL file
TOPLEVEL := reset_deasert_sync

# MODULE is the basename of the Python test file
MODULE := test_reset_deasert_sync

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	@$(WAVEFORM_VIEWER) --dump=$(WAVEFILE).vcd waveform.gtkw
