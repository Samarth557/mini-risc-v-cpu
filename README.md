# mini-risc-v-cpu

A small RISC-V CPU that I designed, verified, and took through physical design during the
SiliconJackets onboarding at Georgia Tech in Fall 2026. Each folder covers one stage of the
work on the same CPU.

| Stage | What I did | Tools |
| --- | --- | --- |
| [1. Design](rtl/README.md) | Wrote the decode, execute, memory-access and writeback logic and completed the top level of a CPU that runs a subset of RV32I | SystemVerilog |
| [2. Verification](dv/README.md) | Wrote a test plan, completed a class-based testbench, added assertions, closed coverage, and found three injected bugs in an encrypted version of the CPU | Cadence Xcelium, SimVision, IMC |
| [3. Physical design](pd/README.md) | Synthesis, floorplan, place and route, timing, clock gating, cell swapping and signoff on sky130 | Synopsys Design Compiler, Cadence Innovus |

## The CPU

The CPU executes ADD, ADDI, SUB, SLL, SRL, LW, SW, BEQ and EBREAK. It fetches from a 1024-word
instruction SRAM and loads and stores to a 1024-word data SRAM. Once it halts, the testbench can
read its registers through an external port.

## Highlights

- The CPU passes the full directed and constrained-random suite (seed 1, 0 scoreboard mismatches).
- Three SystemVerilog assertions, each shown to fire on a forced violation.
- `dut` reached 98.80% average cumulative block coverage in IMC.
- All three injected bugs in the encrypted CPU were found and explained. Each one comes with a short
  reproducer cut from the logged failing program and a waveform.

## What is not here

The club's starter code, the encrypted bug-hunt CPU, the SRAM macro, PDK and library files, and
simulator databases belong to SiliconJackets or to tool and IP vendors, so they are left out. Each
stage's README says what was provided and what I wrote.
