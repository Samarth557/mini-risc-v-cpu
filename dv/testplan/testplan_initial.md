# Fall 2026 DV Onboarding Test Plan

<!--
Make two copies of this template:
  1. testplan_initial.md, submitted before implementing tests.
  2. testplan_final.md, updated after implementation and coverage closure.

Keep the initial copy unchanged after review. HTML comments are editing
instructions and disappear from rendered Markdown.
-->
## NOTE: THIS IS A TEMPLATE FOR YOU TO FOLLOW. THIS IS **NOT** A COMPREHENSIVE TESTPLAN. YOU NEED TO EXTEND IT.
## Document information

| Field | Value |
| --- | --- |
| Verification engineer | Samarth Gupta |
| Plan revision | Initial |
| Date | 2026-09-23 |

### Revision history

| Revision | Date | Changes |
| --- | --- | --- |
| Initial | 2026-09-24 | Initial planned tests |
| Final | YYYY-MM-DD | <!-- Tests or constraints added after debugging and coverage review --> |

## 1. Functional tests

<!--
Plan tests for the CPU functionality supported by this onboarding. Organize
related behavior together. Include both individual instruction behavior and
multi-instruction sequences where ordering or dependencies matter.

Add as many rows and detailed test records as needed. Do not put every CPU
operation into one large program: each failure should identify a reasonably
small area to debug.
-->

### Functional-test summary

| Test ID | Test name | Functionality being tested | Expected result | Status |
| --- | --- | --- | --- | --- |
| 1.1 | `window_instr_sram` | Testing the Instruction SRAM window has the expected address, does not go out of 1024 word range | First and last written word of a particular window match the read value | Planned |
| 1.2 | `check_cpu_pulse` | Verifies that cpu_halted_o is a one cycle pulse, rather than a persistent status bit | Should be sampled every cycle, using effective stimulus should reflect changes from cycle to cycle (for eg. high for 1 cycle, then low) | Planned |
| 1.3 | `try_regfile_write` | tries to write to reg file (read only) | value in reg file should be unchanged | Planned |
| 1.4 | `read_and_write_en` | Verifies that read_en and write_en can never be asserted at the same time | Should either let you read or write | Planned |
| 1.5 | `addi_neg_imm` | Tries to add a negative immediate value using the addi instr | should subtract negative val from reg val | Planned |
| 1.6 | `check_beq_func` | Makes sure beq does not branch when rs1 is not equal to rs2| Should not branch| Planned |
| 1.7 | `honor_x0` | Tries to store a non-zero value in x0 |x0 should retain 0 val | Planned |

### Functional-test details

<!-- Duplicate this complete record for every functional test. -->

### 1.1 — `window_instr_sram`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Verifies that the SRAM Instruction window has been correctly decoded from the External address addr_i[13:12] (should be equal to 2'b00). The first word (base) 0x0000 and the last word ( there are 1024 words, calculated using base +n*4) 0x0FFC, makes sure that the decoding logic used for addr_i does not leak into another window.

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> In the reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> For the duration of this test, CPU will be disabled (en_cpu_i will never be pulsed)

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

```systemverilog
drv.reset_task();
seqr.send_write_trans(word_addr(ISRAM_BASE, 0),    32'some val);
seqr.send_write_trans(word_addr(ISRAM_BASE, 1023), 32'some val);
seqr.send_read_trans(word_addr(ISRAM_BASE, 0));
seqr.send_read_trans(word_addr(ISRAM_BASE, 1023));
seqr.wait_for_empty();

```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `addr_i = 14'h0` | `whatever val was written to it previously by the write task` | writes word to one edge of the range, then reads it to check if it is matching  |
| `addr_i = 14'h0FFC`| `whatever val was written to it previously by the write task (different from what was written to word 0)` | writes word to one edge of the range, then reads it to check if it is matching  |

**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> Reads at 0x0000 and 0x0FFC return the values written to those adresses. Scoreboard will record what value was written for prediction, monitor will report what the DUT's actual read response was independent of the scoreboard. 

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.2 — `check_cpu_pulse`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Makes sure that cpu_halted_o is actually a pulse, and not just something that is asserted once and stays high/low. 

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> In the reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> Have to load some stimulus via the external port to get the cpu to halt --> some instr followed by E_BREAK

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(3)),
    EBREAK_WORD
};
run_directed("check_cpu_pulse", prog); //causes cpu_halted_o to pulse
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `cpu_halted_o` sampled every cycle | `high for one cycle, then low` | should pulse (halt the cpu) when the E_BREAK instr is executed, then go low after execution (the next cycle)|
| `x3`| `32'0003` | makes sure that cpu functions normally before being halted  |

**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> cpu_halted_o is observed to be high for exactly one cycle (pulsed), and then should be low the next cycle. No other state is expected to change throughout this test.

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.3 — `try_regfile_write`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Tries to write externally to the register file which is supposed to be read only addr_i[13:12] = 2'b10

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> not in the reset state, registers have some established non-zero val
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> some stimulus to load vals into the registers, then halt cpu

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

```systemverilog
prog = '{
    asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(7)), //store val in reg 1
    EBREAK_WORD
};
run_directed("try_regfile_write_setup", prog);

seqr.send_write_trans(word_addr(REG_BASE, 1), 32'some val(not 7)); //illegal external write attempt
seqr.wait_for_empty();
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `x1` | `7` | illegal write attempt should not work, reg must retain prev val|


**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> as per the external addr map, reg files are read only (should not be able to write to them externally as we should not intefere with instructions being executed within cpu). so the reg file should maintain the same val before and after the illegal write attempt, which we can verify by performing a legal read. 

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.4 — `read_and_write_en`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Tries to assert w_en_i and r_en_i together, which should be illegal

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> some word, so we can check for corruption
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> cpu should be disabled, drive cpuVif directly (connects to DUT's pins as per tb_top diagram)--> cannot do this through the driver/sequencer because as soon as you call one task it commits to either a read or write

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

```systemverilog
drv.reset_task();
seqr.send_write_trans(word_addr(DSRAM_BASE, 0), 32'some initial val); //addr we are writing/reading, with initial value
seqr.wait_for_empty();

cpu_if.addr  = word_addr(DSRAM_BASE, 0);
cpu_if.wdata = 32'some val; //data we attempt to write
cpu_if.w_en  = 1'b1; //setting test condition
cpu_if.r_en  = 1'b1;
@(posedge clk);
cpu_if.w_en  = 1'b0; //reseting ports to normal state
cpu_if.r_en  = 1'b0;

seqr.send_read_trans(word_addr(DSRAM_BASE, 0)); //reading at the target addr to check what happened 
seqr.wait_for_empty();
```

**Expected result:**

| Register or memory word | Expected value | Calculation or explanation |
| --- | --- | --- |
| `Data SRAM word` | `If read, uncorrupted, otherwise whatever val was supposed to be written` | it should either be a read or write --> if it is a read, then the word at that addr should bethe same, whereas, if it was a write, then whatever the value that was written. Depends on what the DUT chooses?


**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> The DUT should prioritize one operation over the other, always. So whether it's a read or write, the value should change accordingly (and not be some corrupted garbage value).

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.5 — `addi_neg_imm`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Tries to perform a mathematical subtraction by adding a negative immediate value using the addi instruction 

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> cpu should be disabled

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

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
| `x1` | `10` | adds the positive imm value of 10 to the x0 register which stores 0, stores 10+0=10 in register x1
| `x2` | `10-3=7` | takes the value in register x1,  subtracts the negative imm val of -3 from it , stores the result (10-3=7) in the register x2



**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> Mathematical operations should be performed as expected, registers x1 and x2 should store the appropriate final values

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.6 — `check_beq_func`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Verifies if the beq function works as expected, whether it branches to an addr only when rs1==rs2

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> cpu should be disabled

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

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
| `x1` | `5` | we set it to be a non-zero val
| `x2` | `1` | should not branch, fall through to next instr
| `x2` | `1` | same as prev



**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> We expect beq to not branch since x1 is compared to x0, and x1 is set to a non-zero val. It should fall through to the next 2 instrs and execute them.

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

### 1.7 — `honor_x0`

**Functionality:** <!-- State exactly what CPU behavior this test checks. --> Makes sure that the x0 value in the regfile cannot be nonzero

**Initial state:**

- Registers: <!-- Usually reset state unless the program establishes another value. --> reset state
- Data memory: <!-- List relevant initialized word addresses and values, or write “none.” --> none
- Other setup: <!-- Reset, program timeout, number of words to read back, etc. --> cpu should be disabled

**Program:**

<!-- Use the same representation that will be placed in run_member_directed_tests(). -->

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
| `x0` | `0` | x0 value should never change
| `x1` | `1` | 0+1=1,  helps us check the value above




**Pass criteria:** <!-- Include halt/timeout behavior and any state that must remain unchanged. --> We expect x0 to ignore the illegal write attempt. Adding 1 to x0 and storing the value in x1 should give us a value of 1.

**Final result:** <!-- Complete in testplan_final.md: pass/fail and useful log or waveform reference. -->

## 2. Constrained-random tests

### Instruction constraints

<!--
Explain the provided constraints, then record how the partial and open
constraints are completed. State what each constraint permits, excludes, or
biases and why the resulting programs remain useful and terminating.
-->

| Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
| --- | --- | --- | --- |
| `c_opcode` | Provided | It keeps the opcode values withing the given ISA | No member change |
| `c_reg_bias` | Provided | The constraint implement weighted distributions to bias the x0 register during testing | No member change |
| `c_imm_range` | Partial | Keeps the immediate value within the two's complement 12 bit range| Currently only the negative end of the 12 bit range is bounded, need to add a bound for the maximum positive value, imm <= 2047 |
| `c_mem_align` | Open | Adresses must always be word aligned, aka they should be divisible by 4. | Add a constraint that makes sure imm %4 == 0 |
| `c_imm_unused` | Provided | If the instr is not a I-type instr, then make sure the imm value is some fixed (irrelevant) value | No member change |
| `c_branch_target` | Partial | This enforces word alignment and makes sure that branching is done using a positive offset, this functionally avoids looping | Need to make sure that the program branches to some address within meaningful instruction memory, and not some garbage value. SO we need to add a upper bound to the imm val |
| `c_no_branch_at_end` | Provided | Avoids branching in the final slot before an E_BREAK instr is executed, so it doesn't branch to some illegal target | No member change |
| `c_branch_taken_bias` | Open | add a weighted distibution to bias the values of the registers being compared | Bias registers to have the same value a more number of times, so that branching occurs and we can close coverage  |

### External-port constraints

| Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
| --- | --- | --- | --- |
| `c_align` | Provided | Makes sure that the requests are aligned to word-sized addresses | No member change |
| `c_valid_window` | Partial | Makes sure that the addr window picked is valid according to the external port spec (2'b11 is unmapped) | Cannot exceed memory range, need to constrain some bits on the addr to zero, because the reg file (2'b10) only has 32 words. So need to add : addr[11:7] == 5'b0 if addr[13:12] == 2'b10|
| `c_reg_read_only` | Provided | The reg file is read-only, cannot be written through this external port | No member change |
| `c_data_corners` | Open | Add a weighted dist on data, to increase the probability of edge-case values | Assign a higher weight to 32'b0, 32'bFFFF so that boundary values are hit more often. Also bias signed boundaries (most negative and most positive number) |

### Random-program test

| Item | Plan |
| --- | --- |
| Number of programs per seed | Anywhere from 1-7 per seed |
| Program-length range | 5-15 instructions |
| Information logged for reproduction | Numeric `SVSEED`, iteration, and complete generated program |

**Implementation outline:**

```systemverilog
// Write the intended loop and lifecycle using seqr.gen_program(...).
//Repeat for however many programs we want to test per seed, choosing within our intended range 
//Pick a random program length within our planned range
//seqr.gen_program(random length)  , #generates random instructions + ebreak
//seqr.wait_for_empty()  , #let all instruction writes complete
//drv.run_program() , #starts CPU, waits for halt 
//Then the scoreboard compares actual vals vs. its own golden prediction)
```

## 3. Assertions

<!--
Plan at least two assertions in addition to the supplied example. Write the
timing rule in English first. In the final plan, include the exact SVA and
evidence from a temporary violation proving that the assertion can fire.
-->

### Assertion summary

| Assertion ID/name | Behavior checked | When it is sampled/disabled | Activating test |
| --- | --- | --- | --- |
| 4.1 / `READ_AND_WRITE` | Makes sure w_en_i and r_en_i are not asserted at the same time | Sampled every  cycle, disabled during rst | 1.4 |
| 4.2 / `X0_ALWAYS_ZERO` | Makes sure the value of the register x0 is always 0 | Sampled every  cycle | 1.7 |\
| 4.3 / `ADDI_SUM_MATCH` | Whenever an addi instruction completes,verify the mathematical corectness | Sampled every cycle, disabled during reset | 1.5


### 4.1 — `READ_AND_WRITE`

**Timing requirement in words:** 
On every cycle, except reset, w_en_i and r_en_i must not be asserted at the same time 

```systemverilog
READ_AND_WRITE:
  assert property (@(posedge clk) disable iff (rst)
    !(cpu_if.w_en && cpu_if.r_en))
  else assertion_fail("w_en_i and r_en_i asserted at the same time");
```

**Evidence that it detects a violation:** <!-- Temporary change, failing log/waveform, and confirmation after reverting it. -->

### 4.2 — `X0_ALWAYS_ZERO`

**Timing requirement in words:**
THe x0 value reflected in the crossbar needs to be 0 at all cycles.

```systemverilog
X0_ALWAYS_ZERO:
  assert property (@(posedge clk)
    register_crossbar[0] == 'b0)
  else assertion_fail("x0 value malfunction");
```

**Evidence that it detects a violation:**

### 4.3 — `ADDI_SUM_MATCH`

**Timing requirement in words:**
Whenever an addi instruction is completed the value written to its destination register must equal reg 1's value plus the sign-extended 12-bit immediate value for both positive and negative immediates.

```systemverilog
ADDI_RESULT_MATCHES_SIGNED_SUM:
  assert property (@(posedge clk_i) disable iff (rst_i)
    (dut.cpu.commit && dut.cpu.instr_type == ADDI)
    |-> (dut.cpu.rd_data == (dut.cpu.rs1_data + dut.cpu.imm)))
  else assertion_fail("addi instr did not perform as expected");
```

**Evidence that it detects a violation:**



## 4. Encrypted CPU Bug Hunt

### Random discovery

| Field                    | Evidence                      |
| ------------------------ | ----------------------------- |
| Discovery command        | `make bug_hunt SEED=random`   |
| Numeric `SVSEED`         |                               |
| Failing iteration        |                               |
| First failure message    |                               |
| Reproduction command     | `make bug_hunt SEED=________` |
| Reproduces consistently? | Yes / No                      |

**Original failing program:**

```systemverilog
prog = '{
  // Paste original generated sequence
  EBREAK_WORD
};
```

### Expected vs. actual

| Instruction / event | Expected | Actual | Cycle/time |
| ------------------- | -------- | ------ | ---------- |
|                     |          |        |            |

**First architectural divergence:**

<!-- State the first register, memory, or control-flow result that becomes incorrect. -->

### Minimization

**Minimized reproducer:**

```systemverilog
prog = '{
  // Smallest sequence that still fails
  EBREAK_WORD
};
```

### Waveform evidence

Include a screenshot showing the offending instruction and the first incorrect architectural result.

### Conclusion

**Trigger:**

<!-- Smallest condition that causes the failure. -->

**Expected behavior:**

<!-- ISA-correct behavior. -->

**Observed behavior:**

<!-- What the encrypted CPU does instead. -->

**Behavioral characterization:**

<!-- One precise sentence. Do not speculate about hidden RTL. -->

