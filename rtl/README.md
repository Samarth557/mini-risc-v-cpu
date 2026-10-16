# Digital Design: RISC-V Subset CPU

> Draft. The RTL here is the copy of my CPU from the DV submission. The uploaded DD repo zip is the
> club's starter version, so it was used only to tell provided files apart from mine.

A CPU written for the SiliconJackets Fall 2026 Digital Design onboarding. It runs a
subset of RV32I (ADD, ADDI, SUB, SLL, SRL, LW, SW, BEQ, EBREAK) out of a 1024-word instruction SRAM and a
1024-word data SRAM, and its register file can be read from outside the chip once the CPU halts.

## Modules

Authorship below comes from comparing my CPU against the club's starter repo.

| File | Role | Source |
| --- | --- | --- |
| `decode.sv` | Field extraction and immediate generation | Mine (not in starter) |
| `execute.sv` | ALU, shifts and branch comparison | Mine (not in starter) |
| `mem_access.sv` | LW/SW requests to data SRAM | Mine (not in starter) |
| `writeback.sv` | Selects ALU result or loaded data for the destination | Mine (not in starter) |
| `cpu_top.sv` | Stage wiring and stall logic | Starter stub, completed by me |
| `fetch.sv` | Instruction fetch | Provided; I only added comments |
| `reg_file.sv` | 32 x 32 register file, `x0` reads as zero | Provided, unchanged |
| `cpu_pkg.sv` | Instruction-type enum | Provided, unchanged |

The chip top, memory controller, SRAM wrapper, SRAM model, processor testbench and the test
programs under `tests/` were all provided by the club.

## Verification

This CPU is the design under test in the [DV work](../dv/README.md), where it passes every
directed and random test.
