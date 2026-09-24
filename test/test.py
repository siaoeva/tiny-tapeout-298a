# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

# ui_in bits: en=0, load=1, up_down=2, oe=3
EN, LOAD, UP, OE = 0x01, 0x02, 0x04, 0x08


async def setup(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)


async def step(dut, n=1):
    """Wait n clock cycles, then let outputs settle."""
    await ClockCycles(dut.clk, n)
    await Timer(1, "ns")


@cocotb.test()
async def test_load(dut):
    await setup(dut)

    dut.uio_in.value = 0xA5
    dut.ui_in.value = LOAD
    await step(dut)
    dut.ui_in.value = 0

    assert dut.uo_out.value == 0xA5


@cocotb.test()
async def test_count_up_down(dut):
    await setup(dut)

    # load 10
    dut.uio_in.value = 10
    dut.ui_in.value = LOAD
    await step(dut)

    # count up 3 times -> 13
    dut.ui_in.value = EN | UP
    await step(dut, 3)
    assert dut.uo_out.value == 13

    # count down 2 times -> 11
    dut.ui_in.value = EN
    await step(dut, 2)
    assert dut.uo_out.value == 11


@cocotb.test()
async def test_drive_output(dut):
    await setup(dut)

    dut.uio_in.value = 0x3C
    dut.ui_in.value = LOAD
    await step(dut)

    # oe=1: pins are driven with the count
    dut.ui_in.value = OE
    await step(dut)
    assert dut.uio_oe.value == 0xFF
    assert dut.uio_out.value == 0x3C


@cocotb.test()
async def test_drive_z(dut):
    await setup(dut)

    # oe=0: pins are released (high-Z at the pad)
    dut.ui_in.value = 0
    await step(dut)
    assert dut.uio_oe.value == 0x00