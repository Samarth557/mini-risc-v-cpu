# Fall 2026 DV Onboarding Test Plan

## Document information

| Field | Value |
| --- | --- |
| Verification engineer | Samarth Gupta |
| Plan revision | Final |
| Date | 2026-10-01 |

### Revision history

| Revision | Date | Changes |
| --- | --- | --- |
| Initial | 2026-09-24 | Initial planned tests |
| Second rev | 2026-09-30 | Incorporated lead feedback on the initial testplan: added corner-case instruction tests for SLL/SRL and LW/SW and an external-port test covering halt during program execution.Removed `read_and_write_en` as a directed test because of the `NO_SIMULTANEOUS_READ_WRITE` assertion, fixed the `check_beq_func` expected results, reworked `c_mem_align` to constrain against the runtime register value instead of the immediate alone, and added both signed extremes to `c_data_corners`. |
| Final | 2026-10-01 | Added `external_port_window`, `reg_window_aliasing`, `dsram_full_depth`, `check_double_beq`, and `check_consecutive_sw` to close `dut`coverage to 98% . Filled in final results, bug-hunt info for all three required bugs, and assertion-violation evidence with waveform references. |

## 1. Functional tests

### Functional-test summary

| Test ID | Test name | Functionality being tested | Expected result | Status |
| --- | --- | --- | --- | --- |
| 1.1 | `window_instr_sram` | Instruction SRAM window decode on `addr_i[13:12] == 2'b00`, first and last word of the 1024-word range | First and last written word read back unchanged, no leak into another window | Pass |
| 1.2 | `check_cpu_pulse` | Behavior of `cpu_halted_o` across a halt | `x3 = 3`: `cpu_halted_o` rises only while the CPU is active, checked by assertion 3.3 | Pass |
| 1.3 | `try_regfile_write` | External write attempt to the read-only register window | Register value unchanged | Removed |
| 1.4 | `addi_neg_imm` | ADDI with a negative immediate | Subtracts the negative immediate from the register value | Pass |
| 1.5 | `check_beq_func` | BEQ does not branch when `rs1 != rs2` | Falls through, both following instructions execute | Pass |
| 1.6 | `honor_x0` | Write attempt to `x0` through ADDI | `x0` stays 0 | Pass |
| 1.7 | `check_sll_srl` | SLL and SRL at shift amounts 0 and 31, and a round trip through both | Correct shift in both directions at both corners | Pass |
| 1.8 | `check_lw_sw` | LW/SW at word 0 and at a computed high address near the top of data SRAM | Store then load returns the stored value at both addresses | Pass |
| 1.9 | `external_port_window` | External port reaches Instr SRAM, Data SRAM, and the register window independently, at the first and last word of each SRAM | Each window returns exactly what was written, with no corruption between windows | Pass |
| 1.10 | `reg_window_aliasing` | Register-window reads with `addr[11:7] != 0` | Decode uses `addr[6:2]` only, the upper bits are Xs and the read still returns the correct register | Pass |
| 1.11 | `dsram_full_depth` | A loop drives every DSRAM word address, 0 through 1023, with a store/load pair | Checksum over all 1024 store/loads matches the expected sum | Pass |
| 1.12 | `check_double_beq` | 2 back to back self-comparing branches, each skipping instructions | Both skipped-over instructions never execute | Pass |
| 1.13 | `check_consecutive_sw` | Three stores to distinct addresses, two of them writing zeroes as data, separated by a differently valued sw| All three stores reach data SRAM at the correct address with the correct data,and we make sure that a zero-data store is not silently dropped | Pass |

### Functional-test details

### 1.1 — `window_instr_sram`

**Functionality:** Verifies that the SRAM instruction window is correctly decoded from the external address `addr_i[13:12]` (`2'b00`). Writes and reads the first word (byte address `0x0000`) and the last word of the 1024-word range (byte address `0x0FFC`) to make sure the decode logic does not leak into another window.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled for the duration of this test (`en_cpu_i` never pulsed)

**Program:**

```systemverilog
seqr.send_write_trans(word_addr(ISRAM_BASE, 0),    32'hAAAA_AAAA);
seqr.send_write_trans(word_addr(ISRAM_BASE, 1023), 32'h5555_5555);
seqr.send_read_trans(word_addr(ISRAM_BASE, 0));
seqr.send_read_trans(word_addr(ISRAM_BASE, 1023));
seqr.wait_for_empty();
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `addr_i = 14'h0000` | `32'hAAAA_AAAA` | written to the low edge of the range, then read back |
| `addr_i = 14'h0FFC` | `32'h5555_5555` | written to the high edge of the range, with a distinct pattern so a window corruption is visible in the log |

**Pass criteria:** reads at `0x0000` and `0x0FFC` return the values written to those addresses. The scoreboard records the predicted value from the write and the monitor independently reports the DUT's actual read response.

**Final result:** Pass, `evidence/normal_cpu_passed.log`. Both corner reads matched, no stuck bits or window corruption observed.

### 1.2 — `check_cpu_pulse`

**Functionality:** Runs one instruction and an EBREAK so the CPU halts, while assertion 3.3 (`CPU_HALT_PULSE_CHECK`) watches `cpu_halted_o` on every cycle.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
drv.reset_task();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(3)),
    EBREAK_WORD
};
run_directed("check_cpu_pulse", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x3` | `3` | `0 + 3`, so the CPU ran normally before the halt |
| `cpu_halted_o` | rises once, at the EBREAK, while the CPU is active | checked by `CPU_HALT_PULSE_CHECK` (3.3) |

**Pass criteria:** `x3` matches and `CPU_HALT_PULSE_CHECK` does not fire.

**Final result:** Pass. `evidence/normal_cpu_passed.log`: `cpu_halted_o` asserted at 126725 ns, `x3 = 0x00000003` matched at 126805 ns, and the run ended with 0 assertion failures.

### 1.3 — `try_regfile_write`

**Functionality:** Removed because of redundancy: the scoreboard catches this error anyways.
### 1.4 — `addi_neg_imm`

**Functionality:** Performs a subtraction by adding a negative immediate with ADDI.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(-3)),
    EBREAK_WORD
};
run_directed("addi_neg_imm", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x1` | `10` | `0 + 10` |
| `x2` | `7` | `10 + (-3)` |

**Pass criteria:** `x1` and `x2` match.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. Both values matched.

### 1.5 — `check_beq_func`

**Functionality:** Verifies BEQ does not branch when `rs1 != rs2`.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
    asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(0), .imm(8)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(1)),
    asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(2)),
    EBREAK_WORD
};
run_directed("check_beq_func", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x1` | `5` | set to a non-zero value so the comparison against `x0` actually makes sense |
| `x2` | `1` | beq falls through since `x1 (5) != x0 (0)`, and this instr executes |
| `x3` | `2` | falls through again, so this instr also executes |


**Pass criteria:** `x1`, `x2`, and `x3` all match, and no branch is taken.

**Final result:** Pass. `evidence/normal_cpu_passed.log` :all three registers matched as expected.

### 1.6 — `honor_x0`

**Functionality:** Tests that `x0` cannot be made non-zero through a normal instruction write.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(0), .rs1(0), .imm(5)),
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1)),
    EBREAK_WORD
};
run_directed("honor_x0", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x0` | `0` | write attempt ignored |
| `x1` | `1` | `0 + 1`; also shows `x0` was read as 0 by this instruction |

**Pass criteria:** `x0` stays 0; `x1` matches.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. Both reg matched, also exercised by assertion 3.2, `X0_ALWAYS_ZERO`.

### 1.7 — `check_sll_srl`

**Functionality:** checks shift amounts for sll and srl: amount 0 (no-op) and amount 31 (the max single-bit shift in a 32-bit word), and a round trip (shift left then right by the same amount) to verify srl correctly reverses sll.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(31)),
    asm_instr(.op(OP_SLL),  .rd(3), .rs1(1), .rs2(2)),
    asm_instr(.op(OP_SRL),  .rd(4), .rs1(3), .rs2(2)),
    asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(0)),
    asm_instr(.op(OP_SLL),  .rd(6), .rs1(1), .rs2(5)),
    EBREAK_WORD
};
run_directed("check_sll_srl", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x3` | `32'h8000_0000` | `1 << 31` |
| `x4` | `32'h0000_0001` | `0x8000_0000 >> 31`, reverses the shift above |
| `x6` | `32'h0000_0001` | `1 << 0`, shift-by-zero is a no-op |

**Pass criteria:** all three regs should match.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. All three ended up matching. 

### 1.8 — `check_lw_sw`

**Functionality:** Store/load round trip at word 0 and at some high addr. The goal is to reach both ends of the usable data-SRAM range from a prog-computed base.
**Initial state:**

- Registers: reset state
- Data memory: every word this test reads is written by this test first
- Other setup: CPU disabled before load

**Program:**

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(99)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(0)),
    asm_instr(.op(OP_SW),   .rs1(2), .rs2(1), .imm(0)),
    asm_instr(.op(OP_LW),   .rd(3), .rs1(2), .imm(0)),
    asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(2047)),
    asm_instr(.op(OP_ADDI), .rd(4), .rs1(4), .imm(2045)),
    asm_instr(.op(OP_SW),   .rs1(4), .rs2(1), .imm(0)),
    asm_instr(.op(OP_LW),   .rd(5), .rs1(4), .imm(0)),
    EBREAK_WORD
};
run_directed("check_lw_sw", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x3` | `99` | loaded back from word 0 |
| `x4` | `4092` | `2047 + 2045`, the byte base of word 1023 |
| `x5` | `99` | loaded back from word 1023, reached through a computed base |

**Pass criteria:** both loads should return 99.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. Both loads matched, so the computed-address path works and the top of the data-SRAM range is reachable.

### 1.9 — `external_port_window`

**Functionality:** The external port reaches all three mapped windows (instruction SRAM, data SRAM, register file) independently. Writes and reads the first and last word of both SRAMs, then runs a short program so the register window has known, non-zero vals, including a negative value.

**Initial state:**

- Registers: reset state, then established by the program in the second phase
- Memories: `init_memories()` values; every word this test reads is written by this test first
- Other setup: port writes the first and last word of SRAM and reads those 4 words back with the CPU disabled, then runs a program to populate the register window

**Program:**

```systemverilog
drv.reset_task();
seqr.send_write_trans(word_addr(ISRAM_BASE, 0),    32'hC3C3_C3C3);
seqr.send_write_trans(word_addr(ISRAM_BASE, 1023), 32'h3C3C_3C3C);
seqr.send_write_trans(word_addr(DSRAM_BASE, 0),    32'h0000_0000);
seqr.send_write_trans(word_addr(DSRAM_BASE, 1023), 32'hFFFF_FFFF);
seqr.wait_for_empty();
repeat (2) @(cpu_if.cb);

readback(0, 1, 0);
readback(0, 1, 1023);
readback(1, 1, 0);
readback(1, 1, 1023);

drv.reset_task();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(9),  .rs1(0), .imm(3)),
    asm_instr(.op(OP_ADDI), .rd(17), .rs1(0), .imm(123)),
    asm_instr(.op(OP_ADDI), .rd(30), .rs1(0), .imm(-1)),
    EBREAK_WORD
};
run_directed("external_port_window", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `imem[0]` | `32'hC3C3_C3C3` | instruction window, first word |
| `imem[1023]` | `32'h3C3C_3C3C` | instruction window, last word; inverted pattern exposes window corruption|
| `dmem[0]` | `32'h0000_0000` | data window, first word; exposes a stuck-high bit |
| `dmem[1023]` | `32'hFFFF_FFFF` | data window, last word; exposes a stuck-low bit |
| `x9` | `32'h0000_0003` | written by the program, read through the register window |
| `x17` | `32'h0000_007B` | same as above |
| `x30` | `32'hFFFF_FFFF` | `-1` (2's complement), exercises sign handling through the register-window path too |

**Pass criteria:** all four SRAM corners should match what was written, all 32 register-window words should match the reference model w/ no driver timeouts.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. All four SRAM corners and all register-window words matched.

### 1.10 — `reg_window_aliasing`

**Functionality:** The register window's controller decodes on `addr_i[6:2]`. Bits `addr_i[11:7]` should not matter (be Xs): so a read with those bits set should still return the correct register. 

**Initial state:**

- Registers: reset state, then set to a known value by a short program
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
drv.reset_task();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(777)),
    EBREAK_WORD
};
seqr.load_program(prog);
seqr.wait_for_empty();
repeat (2) @(cpu_if.cb);
drv.run_program(2000);

seqr.send_read_trans(word_addr(REG_BASE, 5));
seqr.send_read_trans(word_addr(REG_BASE, 5) | 13'h0080);
seqr.wait_for_empty();
repeat (2) @(cpu_if.cb);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| address for `x5` | `777` | normal read |
| aliased address (`addr[11:7]` nonzero, `addr[6:2]` unchanged) | `777` | same register as upper bits should not affect the decode |

**Pass criteria:** both reads should return 777.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. Both reads matched, the decode logic uses only `addr[6:2]` as the testplan for `c_valid_window` assumes.

### 1.11 — `dsram_full_depth`

**Functionality:** Added  this test for coverage closure- it drives a loop  through every word of data SRAM, 0 through 1023, storing and immediately reading back the address value at each word. Attempts to close toggle coverage on `dsram_addr` and the LW/SW data path across the full addr range.

**Initial state:**

- Registers: reset state
- Data memory: none; this test writes every word it reads
- Other setup: CPU disabled before load; timeout raised to accommodate 1024 loop iterations

**Program:**

```systemverilog
drv.reset_task();
init_memories();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(0)), //addr pointer
    asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(0)),    
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1024)), //loop counter
    asm_instr(.op(OP_SW),   .rs1(3), .rs2(3), .imm(0)), //store val at that addr
    asm_instr(.op(OP_LW),   .rd(4),  .rs1(3), .imm(0)), //read it back
    asm_instr(.op(OP_ADD),  .rd(5),  .rs1(5), .rs2(4)), //inc x5 by x4
    asm_instr(.op(OP_ADDI), .rd(3),  .rs1(3), .imm(4)), //inc addr to next word
    asm_instr(.op(OP_ADDI), .rd(1),  .rs1(1), .imm(-1)), //decrement counter
    asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(0), .imm(8)),  //loop cond
    asm_instr(.op(OP_BEQ),  .rs1(0), .rs2(0), .imm(-24)),  //otherwise loop back

    EBREAK_WORD
};
run_directed("dsram_full_depth", prog, 10000, 4);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x5` | `32'h001F_F800` | sum of every word byte-address `0, 4, 8, ..., 4092`, i.e. `4 * (0+1+2+...+1023)` |

**Pass criteria:** `x5` matches, which means every word 0 to 1023 was correctly stored and read back exactly once.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. `x5 = 32'h001F_F800` as expected. helped close the remaining `dsram_addr` toggle bits that brought `dut` toggle coverage to 98.08%. 

### 1.12 — `check_double_beq`

**Functionality:** Two back-to-back self-comparing branches (`rs1 == rs2` using the same register, so each is always taken regardless of runtime value), each one skipping over a pair of instructions. The point is to exercise the branch-target datapath with two independent taken branches back to back.

**Initial state:**

- Registers: reset state
- Data memory: none
- Other setup: CPU disabled before load

**Program:**

```systemverilog
drv.reset_task();
init_memories();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1)),
    asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(1), .imm(12)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(99)),
    asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(88)),
    asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(1)),
    asm_instr(.op(OP_BEQ),  .rs1(3), .rs2(3), .imm(12)),
    asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(77)),
    asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(66)),
    asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(42)),
    EBREAK_WORD
};
run_directed("check_double_beq", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x1` | `1` | set before the first branch |
| `x2` | `0` | both writes to `x2` are inside the first branch's skip window and never execute |
| `x3` | `1` | set after the first branch, reached normally |
| `x4` | `0` | both writes to `x4` are inside the second branch's skip window and never execute |
| `x5` | `42` | reached after the second branch- shows the branch landed correctly without over/undershooting |

**Pass criteria:** `x2` and `x4`should stay 0; `x1`, `x3`, `x5`  should match.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. Both skip windows were followed exactly, with no data leakage between the two adjacent branches.

### 1.13 — `check_consecutive_sw`

**Functionality:** produces a back-to-back store pattern to check whether `dsram_en_o` correctly pulses for every store, including one that writes only zeroes as data (which could be place for a write-en bug to hide, if zero data is ever mistaken for a no-op write). Three stores to three distinct addresses: zero data, then non-zero data, then zero data again.

**Initial state:**

- Registers: reset state
- Data memory: none; all three words this test writes are checked afterward
- Other setup: CPU disabled before load

**Program:**

```systemverilog
drv.reset_task();
init_memories();
prog = '{
    asm_instr(.op(OP_ADDI), .rd(3),  .rs1(0), .imm(1000)),
    asm_instr(.op(OP_ADDI), .rd(24), .rs1(0), .imm(100)),
    asm_instr(.op(OP_SW),   .rs1(0), .rs2(0), .imm(0)),
    asm_instr(.op(OP_SW),   .rs1(24),.rs2(3), .imm(4)),
    asm_instr(.op(OP_SW),   .rs1(0), .rs2(0), .imm(8)),
    EBREAK_WORD
};
run_directed("check_consecutive_sw", prog);
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `dmem[0]` (address 0) | `32'h0000_0000` | first store: data is `x0` (zero) |
| `dmem[26]` (address 104, `x24 + 4`) | `1000` | second store: non-zero data at a different address |
| `dmem[2]` (address 8) | `32'h0000_0000` | third store: zero data again,diff addr |
| Store count | `3` | all three stores must be observed, including both zero-data ones |

**Pass criteria:** all three words must match, andexactly three stores should logged by the monitor,with none being dropped.

**Final result:** Pass. `evidence/normal_cpu_passed.log`. All three stores observed and matched, including both zero-data stores. `dsram_en_o` is not gated on the data value being non-zero.

## 2. Constrained-random tests

### Instruction constraints

| Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
| --- | --- | --- | --- |
| `c_opcode` | Provided | Keeps the opcode values within the supported ISA | No member change |
| `c_reg_bias` | Provided | The constraint implement weighted distributions to bias the x1-x7 regs, with a significant but lower weighted dist to x0 register during testing | No member change |
| `c_imm_range` | Partial | Keeps the immediate within the two's-complement 12-bit range | Added the both signed bounds, `imm <= 2047` and a dist weighting the corner values `-2048`, `-1`, `0`, `2047` so they are hit with a desirable probability. |
| `c_mem_align` | Open | Keeps load/store addresses word-aligned | Aligning the imm alone is not enough since the effective address is `rs1 + imm`, and `rs1` is randomized, so an aligned immediate on top of an unaligned base is still unaligned, and might land outside data SRAM range. This was implemented against the runtime register snapshot  `((reg_snapshot[rs1] + imm) & 32'h3) == 0` and `(reg_snapshot[rs1] + imm) <= (DSRAM_WORDS * 4) - 4`. which keeps`rs1`'s existing distribution rather than forcing it to a dedicated addr reg. |
| `c_imm_unused` | Provided | Forces `imm == 0` on register-only instructions | No member change |
| `c_branch_target` | Partial | Enforces word alignment and a positive forward-only offset | Added the upper bound, `imm <= (prog_len - idx - 1) * 4`, so every branch target lands at or before the appended EBREAK. |
| `c_no_branch_at_end` | Provided | Avoids branching in the final slot before EBREAK | No member change |
| `c_branch_taken_bias` | Open | Biases `rs1`/`rs2` to compare equal often enough that BEQ is actually exercised | Implemented with a equal dist  `1 :/ 50, 0 :/ 50`; when set, the same register index is used for both `rs1` and `rs2`, which is taken regardless of runtime value. |

### External-port constraints

| Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
| --- | --- | --- | --- |
| `c_align` | Provided | Requests aligned to word-sized addresses | No member change |
| `c_valid_window` | Partial | Keeps the selected window valid (`2'b11` is unmapped) | The register window holds 32 words but is decoded on `addr_i[6:2]` alone, so an address with `addr[11:7] != 0` matches to a real register and doesn't cause an error, so I ddded `(addr[13:12] == 2'b10) -> addr[11:7] == 0` so random register-window reads always name a register the scoreboard can predict as a real comparison, without relying on the addr bits behaving correctly. |
| `c_reg_read_only` | Provided | Reg file is read-only over this port | No member change |
| `c_data_corners` | Open | Weighted distribution on write data to hit edge-case values more often | Implemented as a `dist` over `32'h0000_0000`, `32'hFFFF_FFFF` , and after feedback added both signed extremes, `32'h8000_0000` and `32'h7FFF_FFFF` |

### Random-program test

| Item | Plan |
| --- | --- |
| Number of programs per seed | `NUM_RANDOM_PROGRAMS`, default 20, can be overridden using plusarg |
| Program-length range | 1 to `ISRAM_WORDS - 1` instructions |
| External-port transactions | `NUM_RANDOM_XBAR`, default 300, run while the CPU is disabled |
| Information logged for reproduction | Numeric `SVSEED`, iteration, and complete generated program |



**Implementation outline:**

```systemverilog
for (int i = 0; i < NUM_RANDOM_PROGRAMS; i++) begin
    automatic string test_name = $sformatf("random_%0d", i);
    automatic int num_instrs = $urandom_range(ISRAM_WORDS - 1, 1);
    automatic int num_xbar   = $urandom_range(NUM_RANDOM_XBAR, 0);

    sb.set_test(test_name);
    drv.reset_task();
    init_memories();

    seqr.gen_program(num_instrs, 1'b1);
    seqr.wait_for_empty();
    repeat (num_instrs + 10) @(cpu_if.cb);
    drv.run_program(2000);

    if (drv.last_run_completed) begin
        repeat (5) @(cpu_if.cb);
        readback(2, REG_COUNT);
        readback(1, DSRAM_WORDS);
    end else begin
        drv.reset_task();
    end

    if (num_xbar > 0) begin
        seqr.gen_xbar(num_xbar, 1'b1);
        seqr.wait_for_empty();
    end
end
```

## 3. Assertions

### Assertion summary

| Assertion ID/name | Behavior checked | When it is sampled/disabled | Activating test |
| --- | --- | --- | --- |
| 3.1 / `NO_SIMULTANEOUS_READ_WRITE` | `w_en_i` and `r_en_i` are never asserted together | `posedge clk`, disabled during reset | forced violation  |
| 3.2 / `X0_ALWAYS_ZERO` | `x0` as reflected in the register crossbar is always 0 | `posedge clk` | 1.6 |
| 3.3 / `CPU_HALT_PULSE_CHECK` | `cpu_halted_o` never rises while the CPU is inactive | `posedge clk`, disabled during reset | 1.2 |

NOTE: after the leads feedback i removed `ADDI_SUM_MATCH` ,as it was redundant with the scoreboard, which already catches arithmetic errors during normal testing. I replaced it with `CPU_HALT_PULSE_CHECK`

### 3.1 — `NO_SIMULTANEOUS_READ_WRITE`

**Timing requirement in words:** on every cycle except reset, `w_en_i` and `r_en_i` must not be asserted together.

```systemverilog
NO_SIMULTANEOUS_READ_WRITE:
    assert property (@(posedge clk) disable iff (rst)
        !(cpu_if.w_en && cpu_if.r_en))
    else assertion_fail("w_en_i and r_en_i were asserted together");
```

**Evidence that it detects a violation:** forced `cpu_if.w_en` and `cpu_if.r_en` high together for one cycle via `force`/`release`, then released and recovered with `drv.reset_task()` after that. The assertion fired on the forced cycle and I captured it in `evidence/assert_simul_read_and_write.log`. 

### 3.2 — `X0_ALWAYS_ZERO`

**Timing requirement in words:** the `x0` value reflected in the register crossbar must be 0 on every cycle.

```systemverilog
X0_ALWAYS_ZERO:
    assert property (@(posedge clk)
        dut.cpu.reg_crossbar_o[0] == '0)
    else assertion_fail("x0 value malfunction");
```

**Evidence that it detects a violation:** forced `dut.cpu.reg_crossbar_o[0]` to `32'hDEADBEEF`(just because i found it funny that i could do that with hex numbers) for two clock cycles via `force`/`release`, then released it. The assertion fired on both forced cycles, at 125005 ns and 125015 and captured it in `evidence/assert_x0_always_zero.log`.

### 3.3 — `CPU_HALT_PULSE_CHECK`

**Timing requirement in words:** on any clock edge where `cpu_halted_o` rises, the CPU must have been active. Expected behavior is for `halted_o` to be held once EBREAK commits.
```systemverilog
CPU_HALT_PULSE_CHECK:
    assert property (@(posedge clk) disable iff (rst)
        $rose(cpu_if.cpu_halted) |-> cpu_if.cpu_active)
    else assertion_fail("cpu_halted_o rose when CPU was not active");
```
**Evidence that it detects a violation:** The assertion fired 31 times, after which I reverted the fix back and reran, and all tests passed. I captured it in `evidence/assert_halt_pulse_check.log`.

## 4. Encrypted CPU Bug Hunt

My assigned variant was: `bug_hunt_cpu_1`. The three failures come from an earlier `make bug_hunt` that i ran at `SVSEED=-1470738337`, saved as `evidence/org_bug_hunt.log`. Bug 3 also has a second case from a run at `SVSEED=1`, saved as `evidence/org_seed1_bug_hunt.log`. Both runs were made while my tb_top wasnt yet finalized (i had removed test 1.2 in the middle). Putting 1.2 back ahead of the random tests shifts the random stream (because 1.2 is part of the directed tests, which come before the random tests), so the same seeds now generate different programs, and `evidence/seed_bug_hunt.log` is the rerun at `SVSEED=-1470738337`. After review I rebuilt each minimized reproducer from its failing program in those logs, keeping the registers and immediates, so the reproducers don't depend on the seed. They run through `run_reproduce_bugs_tests()` with `make bug_hunt SIM_PLUSARGS="+REPRODUCE_BUGS"`, and on the member CPU as a control with `make xrun SIM_PLUSARGS="+REPRODUCE_BUGS"`. The encrypted-CPU run is `evidence/reproduced_bugs.log`, and the member-CPU run, `evidence/reproduce_member_cpu.log`, passed with 0 scoreboard mismatches.

### Bug 1 — shift amount taken from `rs2[5:0]` instead of `rs2[4:0]`

#### Random discovery

| Field | Evidence |
| --- | --- |
| Discovery command | `make bug_hunt SEED=random` |
| Numeric `SVSEED` | `-1470738337` |
| Failing iteration | `random_3` |
| First failure message | `709655 SB: [random_3] read of register x7 returned 0x00000000, expected 0x19a9942f` |
| Reproduction command | `make bug_hunt SIM_PLUSARGS="+REPRODUCE_BUGS"`, test `mr_srl_random3`. The seed no longer regenerates `random_3` (see above) |
| Reproduces consistently? | Yes for the reproducer: `mr_srl_random3` fails the same way, `x7 = 0` at 84525 ns in `evidence/reproduced_bugs.log` |

**Original failing program:** excerpt from `random_3`, from the `Seq:` instruction trace. The full sequence is in `evidence/org_bug_hunt.log` and the offending instruction is `[254]`.

```systemverilog
// ... start
[249] add x10, x18, x2
[250] lw  x3, 700(x7)
[251] srl x5, x13, x0
[252] add x5, x7, x2
[253] beq x3, x6, 8
[254] srl x7, x1, x2 //x1 = 0xcd4ca17e, x2 = 0xd2e92663 -> offending instruction
[255] add x1, x2, x6
[256] addi x5, x1, 1706
// rest of random_3 ...
```

The instructions that produce `x1` and `x2` for `[254]`, from the `Ref:` trace of the same run:

```systemverilog
[13]  lw   x1, 496(x12)   // dmem[0x7c] = 0xd2e92947, x12 = 0
[18]  srl  x2, x1, x6     // x6 = 0, x2 = 0xd2e92947
[20]  addi x2, x2, -740   // x2 = 0xd2e92663
[28]  lw   x1, 1224(x8)   // dmem[0x132] = 0xcd4c9d4d, x8 = 0
[246] addi x3, x1, 1073   // x3 = 0xcd4ca17e
[248] srl  x1, x3, x15    // x15 = 0, x1 = 0xcd4ca17e
```

**Root cause in the random program:** `srl x7, x1, x2` at instruction `[254]`, pc `0x3f8`. `x2 = 0xd2e92663`, bit 5 set, low 5 bits = 3. Model: `x1 (0xcd4ca17e) >> 3 = 0x19a9942f`. DUT returned 0, which is what a shift by `0xd2e92663 & 63 = 35` gives. `x7` is the only register that failed in `random_3`, and `[254]` is the last write to it.

#### Expected vs. actual

| Instruction / event | Expected | Actual (encrypted CPU) | Cycle/time |
| --- | --- | --- | --- |
| `random_3` `[254]`: `srl x7, x1, x2`, `x1 = 0xcd4ca17e`, `x2 = 0xd2e92663` | `0x19a9942f` | `0x00000000` | 709655 ns, `evidence/org_bug_hunt.log` |
| `mr_srl_random3`: the same SRL after the six instructions above | `x7 = 0x19a9942f` | `x7 = 0x00000000` | 84525 ns, `evidence/reproduced_bugs.log` |
| `test_bit5_clear`: same program, `x2 = 0xd2e92643` (bit 5 clear, low 5 bits still 3) | `x7 = 0x19a9942f` | `x7 = 0x19a9942f`, matches | 85865 ns, `evidence/reproduced_bugs.log` |
| `test_shift_mask`: `sll x3, x1, x2`, `x1 = 1`, `x2 = 32` | `0x00000001` (`32 & 31 == 0`) | `0x00000000` | 86935 ns, `evidence/reproduced_bugs.log` |
| `test_shift_5th_bit`: `sll x22, x20, x21`, `x20 = 1`, `x21 = 64` | `0x00000001` | `0x00000001`, passes | 88465 ns, `evidence/reproduced_bugs.log` |

**First architectural divergence:** `x7` after `[254]` in `random_3`, read back as `0x00000000` at 709655 ns where the ref model expected `0x19a9942f`. The earlier directed tests narrow down how the amount is formed. A correct 5-bit mask (`rs2[4:0]`) reduces shift amount 32 to 0, a no-op, so `x3` in `test_shift_mask` should stay `x1 = 1`. The encrypted CPU gives 0 instead, consistent with the amount being taken as `rs2[5:0]` instead of `rs2[4:0]`: `32 & 63 = 32` shifts the value out entirely, while `64 & 63 = 0` is a no-op, which is why `test_shift_5th_bit` passes. A correct 5-bit mask would pass on 32 and a full 32-bit amount would clear on 64, so only the 6-bit amount makes sense from both results.

#### Minimization

**Minimized reproducer** (the minimum failing program, `mr_srl_random3`)**:** I kept the seven instructions above that feed `[254]`, copied with their registers and immediates, and dropped everything else in `random_3`. The base registers they read (`x6`, `x8`, `x12`, `x15`) are 0 at those points in the log and 0 after reset here, and the two words the loads read are preloaded with the logged values.

```systemverilog
task automatic mr_srl_random3();
    logic [31:0] p [$];
    logic [31:0] d [$];
    d = '{32'hD2E92947};
    preload_dmem(d, 'h7C);                                       // word read by [13]
    d = '{32'hCD4C9D4D};
    preload_dmem(d, 'h132);                                      // word read by [28]
    p = '{
        asm_instr(.op(OP_LW),   .rd(1), .rs1(12), .imm(496)),   // [13]  x1 = 0xD2E92947 (word 0x7C)
        asm_instr(.op(OP_SRL),  .rd(2), .rs1(1),  .rs2(6)),     // [18]  x2 = x1 >> 0 = 0xD2E92947
        asm_instr(.op(OP_ADDI), .rd(2), .rs1(2),  .imm(-740)),  // [20]  x2 = 0xD2E92663, x2[5:0] = 35
        asm_instr(.op(OP_LW),   .rd(1), .rs1(8),  .imm(1224)),  // [28]  x1 = 0xCD4C9D4D (word 0x132)
        asm_instr(.op(OP_ADDI), .rd(3), .rs1(1),  .imm(1073)),  // [246] x3 = 0xCD4CA17E
        asm_instr(.op(OP_SRL),  .rd(1), .rs1(3),  .rs2(15)),    // [248] x1 = x3 >> 0 = 0xCD4CA17E
        asm_instr(.op(OP_SRL),  .rd(7), .rs1(1),  .rs2(2)),     // [254] failing shift: expect x7 = 0x19A9942F
        EBREAK_WORD
    };
    run_directed("mr_srl_random3", p, 2000, 8);
endtask
```

**Experiments to separate the trigger from nearby possibilities:** `test_shift_mask` fails on the encrypted CPU and the other two pass. All three pass on the member CPU (`evidence/reproduce_member_cpu.log`).

| Experiment | Result (encrypted CPU) | What it shows |
| --- | --- | --- |
| `test_bit5_clear`: the `mr_srl_random3` program with the `[20]` immediate changed from `-740` to `-772`, so bit 5 of `x2` is clear and its low 5 bits are still 3 | pass, `x7 = 0x19a9942f` | with bit 5 clear, the same shift is correct |
| `test_shift_mask` (original directed test): `sll` of 1 by 32 | fail, `x3 = 0` where 1 is expected | SLL fails too, and an amount of exactly 32 clears the result |
| `test_shift_5th_bit` (original directed test): `sll` of 1 by 64 | pass, `x22 = 1` | bit 6 of `rs2` has no effect, so the shift amount is clearl not dependent on the whole register |

#### Waveform evidence

`screenshots/BUG1_waveform.png` shows `mr_srl_random3` from 84,320 to 84,545 ns. At cursor TimeB (84,335 ns) `core_isram_rdata` holds `0x0020D3B3`, the encoding of `srl x7, x1, x2`. `core_isram_addr` already reads `0x007` there because the instruction SRAM returns each word one cycle after its address. After the halt the testbench reads the registers back over `addr_i`: `x1` at `0x2004` returns `0xCD4CA17E` and `x2` at `0x2008` returns `0xD2E92663`. At the other cursor in the screenshot, TimeA (84,520 ns),  `addr_i = 0x201C`, the address of `x7`, and `rdata_o = 0x00000000`, where the model expects `0x19A9942F`. The scoreboard flags this readback at 84525 ns in `evidence/reproduced_bugs.log`.

#### Conclusion

**Trigger:** an sll or srl whose `rs2` has bit 5 set (35 in `random_3`, 32 in `test_shift_mask`).

**Expected behavior:** the shift amount is `rs2[4:0]`; amounts at or above 32 reduce mod32, so 32 behaves as 0.

**Observed behavior:** on the encrypted CPU, sll and srl return 0 whenever bit 5 of `rs2` is set, although only `rs2[4:0]` should count.

**Behavioral characterization:** sll and srl take the shift amount from `rs2[5:0]`, where the ISA uses `rs2[4:0]`, so any amount with bit 5 set clears the result (this data cannot distinguish that from forcing the result to zero whenever `rs2[5]` is set).

### Bug 2 — BEQ directly after an LW compares against the LW destination's old value

#### Random discovery

| Field | Evidence |
| --- | --- |
| Discovery command | `make bug_hunt SEED=random` |
| Numeric `SVSEED` | `-1470738337` |
| Failing iteration | `random_8` |
| First failure message | `1162755 SB: [random_8] CPU store dmem[e9] <- a91800bf, expected dmem[133] <- 0` |
| Reproduction command | `make bug_hunt SIM_PLUSARGS="+REPRODUCE_BUGS"`, test `mr_lw_beq_random8`. The seed no longer regenerates `random_8` (see the section intro) |
| Reproduces consistently? | Yes for the reproducer: `mr_lw_beq_random8` takes the branch, `x1 = 0x92ed1f2d` at 89225 ns in `evidence/reproduced_bugs.log`. |

**Original failing program:** excerpt from `random_8`, from the `Seq:` instruction trace. The full sequence is in `evidence/org_bug_hunt.log`; the offending instruction is `[18]`.

```systemverilog
// start of prog ...
[14] srl x29, x1, x25
[15] sw  x14, 444(x7)
[16] lw  x27, 268(x0)
[17] lw  x1, 1992(x0)  //loads x1 <= 0x92ed1f2d
[18] beq x1, x30, 1032 // x30 = 0, stale x1 = 0 , incorrectly taken
[19] sll x1, x7, x9
// the rest of random_8 ...
```

**Root cause in the random program:** `lw x1, 1992(x0)` loads `x1 <= 0x92ed1f2d`, immediately followed by `beq x1, x30, 1032`. `x30` and the pre-load `x1` were both 0, so a stale read makes `x1 == x30` and wrongly takes the branch and the loaded value doesn't match, so it should fall through. Everything after this point in `random_8` runs from the wrong branch target, so the later stores go to the wrong addresses.

#### Expected vs. actual

| Instruction / event | Expected | Actual (encrypted CPU) | Cycle/time |
| --- | --- | --- | --- |
| `random_8` `[18]`: `beq x1, x30` right after `lw x1` loads `0x92ed1f2d`; `x30 = 0`, old `x1 = 0` | not taken; next CPU store is `dmem[133] <- 0` | taken; next CPU store is `dmem[e9] <- a91800bf` | 1162755 ns, `evidence/org_bug_hunt.log` |
| `mr_lw_beq_random8`: `[17]` to `[19]` with the branch offset scaled to 8 | not taken; `x1 = 0` after `[19]` | taken; `x1 = 0x92ed1f2d` | 89225 ns, `evidence/reproduced_bugs.log` |
| `test_lw_nop_beq`: same with one nop between the lw and the beq | not taken; `x1 = 0` | `x1 = 0`, matches | 91665 ns, `evidence/reproduced_bugs.log` |
| `test_lw_beq_stale`: old `x1 = 1`, loaded `x1 = 0`, `x30 = 0` | taken; `x8 = 0` | not taken; `x8 = 0x000007ff` | 90585 ns, `evidence/reproduced_bugs.log` |
| `test_beq_after_lw`: `beq x1, x4, +8`, `x1 = 0`, `x4` just loaded as 7 | not taken (`0 != 7`); `x8` reached and set to `0x000007ff` | `0x00000000` branch taken on the stale pre-load value of `x4`, `x8` skipped | 94205 ns, `evidence/reproduced_bugs.log` |
| same test: final value of `x4`, the lw's destination | `0x00000007` | `0x00000007`, matches | 94125 ns, `evidence/reproduced_bugs.log` |
| `test_beq_after_addi`: `addi x4, x0, 7` then `beq x1, x4, +8`, `x1 = 0` | not taken; `x8 = 0x000007ff` | `x8 = 0x000007ff`, matches | 92955 ns, `evidence/reproduced_bugs.log` |

**First architectural divergence:** control flow at `[18]` in `random_8`. The branch should fall through to `[19]` and the encrypted CPU goes to the branch target instead. The first visible result is the sw at 1162755 ns. The reproducer run supports reading this as a stale comparison and not a lost lw: in `test_beq_after_lw`, `x8` is skipped, yet `x4` (the LW's destination) reads back `0x00000007` at 94125 ns, so the lw's writeback completed and only the beq instr saw the old value.

#### Minimization

**Minimized reproducer** (the minimum failing program, `mr_lw_beq_random8`)**:** `[17]` to `[19]` of `random_8`, with the same registers. I dropped `[0]` to `[16]`; `x1`, `x7`, `x9` and `x30` are 0 at `[17]` in the log and 0 after reset here. `dmem[0x1f2]` is preloaded with the logged `0x92ed1f2d`. The one change is the branch offset, 8 instead of 1032, so the taken path stays inside the program: taking the branch skips `[19]` and leaves `x1 = 0x92ed1f2d`, while the correct fall-through runs `[19]` and sets `x1 = 0`.

```systemverilog
task automatic mr_lw_beq_random8();
    logic [31:0] p [$];
    logic [31:0] d [$];
    d = '{32'h92ED1F2D};
    preload_dmem(d, 'h1F2);                                      // word read by [17]
    p = '{
        asm_instr(.op(OP_LW),   .rd(1), .rs1(0),  .imm(1992)),  // [17] x1 = 0x92ED1F2D, old x1 = 0
        asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(30), .imm(8)),    // [18] 0x92ED1F2D != x30 = 0: must NOT be taken
        asm_instr(.op(OP_SLL),  .rd(1), .rs1(7),  .rs2(9)),     // [19] x1 = 0 << 0 = 0; skipped if taken
        EBREAK_WORD
    };
    run_directed("mr_lw_beq_random8", p, 2000, 8);
endtask
```

**Experiments to separate the trigger from nearby possibilities:** `test_lw_beq_stale` and `test_beq_after_lw` fail on the encrypted CPU and the other two pass (All four pass on the member CPU).

| Experiment | Result (encrypted CPU) | What it shows |
| --- | --- | --- |
| `test_lw_beq_stale`: `x1 = 1` before the lw, the lw loads 0 and `x30 = 0`, so the branch should be taken and skip `addi x8, x0, 2047` | fail, `x8 = 0x7ff` where 0 is expected | the branch follows the old `x1`, so a beq after a lw is not simply always taken |
| `test_lw_nop_beq`: the minimum program with one nop between the lw and the beq instr | pass, `x1 = 0` | the wrong branch only happens when the beq instr directly follows the lw instr|
| `test_beq_after_addi`: an addi instead of a lw writes `x4` right before `beq x1, x4` | pass, `x8 = 0x7ff` | an addi right before the beq instr does not cause it, so it is specific to the lw |
| `test_beq_after_lw` : sw of 7 to a word, lw of the same word into `x4`, and then `beq x1, x4`; same word, so Bug 3 does not apply | fail, `x8 = 0` where `0x7ff` is expected; `x4 = 7` | the loaded value still reaches `x4`, and only the branch goes wrong |

#### Waveform evidence

`screenshots/BUG2_waveform.png` shows `mr_lw_beq_random8` from 89,140 to 89,235 ns. The load is on the data bus until 89,155 ns (`dsram_en = 1`, `dsram_addr = 0x1F2`), and `dsram_rdata` holds the loaded `0x92ED1F2D`, which the monitor reports at 89165 ns. `core_isram_addr` goes from `0x000` to `0x001` and then straight to `0x003`. It never reads `0x002`, so the `sll` at word 2 is not fetched. At cursor: TimeA (89,160 ns) `core_isram_rdata` holds `0x01E08463`, the `beq x1, x30, 8`, with `core_isram_addr` already at `0x003`, while `dsram_rdata` still shows `0x92ED1F2D`. The next word fetched is `0x00100073`, the EBREAK at word 3. At the other cursor I added, TimeC (89,222 ns) `addr_i = 0x2004`, the address of `x1`, and `rdata_o = 0x92ED1F2D`. A correct CPU falls through, runs the `sll` and reads back 0, as the member CPU does at 89235 ns in `evidence/reproduce_member_cpu.log`. The encrypted CPU's readback is flagged at 89225 ns in `evidence/reproduced_bugs.log`, giving evidence od the bug. 

#### Conclusion

**Trigger:** a beq whose comparison operand was written by the immediately preceding LW.

**Expected behavior:** by the time beq reads its source registers, it should read the value the preceding lw loaded

**Observed behavior:** the encrypted CPU's beq instr branches as if the register still held its value from before the lw. In `random_8` the beq comes directly after the lw. With one nop in between, the branch is correct (`test_lw_nop_beq`), so the stale value only reaches the very next instr.

**Behavioral characterization:** a beq immediately following a lw that writes one of its operands uses that operand's pre-load value for the comparison (only lw's cause it: in `test_beq_after_addi` an ADDI writes the operand right before the BEQ, and the branch comes out to be correctly not taken).

### Bug 3 — LW directly after an SW returns the SW's data when the word addresses share bits [3:0]

#### Random discovery

| Field | Evidence |
| --- | --- |
| Discovery command | `make bug_hunt SEED=random` |
| Numeric `SVSEED` | `-1470738337` |
| Failing iteration | `random_0` |
| First failure message | `442225 SB: [random_0] CPU store dmem[1b3] <- 0, expected dmem[1b3] <- b99891d9` |
| Reproduction command | `make bug_hunt SIM_PLUSARGS="+REPRODUCE_BUGS"`, tests `mr_sw_lw_random0` and `test_4bits_match`.  |
| Reproduces consistently? | Yes for the reproducers: `mr_sw_lw_random0` stores 0 to `dmem[1b3]` at 95985 ns, and `test_4bits_match` reads `x1 = 0x832b50c7` at 97315 ns, both in `evidence/reproduced_bugs.log` |

**Original failing program:** Taken from `random_0`, from the sequencer (`Seq:`) instruction trace. The full sequence is in `evidence/org_bug_hunt.log`; the offending instruction is `[110]`.

```systemverilog
// ... [0] through [107] ...
[17]  addi x6, x3, -374   // x6 = 0xfffffe8a, so [110] reads word 0x46
// ...
[108] add x3, x0, x0
[109] sw  x29, 856(x23)   // x29 = 0 stored to word 0xd6
[110] lw  x2, 654(x6)     // word 0x46 holds 0xb99891d9; x2 ends up 0
[111] sub x7, x14, x4
[112] sw  x2, 1740(x3)    // stores 0 to word 0x1b3
// ... remainder of random_0 ...
```

Second case, from `random_9` at `SVSEED=1` (`evidence/org_seed1_bug_hunt.log`):

```systemverilog
[713] lw  x5, 584(x21)    // x5 = 0x832b50c7
// ...
[749] sw  x5, 532(x1)     // 0x832b50c7 stored to word 0x85
[750] lw  x1, 1044(x7)    // word 0x105 holds 0x1cc26a38; x1 ends up 0x832b50c7
// ...
[753] sll x3, x1, x7      // x7 = 0, so x3 = x1
```

**Root cause in the random program:** instruction `[109]`, `sw x29, 856(x23)`, immediately followed by `[110]`, `lw x2, 654(x6)`. The load itself is fine (the monitor logs `CPU load dmem[46] -> b99891d9` at 442215 ns), but `x2` does not get that value. Two instructions later, `[112]` stores `x2` as 0, and `[115] sll x2, x12, x2` leaves `x2 = x12 = 0xc85f35cc`, which is a shift by 0. In this case 0 is both the old `x2` and the stored `x29`, so the log can't tell us which one `x2` received.

`random_9` at `SVSEED=1` helped me figure that out. `[749]` stores `0x832b50c7` to word `0x85`, and `[750]` reads word `0x105` (the monitor logs `CPU load dmem[105] -> 1cc26a38` at 1305895 ns). `x1` was 0 before the load, but `x3 = x1` reads back `0x832b50c7` at 1306165 ns, which is the sw's data.

Both failing pairs are on different words that match from bits [3:0]: `0xd6`/`0x46` (both end in 6) and `0x85`/`0x105` (both end in 5). SW-then-LW pairs on words that differ in those bits load correctly. At `SVSEED=1`, `random_13` has `sw x0, 784(x7)` then `lw x1, 816(x0)` (words `0xc4` and `0xcc`, differing only in bit 3) and `random_11` has `sw x21, 1052(x0)` then `lw x6, 764(x10)` (words `0x107` and `0xbf`)- both tests pass. So a store that differs from the load in bit 3 leaves the load correct, while the two failing pairs differ in bits 4, 7 and 8 and still fail. Since the logs only tell us about some addr bits, I implemented some tests to figure out how the rest of the bits play a role in causing the bug.

#### Expected vs. actual

| Instruction / event | Expected | Actual (encrypted CPU) | Cycle/time |
| --- | --- | --- | --- |
| `random_0` `[110]` `lw x2` from word `0x46` right after `[109]` stores 0 to word `0xd6`; `[112]` stores `x2` to word `0x1b3` | `dmem[1b3] <- b99891d9` | `dmem[1b3] <- 0` | 442225 ns, `evidence/org_bug_hunt.log` |
| `random_9` (`SVSEED=1`) `[750]` `lw x1` from word `0x105` right after `[749]` stores `0x832b50c7` to word `0x85`; `x3 = x1` | `x3 = 0x1cc26a38` | `x3 = 0x832b50c7` | 1306165 ns, `evidence/org_seed1_bug_hunt.log` |
| `test_beq_after_lw`: `lw x4, 0(x5)` immediately after `sw x9, 0(x5)`, same word | `0x00000007` | `0x00000007`, matches | 94125 ns, `evidence/reproduced_bugs.log` |
| `mr_sw_lw_random0`: `[17]`, `[109]` to `[112]` | `x2 = 0xb99891d9`, `dmem[1b3] <- b99891d9` | `dmem[1b3] <- 0`, `x2 = 0` | 95985 ns and 96075 ns, `evidence/reproduced_bugs.log` |
| `test_sw_lw_nop`: one nop between `[109]` and `[110]` | same | `x2 = 0xb99891d9`, matches | 98635 ns, `evidence/reproduced_bugs.log` |
| `test_sw_lw_addr_bits`: ten `[109]`/`[110]` pairs, store word `0x46` with bit 0 to 9 flipped, loads into `x10` to `x19` | `x10` to `x19` = `0xb99891d9` | `x10` to `x13` match; `x14` to `x19` = 0 | 100715 to 100895 ns, `evidence/reproduced_bugs.log` |
| `test_4bits_match`: `[713]`, `[749]`, `[750]`, `[753]` | `x1 = x3 = 0x1cc26a38` | `x1 = x3 = 0x832b50c7` | 97315 ns and 97355 ns, `evidence/reproduced_bugs.log` |

**First architectural divergence:** `x2` after `[110]` in `random_0`. It is first visible when `[112]` stores it, `CPU store dmem[1b3] <- 0` at 442225 ns where `b99891d9` was expected.

#### Minimization

**Minimized reproducer** (the minimum failing program, `mr_sw_lw_random0`)**:** I kept `[109]` to `[112]` of `random_0` and `[17]`, which sets the load's base register `x6`, with the logged registers and immediates. `x3`, `x23` and `x29` are 0 at those points in the log and 0 after reset here, and word `0x46` is preloaded with the logged `0xb99891d9`. `x4` is not 0 at `[111]` in the log, so `x7` ends with a different value here and nothing reads it later.

```systemverilog
task automatic mr_sw_lw_random0();
    logic [31:0] p [$];
    logic [31:0] d [$];
    d = '{32'hB99891D9};
    preload_dmem(d, 'h46);                                       // word read by [110]
    p = '{
        asm_instr(.op(OP_ADDI), .rd(6), .rs1(3),  .imm(-374)),  // [17]  x6 = 0xFFFFFE8A, base for [110]
        asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(856)), // [109] store x29 = 0 to word 0xD6
        asm_instr(.op(OP_LW),   .rd(2), .rs1(6),  .imm(654)),   // [110] load word 0x46: expect x2 = 0xB99891D9
        asm_instr(.op(OP_SUB),  .rd(7), .rs1(14), .rs2(4)),     // [111] unrelated, kept from the log
        asm_instr(.op(OP_SW),   .rs1(3), .rs2(2),  .imm(1740)), // [112] store x2 to word 0x1B3
        EBREAK_WORD
    };
    run_directed("mr_sw_lw_random0", p, 2000, 8);
endtask
```

**Experiments to separate the trigger from nearby possibilities:** `test_4bits_match` and `test_sw_lw_addr_bits` fail on the encrypted CPU and `test_sw_lw_nop` passes (All three pass on the member CPU).

| Experiment | Result (encrypted CPU) | What it shows |
| --- | --- | --- |
| `test_4bits_match`: taken from `random_9` at `SVSEED=1` (below); the stored `0x832b50c7` differs from the loaded word and from the old `x1` | fail, `x1 = x3 = 0x832b50c7` where `0x1cc26a38` is expected | the lw's register gets the sw's data|
| `test_sw_lw_nop`: the minimum program with one nop between the sw and the lw | pass, `x2 = 0xb99891d9` | the lw has to come directly after the sw |
| `test_sw_lw_addr_bits`: ten sw/lw pairs built from `[109]` and `[110]`; pair `b` stores 0 to word `0x46` with only bit `b` flipped, then loads word `0x46` into `x(10+b)` | fail on 6 of 10: `x10` to `x13` correct, `x14` to `x19` = 0 | loads were wrong only when the store address matched the load address in bits [3:0] |

**`test_4bits_match`:** keeps `[713]`, `[749]`, `[750]` and `[753]` of `random_9` at `SVSEED=1`, with words `0x92` and `0x105` preloaded. Its store data differs from both the loaded word and the old `x1`, so `x1 = 0x832b50c7` would mean `x1` received the store's data and `x1 = 0` would mean the load never wrote `x1`.

How I difffrentiated the bug- `random_0` and `random_9` come from different seeds and share only the SW-then-LW pair on words with matching bits [3:0]. In neither case is the lw followed by a beq instr, which rules out Bug 2, and neither pair involves an sll or srl, which rules out Bug 1.

#### Waveform evidence

`screenshots/BUG3_waveform.png` shows `mr_sw_lw_random0` from 95,925 to 96,090 ns. At cursor TimeC (95,930 ns) the first store is on the data bus: `dsram_en = 1`, `dsram_write_en = 1`, `dsram_addr = 0x0D6`, `dsram_wdata = 0x00000000`. From 95,945 to 95,965 ns `core_isram_rdata` holds `0x28E32103`, the `lw x2, 654(x6)`, and the load goes out with `dsram_en = 1`, `dsram_write_en = 0` and `dsram_addr = 0x046`. From about 95,955 ns `dsram_rdata` holds `0xB99891D9`, the preloaded word. During a write the data SRAM model copies the value being written to its output, so the `0x00000000` stretches on `dsram_rdata` before and after that come from the two stores. At the other cursor, TimeD (95,980 ns), the next store is on the bus with `dsram_addr = 0x1B3` and `dsram_wdata = 0x00000000`, while `dsram_rdata` still reads `0xB99891D9`. The ref model expects `0xB99891D9` to be stored. Near the right edge, `x2` at `addr_i = 0x2008` reads back as `rdata_o = 0x00000000`. In `evidence/reproduced_bugs.log` the first store is at 95935 ns, the load returning `b99891d9` at 95975 ns, the store of 0 to `dmem[1b3]` at 95985 ns and the `x2` readback at 96075 ns.

#### Conclusion

**Trigger:** an lw directly after an sw, where the two word addresses differ but share bits [3:0] (store to `0xd6` then load from `0x46` in `random_0` : last hex digit is common).

**Expected behavior:** the lw should load and write back the value at its computed address regardless of what instr preceded it.

**Observed behavior:** the lw reads the correct word on the data SRAM port, but its destination register gets the preceding sw's data instead (`0x832b50c7` in `random_9`, in `random_0` that data is 0).

**Behavioral characterization:** a lw that directly follows an sw to a different word whose address matches in bits [3:0] writes the sw's data into its destination instead of the loaded word.