
# Constraining CDC paths

https://docs.xilinx.com/r/en-US/ug949-vivado-design-methodology/Constraints-on-Individual-CDC-Paths


## max-delay

```tcl
######################################################
## set property on clock-domain-crossing (CDC) signals
######################################################
 
# constraint between src-clk-domain FF and 1st dst-clk-domain with a metastable output (max-delay)
#------------------------------------------------------------------------------------------------
# note: from 1st src-clk-domain flipflop to 1st dst-clk-domain flipflop (max-delay) -> implementation constraints (this file)
#       from 1st dst-clk-domain flipflop to 2nd dst-clk-domain flipflop (async_reg) -> synthesis constraints (other file)
 
#-------------------------------------------------------------
# i0_rx_fsm -> i0_clock_domain_crossing
#-------------------------------------------------------------
set_max_delay -datapath_only 8 -from [get_cells -hier -filter {NAME =~ */i0_udp_core/i0_rx/i0_rx_fsm/error_valid_toggle_cs_reg}]                            -to [get_cells -hier -filter {NAME =~ */i0_udp_core/i0_rx/i0_clock_domain_crossing/error_valid_toggle_d1_reg}]
```
 
## async-reg
 
```tcl
##############################################################
# 4) set property on clock-domain-crossing (CDC) signals
#    constraint between 1st and 2nd dst-clk-domain (async_reg)
##############################################################
 
#-------------------------------------------------------------
# clock_domain_crossing (sc-fifo)
# - wr-clk: gmii_rx_clk
# - rd-clk: sys_clk
#-------------------------------------------------------------
# a) constrain signals from gmii_rx_clk to sys_clk (wr -> rd)
set_property async_reg "true" [get_cells -hier -filter {NAME =~ */i0_udp_core/i0_rx/i0_clock_domain_crossing/error_valid_toggle_d1_reg}]
set_property async_reg "true" [get_cells -hier -filter {NAME =~ */i0_udp_core/i0_rx/i0_clock_domain_crossing/error_valid_toggle_d2_reg}]
```

