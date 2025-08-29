axi_pyuvm_starter/
├── Makefile
├── sim/
│   ├── adder.v
│   ├── test_basic.py         <- Cocotb test
│   └── test_uvm.py           <- pyuvm test
└── README.md

module adder (
    input  [1:0] a,
    input  [1:0] b,
    output [2:0] sum
);
    assign sum = a + b;
endmodule

import cocotb
from cocotb.triggers import Timer
import random

@cocotb.test()
async def test_adder_basic(dut):
    """Simple adder test using cocotb"""
    for _ in range(5):
        a = random.randint(0, 3)
        b = random.randint(0, 3)
        dut.a.value = a
        dut.b.value = b
        await Timer(10, units="ns")
        assert dut.sum.value == a + b, f"Wrong sum: {dut.sum.value}"

import cocotb
from cocotb.triggers import Timer
from pyuvm import *

class AdderTransaction(uvm_sequence_item):
    def __init__(self, a=0, b=0):
        super().__init__()
        self.a = a
        self.b = b

class AdderDriver(uvm_component):
    def build_phase(self):
        self.port = uvm_seq_item_pull_port("port", self)

    async def run_phase(self):
        while True:
            txn = await self.port.get_next_item()
            cocotb.top.a.value = txn.a
            cocotb.top.b.value = txn.b
            await Timer(10, units="ns")
            self.port.item_done()

class AdderTest(uvm_test):
    def build_phase(self):
        self.driver = AdderDriver("driver", self)
        self.seq = uvm_sequence("seq", self)
    
    async def run_phase(self):
        for _ in range(5):
            txn = AdderTransaction(a=random.randint(0,3), b=random.randint(0,3))
            await self.seq.start(self.driver.port, txn)

@cocotb.test()
async def run_uvm_test(dut):
    await uvm_root().run_test("AdderTest")

import cocotb
from cocotb.triggers import Timer
from pyuvm import *

class AdderTransaction(uvm_sequence_item):
    def __init__(self, a=0, b=0):
        super().__init__()
        self.a = a
        self.b = b

class AdderDriver(uvm_component):
    def build_phase(self):
        self.port = uvm_seq_item_pull_port("port", self)

    async def run_phase(self):
        while True:
            txn = await self.port.get_next_item()
            cocotb.top.a.value = txn.a
            cocotb.top.b.value = txn.b
            await Timer(10, units="ns")
            self.port.item_done()

class AdderTest(uvm_test):
    def build_phase(self):
        self.driver = AdderDriver("driver", self)
        self.seq = uvm_sequence("seq", self)
    
    async def run_phase(self):
        for _ in range(5):
            txn = AdderTransaction(a=random.randint(0,3), b=random.randint(0,3))
            await self.seq.start(self.driver.port, txn)

@cocotb.test()
async def run_uvm_test(dut):
    await uvm_root().run_test("AdderTest")

make MODULE=test_basic
make MODULE=test_uvm
