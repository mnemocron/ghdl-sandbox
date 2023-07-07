#!/usr/bin/python3

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

ACLK_PERIOD = 5.0


@cocotb.test()
async def stim_input(dut):
	cocotb.start_soon(Clock(dut.clk, ACLK_PERIOD, units="ns").start())

	dut.i_resetn.value = 1
	await RisingEdge(dut.clk)
	# asynch assert of reset
	await Timer(ACLK_PERIOD/10, units="ns")
	dut.i_resetn = 0
	await Timer(ACLK_PERIOD/10, units="ns")
	assert dut.o_resetn == 0 , f"Asynchronous assert failed!"
	await RisingEdge(dut.clk)
	await RisingEdge(dut.clk)
	# asynch deassert of reset
	await Timer(ACLK_PERIOD/10, units="ns")
	dut.i_resetn = 1
	assert dut.o_resetn == 0 , f"Synchronous deassert failed!"
	await RisingEdge(dut.clk)
	await Timer(ACLK_PERIOD/10, units="ns")
	assert dut.o_resetn == 1 , f"Synchronous deassert failed!"

