# mini-risc-v-cpu

A small RISC-V CPU that I designed, verified and took through physical design during the
SiliconJackets onboarding at Georgia Tech in Fall 2026. All three stages work on the same CPU, and
each folder has its own README with the details.

| Stage | What I did | Tools |
| --- | --- | --- |
| [1. Design](rtl/README.md) | Wrote the decode, execute, memory-access and writeback logic and completed the top level of a CPU that runs a subset of RV32I | SystemVerilog, Cadence Xcelium |
| [2. Verification](dv/README.md) | Wrote a test plan, completed a class-based testbench, added assertions, closed coverage, and found three injected bugs in an encrypted version of the CPU | Cadence Xcelium, SimVision, IMC |
| [3. Physical design](pd/README.md) | Synthesis, floorplan, place and route, timing, clock gating, cell swapping and DRC/LVS signoff on SkyWater 130 nm | Synopsys Design Compiler, Cadence Innovus, Pegasus |

## The CPU

The CPU executes ADD, ADDI, SUB, SLL, SRL, LW, SW, BEQ and EBREAK. It fetches from a 1024-word
instruction SRAM and loads and stores to a 1024-word data SRAM. Once it halts, its registers can be
read through an external port. `chip_top` wraps the CPU, both SRAM macros and the memory controller,
and it is the block that both verification and physical design work on.

## Results

**Verification**

- Passes the full directed and constrained-random suite (seed 1, 0 scoreboard mismatches).
- Three SystemVerilog assertions, each shown to fire on a forced violation.
- `dut` reached 98.80% average cumulative block coverage in IMC.
- All three bugs injected into the encrypted CPU were found and explained, each with a short
  reproducer cut from the logged failing program and a waveform.

**Physical design** (target clock 5.0 ns)

- Synthesized to 7661 cells, including the 2 SRAM macros.
- Core of 1,270.736 x 635.368 µm, sized from the macros and their halos at 50% utilization.
- Clock gating inserted, then high-speed cells swapped in: setup WNS went from −2.795 ns to
  −2.648 ns and TNS from −1728.2 ns to −1280.1 ns.
- After routing, hold timing closes (WNS 0.188 ns). Setup does not close at 5.0 ns, mainly because
  the SRAM's clock-to-data delay alone is about 2.4 ns.
- LVS is clean. DRC still reports 97 results, 86 of them on one rule.

## Layout

```
rtl/   CPU source, chip top, SRAM wrapper and model, RTL tests, shared simulation flow (sim/behav)
dv/    Test plans, waveforms, coverage summary, bug-hunt evidence
pd/    Synthesis and place-and-route scripts, reports, signoff results, screenshots
```

The testbench lives in `rtl/src/verilog/tb/` so that the RTL tests and the verification suite run
from the same `sim/behav` flow.

## Running it

Everything here was run on Georgia Tech's ECE servers with Cadence and Synopsys tools, the
licenses that come with them, and the club's setup. Without that environment you can read the
code, scripts and reports but not rerun the flows.

## What is not here

- The encrypted bug-hunt CPUs, which belong to the club.
- PDK and standard-cell library files, which belong to SkyWater and the tool and IP vendors.
- Large simulator logs and databases.

Each stage's README says which files the club provided and which I wrote.
