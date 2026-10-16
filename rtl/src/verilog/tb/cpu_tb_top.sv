/*
 * Top-level testbench
 */
module cpu_tb_top;

    import cpu_tb_pkg::*;

    parameter int DataSize = DATA_W;
    parameter int AddrSize = XBAR_AW;

    string requested_seed = "default";

    int assertion_errors = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    // IF instantiation
    cpu_if #(.DataSize(DataSize), .AddrSize(AddrSize)) cpu_if(.clk(clk));

    // DUT instantiation
    chip_top dut (
        .clk_i(clk),
        .rst_i(cpu_if.cpu.reset),
        .en_cpu_i(cpu_if.cpu.en_cpu),
        .halt_cpu_i(cpu_if.cpu.halt_cpu),
        .cpu_halted_o(cpu_if.cpu.cpu_halted),
        .addr_i(cpu_if.cpu.addr),
        .wdata_i(cpu_if.cpu.wdata),
        .w_en_i(cpu_if.cpu.w_en),
        .r_en_i(cpu_if.cpu.r_en),
        .rdata_o(cpu_if.cpu.rdata),
        .rready_o(cpu_if.cpu.rready)
    );

    // Observation signals from the DUT memory path
    assign cpu_if.cpu_active     = dut.cpu_enable_q;
    assign cpu_if.dsram_en       = dut.dsram_en;
    assign cpu_if.dsram_write_en = dut.dsram_write_en;
    assign cpu_if.dsram_addr     = dut.dsram_addr;
    assign cpu_if.dsram_wdata    = dut.dsram_wdata;
    assign cpu_if.dsram_rdata    = dut.dsram_rdata;

    cpu_tb_pkg::cpu_sequencer #(.DataSize(DataSize), .AddrSize(AddrSize)) seqr;
    cpu_tb_pkg::cpu_driver #(.DataSize(DataSize), .AddrSize(AddrSize))    drv;
    cpu_tb_pkg::cpu_monitor #(.DataSize(DataSize), .AddrSize(AddrSize))   mon;
    cpu_tb_pkg::cpu_sb #(.DataSize(DataSize), .AddrSize(AddrSize))        sb;

    // Record failed assertion
    function void assertion_fail(input string message);
        assertion_errors++;
        $error($stime, " ASSERT: %s\n", message);
    endfunction: assertion_fail

    // Initialize both memories through the DUT's external memory port
    task automatic init_memories();
        $display($stime, " TB: Initializing instruction and data memories\n");
        mon.log_transactions = 1'b0;
        sb.log_transactions = 1'b0;
        for (int i = 0; i < ISRAM_WORDS; i++) begin
            seqr.send_write_trans(word_addr(ISRAM_BASE, i), EBREAK_WORD);
        end
        for (int i = 0; i < DSRAM_WORDS; i++) begin
            seqr.send_write_trans(word_addr(DSRAM_BASE, i), $urandom());
        end
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        mon.log_transactions = 1'b1;
        sb.log_transactions = 1'b1;
        $display($stime, " TB: Memory initialization complete\n");
    endtask: init_memories

    // Queue external reads on a memory window
    task automatic readback(input int window, input int num_words, input int start_word=0);
        logic [AddrSize-1:0] base;

        case (window)
            0: base = ISRAM_BASE;
            1: base = DSRAM_BASE;
            2: base = REG_BASE;
            default: base = REG_BASE;
        endcase

        for (int i = 0; i < num_words; i++) begin
            seqr.send_read_trans(word_addr(base, start_word + i));
        end
        seqr.wait_for_empty();
        repeat (4) @(cpu_if.cb);
    endtask: readback

    task automatic preload_dmem(input logic [31:0] values [$], input int start_word=0);
        foreach (values[i]) begin
            seqr.send_write_trans(word_addr(DSRAM_BASE, start_word + i), values[i]);
        end
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
    endtask: preload_dmem

    // Run a directed test
    task automatic run_directed(input string name, const ref logic [31:0] program_words [$],
            input int max_cycles=2000, input int dmem_words=16);
        $display("");
        $display("=================================================================");
        $display(" TEST: %s", name);
        $display("=================================================================");
        sb.set_test(name);

        drv.reset_task();
        seqr.load_program(program_words);
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        drv.run_program(max_cycles);

        if (drv.last_run_completed) begin
            readback(2, REG_COUNT);
            readback(1, dmem_words);
        end else begin
            $display($stime, " TB: Skipping %s readback after CPU timeout\n", name);
            drv.reset_task();
        end
    endtask: run_directed

    // Basic smoke test for loading, running, and observing a program that halts
    task automatic run_smoke_test();
        logic [31:0] smoke_prog [$];
        smoke_prog = '{ EBREAK_WORD };
        run_directed("smoke_ebreak", smoke_prog, 100, 1);
    endtask: run_smoke_test

    // Smoke test for stopping the CPU from outside the program
    // Readback is skipped because the CPU stops before the program completes
    task automatic run_external_halt_smoke();
        logic [31:0] long_prog [$];

        for (int i = 0; i < 32; i++) begin
            long_prog.push_back(asm_instr(.op(OP_ADDI), .rd(1), .rs1(1), .imm(1)));
        end
        long_prog.push_back(EBREAK_WORD);

        $display("");
        $display("=================================================================");
        $display(" TEST: smoke_external_halt");
        $display("=================================================================");
        sb.set_test("smoke_external_halt");

        drv.reset_task();
        seqr.load_program(long_prog);
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        drv.start_cpu();
        repeat (12) @(cpu_if.cb);
        drv.halt_cpu_now();
        drv.reset_task();
    endtask: run_external_halt_smoke

    //task to fire x0 assertion
    /*
    task automatic force_x0_violation();
        @(posedge clk);
        force dut.cpu.reg_crossbar_o[0] = 32'hEEEEEEEE; //force an illegal write of a non-zero val to x0
        @(posedge clk);
        @(posedge clk);
        release dut.cpu.reg_crossbar_o[0];
    endtask: force_x0_violation
    */ 

    //task to fire read write assertion
    /*
    task automatic force_simultaneous_rw_vio(); 
        @(posedge clk);
        force cpu_if.w_en = 1'b1; //force both signals to be en
        force cpu_if.r_en = 1'b1;
        @(posedge clk);
        @(posedge clk);
        release cpu_if.w_en;
        release cpu_if.r_en;
        drv.reset_task(); 
    endtask: force_simultaneous_rw_vio
    */

        //TESTS TO REPRODUCE BUGS 

        //BUG 1

        //Minimized reproducer for BUG 1 
        task automatic mr_srl_random3(); //taken from random_3 in the log
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'hD2E92947};
            preload_dmem(d, 'h7C);
            d = '{32'hCD4C9D4D};
            preload_dmem(d, 'h132);
            p = '{                                                      //log line references 
                asm_instr(.op(OP_LW),   .rd(1), .rs1(12), .imm(496)),   //[13]  x1 = 0xD2E92947
                asm_instr(.op(OP_SRL),  .rd(2), .rs1(1),  .rs2(6)),     //[18]  x2 = x1 >> 0
                asm_instr(.op(OP_ADDI), .rd(2), .rs1(2),  .imm(-740)),  //[20]  x2 = 0xD2E92663, x2[5:0] = 35
                asm_instr(.op(OP_LW),   .rd(1), .rs1(8),  .imm(1224)),  //[28]  x1 = 0xCD4C9D4D
                asm_instr(.op(OP_ADDI), .rd(3), .rs1(1),  .imm(1073)),  //[246] x3 = 0xCD4CA17E
                asm_instr(.op(OP_SRL),  .rd(1), .rs1(3),  .rs2(15)),    //[248] x1 = x3 >> 0
                asm_instr(.op(OP_SRL),  .rd(7), .rs1(1),  .rs2(2)),     //we expect x7 = 0x19A9942F
                EBREAK_WORD
            };
            run_directed("mr_srl_random3", p, 2000, 8);
        endtask

        //Tests that helped me find and pinpoint BUG 1

        //uses incorrect shift mask, checks if sll is affected 
        task automatic test_shift_mask();
            logic [31:0] p [$];
            p = '{
                asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1)),
                asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(32)), //shift by 32 bits
                asm_instr(.op(OP_SLL),  .rd(3), .rs1(1), .rs2(2)), //we expect reg x3 = 1
                EBREAK_WORD
            };
            run_directed("test_shift_mask", p, 2000, 8); //failed
        endtask

        //tells us that the does not depend on bit 6
        task automatic test_shift_5th_bit();
            logic [31:0] p [$];
            p = '{
                asm_instr(.op(OP_ADDI), .rd(20), .rs1(0), .imm(1)),
                asm_instr(.op(OP_ADDI), .rd(21), .rs1(0), .imm(64)),
                asm_instr(.op(OP_SLL),  .rd(22), .rs1(20), .rs2(21)), //we expect x22 = 1 (64 has bit 5 clear)
                EBREAK_WORD
            };
            run_directed("test_shift_5th_bit", p, 2000, 8); //passed, so we know the other bits above 5 don't matter and arent causing the bug
        endtask

        //same as failing program but clears bit 5 to confirm that is the error
        task automatic test_bit5_clear();
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'hD2E92947};
            preload_dmem(d, 'h7C);
            d = '{32'hCD4C9D4D};
            preload_dmem(d, 'h132);
            p = '{
                asm_instr(.op(OP_LW),   .rd(1), .rs1(12), .imm(496)),
                asm_instr(.op(OP_SRL),  .rd(2), .rs1(1),  .rs2(6)),
                asm_instr(.op(OP_ADDI), .rd(2), .rs1(2),  .imm(-772)), //clears bit 5 as the imm is 32 lower than -740, so lower 6 bits go from 100011 to 000011
                asm_instr(.op(OP_LW),   .rd(1), .rs1(8),  .imm(1224)),
                asm_instr(.op(OP_ADDI), .rd(3), .rs1(1),  .imm(1073)), 
                asm_instr(.op(OP_SRL),  .rd(1), .rs1(3),  .rs2(15)),
                asm_instr(.op(OP_SRL),  .rd(7), .rs1(1),  .rs2(2)),
                EBREAK_WORD
            };
            run_directed("test_bit5_clear", p, 2000, 8); //passes, so we know bit 5 is causing our bug
        endtask

        //BUG 2 

        //Minimized reproducer for BUG 2
        task automatic mr_lw_beq_random8(); //taken from random_8
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'h92ED1F2D};
            preload_dmem(d, 'h1F2);
            p = '{                                                      //log line ref:
                asm_instr(.op(OP_LW),   .rd(1), .rs1(0),  .imm(1992)),  //[17] x1 = 0x92ED1F2D
                asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(30), .imm(8)),    //[18] x30 = 0 , so the branch should notbe  taken
                asm_instr(.op(OP_SLL),  .rd(1), .rs1(7),  .rs2(9)),     //[19] we expect x1 = 0
                EBREAK_WORD
            };
            run_directed("mr_lw_beq_random8", p, 2000, 8);
        endtask

        //Tests that helped me find and pinpoint BUG 2

        //beq immediately after a load writing a comparison reg
        task automatic test_beq_after_lw();
            logic [31:0] p [$];
            p = '{
                asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(100)),
                asm_instr(.op(OP_ADDI), .rd(9), .rs1(0), .imm(7)),
                asm_instr(.op(OP_SW),   .rs1(5), .rs2(9), .imm(0)), //stores 7 at addr=100
                asm_instr(.op(OP_LW),   .rd(4), .rs1(5), .imm(0)),  
                asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(4), .imm(8)),  //x1=0, x4 = 7 ->we expect this branch to not be taken
                asm_instr(.op(OP_ADDI), .rd(8), .rs1(0), .imm(2047)), //should not skip this
                EBREAK_WORD
            };
            run_directed("test_beq_after_lw", p, 2000, 32); //passed, so we know its not the prob
        endtask

        task automatic test_lw_nop_beq(); //tries to copy failure from random_8 with a nop inserted in the middle of the instrs
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'h92ED1F2D};
            preload_dmem(d, 'h1F2);
            p = '{
                asm_instr(.op(OP_LW),   .rd(1), .rs1(0),  .imm(1992)), //val from random_8
                asm_instr(.op(OP_ADDI), .rd(0), .rs1(0),  .imm(0)),  //to denote a no operation
                asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(30), .imm(8)), //should not take branch, and should not compare old vals
                asm_instr(.op(OP_SLL),  .rd(1), .rs1(7),  .rs2(9)),    //we expect x1 = 0
                EBREAK_WORD
            };
            run_directed("test_lw_nop_beq", p, 2000, 8); //passed
        endtask

        task automatic test_lw_beq_stale();
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'h00000000};
            preload_dmem(d, 'h1F2);
            p = '{
                asm_instr(.op(OP_ADDI), .rd(1), .rs1(0),  .imm(1)), //old x1 = 1
                asm_instr(.op(OP_LW),   .rd(1), .rs1(0),  .imm(1992)), //we load in a new val for x1
                asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(30), .imm(8)),  //should branch, compare newly loaded vals
                asm_instr(.op(OP_ADDI), .rd(8), .rs1(0),  .imm(2047)),  //should skip this 
                EBREAK_WORD
            };
            run_directed("test_lw_beq_stale", p, 2000, 8); //failed
        endtask

        task automatic test_beq_after_addi();
            logic [31:0] p [$];
            p = '{
                asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(7)), //sets the val of x4 using addi instead of lw
                asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(4), .imm(8)),   //x1=0, x4=7 ->we expect this branch to not be taken
                asm_instr(.op(OP_ADDI), .rd(8), .rs1(0), .imm(2047)),
                EBREAK_WORD
            };
            run_directed("test_beq_after_addi", p, 2000, 8); //passes so showed me that the prob is specific to a load before a beq instr
        endtask


        //BUG 3

        //Minimized reproducer for BUG 3
        task automatic mr_sw_lw_random0(); //taken from random_0
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'hB99891D9};
            preload_dmem(d, 'h46);                                       //word read by [110]
            p = '{                                                      //reference lines from log 
                asm_instr(.op(OP_ADDI), .rd(6), .rs1(3),  .imm(-374)),  //[17]  x6 = 0xFFFFFE8A, base for [110]
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(856)), //[109] store x29 = 0 to word 0xD6
                asm_instr(.op(OP_LW),   .rd(2), .rs1(6),  .imm(654)),   //[110] load word 0x46:we expect x2 = 0xB99891D9
                asm_instr(.op(OP_SUB),  .rd(7), .rs1(14), .rs2(4)),     //[111] unrelated, kept from the log
                asm_instr(.op(OP_SW),   .rs1(3), .rs2(2),  .imm(1740)), //[112] store x2 to word 0x1B3
                EBREAK_WORD
            };
            run_directed("mr_sw_lw_random0", p, 2000, 8);
        endtask

        //Tests that helped me find and pinpoint BUG 3


        task automatic test_sw_lw_nop(); //checks if the bug is caused by a lw directly after a sw
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'hB99891D9}; //val taken from random_0
            preload_dmem(d, 'h46);                                       // word read by [110]
            p = '{                                                      //log line ref:
                asm_instr(.op(OP_ADDI), .rd(6), .rs1(3),  .imm(-374)),  // [17] x6 = 0xFFFFFE8A
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(856)), // [109] store 0 to word 0xD6
                asm_instr(.op(OP_ADDI), .rd(0), .rs1(0),  .imm(0)),     // this is a nop, to see if it hides the bug 
                asm_instr(.op(OP_LW),   .rd(2), .rs1(6),  .imm(654)),   // [110]we expect x2 = 0xB99891D9
                asm_instr(.op(OP_SUB),  .rd(7), .rs1(14), .rs2(4)),     // [111]
                asm_instr(.op(OP_SW),   .rs1(3), .rs2(2),  .imm(1740)), // [112] store x2 to word 0x1B3
                EBREAK_WORD
            };
            run_directed("test_sw_lw_nop", p, 2000, 8); //passes, which tells us we need a sw followed by a lw
        endtask

        task automatic test_sw_lw_addr_bits(); //tells us how which addr bits must match for lw to fetch the same word as the sw
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'hB99891D9};
            preload_dmem(d, 'h46);  //this is the word every lw reads
            p = '{                                                        //we check for each bit
                asm_instr(.op(OP_ADDI), .rd(6),  .rs1(3),  .imm(-374)),   //x6 = 0xFFFFFE8A, lw 654(x6) = word 0x46
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(284)),   // bit 0: store 0 to word 0x47
                asm_instr(.op(OP_LW),   .rd(10), .rs1(6),  .imm(654)),    //        we expect x10 = 0xB99891D9, the preloaded val every time
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(272)),   // bit 1: store 0 to word 0x44
                asm_instr(.op(OP_LW),   .rd(11), .rs1(6),  .imm(654)),       
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(264)),   // bit 2: store 0 to word 0x42
                asm_instr(.op(OP_LW),   .rd(12), .rs1(6),  .imm(654)),        
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(312)),   // bit 3: store 0 to word 0x4E
                asm_instr(.op(OP_LW),   .rd(13), .rs1(6),  .imm(654)),        
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(344)),   // bit 4: store 0 to word 0x56
                asm_instr(.op(OP_LW),   .rd(14), .rs1(6),  .imm(654)),          
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(408)),   // bit 5: store 0 to word 0x66
                asm_instr(.op(OP_LW),   .rd(15), .rs1(6),  .imm(654)),         
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(24)),    // bit 6: store 0 to word 0x06
                asm_instr(.op(OP_LW),   .rd(16), .rs1(6),  .imm(654)),    
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(792)),   // bit 7: store 0 to word 0xC6
                asm_instr(.op(OP_LW),   .rd(17), .rs1(6),  .imm(654)),       
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(1304)),  // bit 8: store 0 to word 0x146
                asm_instr(.op(OP_LW),   .rd(18), .rs1(6),  .imm(654)),         
                asm_instr(.op(OP_SW),   .rs1(23), .rs2(29), .imm(-1768)), // bit 9: store 0 to word 0x246 
                asm_instr(.op(OP_LW),   .rd(19), .rs1(6),  .imm(654)),     
                EBREAK_WORD
            };
            run_directed("test_sw_lw_addr_bits", p, 2000, 8); //bit 0:3 come back as match, telling us it only compares those bits before deciding 
        endtask

        task automatic test_4bits_match(); //confirms the hypothesis of previous test, vals taken from random_9
            logic [31:0] p [$];
            logic [31:0] d [$];
            d = '{32'h832B50C7};
            preload_dmem(d, 'h92);    //first we load 0x92
            d = '{32'h1CC26A38};
            preload_dmem(d, 'h105);   //then we load 0x105
            p = '{
                asm_instr(.op(OP_LW),   .rd(5), .rs1(21), .imm(584)),   //x5 = 0x832B50C7 (word 0x92)
                asm_instr(.op(OP_SW),   .rs1(1), .rs2(5),  .imm(532)),  //store x5 to word 0x85 , because 0x85 and 0x105 both end in 0101 (last 4 bits match)
                asm_instr(.op(OP_LW),   .rd(1), .rs1(7),  .imm(1044)),  //load word 0x105: expect x1 = 0x1CC26A38
                asm_instr(.op(OP_SLL),  .rd(3), .rs1(1),  .rs2(7)),     //x3 = x1 << 0: expect x3 = 0x1CC26A38
                EBREAK_WORD
            };
            run_directed("test_4bits_match", p, 2000, 8); //fails, confirming the bug 
        endtask

    
    task automatic run_reproduce_bugs_tests(); //task to call all bug specific tests
    // Bug 1: shift amount taken from rs2[5:0]
    // Bug 1 minimized reproducer
    mr_srl_random3();
    // tests added to separate the trigger from nearby possibilities
    test_bit5_clear();
    test_shift_mask();
    test_shift_5th_bit();
    // Bug 2: BEQ right after an LW compares the old value
    // Bug 2 minimized reproducer
    mr_lw_beq_random8();
    // tests added to separate the trigger from nearby possibilities
    test_lw_beq_stale();
    test_lw_nop_beq();
    test_beq_after_addi();
    test_beq_after_lw();
    // Bug 3: LW right after an SW returns the SW's data
    // Bug 3 minimized reproducer
    mr_sw_lw_random0();
    // tests added to separate the trigger from nearby possibilities
    test_4bits_match();
    test_sw_lw_nop();
    test_sw_lw_addr_bits();
    endtask

    

    // TEST PROGRAM
    logic [31:0] prog [$];
    logic [31:0] data [$];

    int NUM_RANDOM_PROGRAMS = 20;
    int NUM_RANDOM_XBAR = 300;

    initial begin
        int total_errors;

        mon = new(cpu_if);
        sb = new(mon.mon_box);
        seqr = new();
        drv = new(cpu_if, seqr.xbar_box);

        void'($value$plusargs("NUM_RANDOM_PROGRAMS=%d", NUM_RANDOM_PROGRAMS));
        void'($value$plusargs("NUM_RANDOM_XBAR=%d", NUM_RANDOM_XBAR));
        if ($test$plusargs("REF_TRACE")) begin
            sb.ref_model.trace = 1'b1;
        end

        fork
            mon.run();
            sb.run();
            drv.run();
        join_none

        drv.reset_task();
        init_memories();

        run_smoke_test();
        run_external_halt_smoke();


        // DIRECTED TESTS
        drv.reset_task();
        init_memories();

        // TODO: Add directed test cases from the test plan
        // Use the existing helpers

        
        if ($test$plusargs("REPRODUCE_BUGS")) begin //flag to run tests that reproduce the 3 bugs  
            run_reproduce_bugs_tests();
        end 
        else begin      //otherwise rrun directed tests 
        
        drv.reset_task();
        init_memories();
        //force_x0_violation(); //only to capture the assertion firing
        //force_simultaneous_rw_vio(); //same as above


        // Example Test: addi with a positive immediate
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(100)),
            EBREAK_WORD
        };
        run_directed("addi_positive", prog);

        //Test 1.1
        seqr.send_write_trans(word_addr(ISRAM_BASE, 0),    32'hAAAA_AAAA);
        seqr.send_write_trans(word_addr(ISRAM_BASE, 1023), 32'h5555_5555);
        seqr.send_read_trans(word_addr(ISRAM_BASE, 0));
        seqr.send_read_trans(word_addr(ISRAM_BASE, 1023));
        seqr.wait_for_empty();

        //Test 1.2
        drv.reset_task();
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(3)),
            EBREAK_WORD
        };
        run_directed("check_cpu_pulse", prog);


        //Test 1.3-redundant, scoreboard takes care of this and exits xcelium, tells you reg file window is read only
        

        //Test 1.4
        drv.reset_task();
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(-3)),
            EBREAK_WORD
        };
        run_directed("addi_neg_imm", prog);


        //Test 1.5
        drv.reset_task();
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
            asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(0), .imm(8)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(1)),
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(2)),
            EBREAK_WORD
        };
        run_directed("check_beq_func", prog);


        //Test 1.6
        drv.reset_task();
        init_memories();
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(0), .rs1(0), .imm(5)),
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1)),
            EBREAK_WORD
        };
        run_directed("honor_x0", prog);


        //Test 1.7
        drv.reset_task();
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


        //Test 1.8
        drv.reset_task();
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


        //Test 1.9 
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


        //Test 1.10
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


        //Test 1.11: 
        drv.reset_task();
        init_memories();
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(0)),      
            asm_instr(.op(OP_ADDI), .rd(5), .rs1(0), .imm(0)),     
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(1024)),  //loop counter

        // loop body
        asm_instr(.op(OP_SW),   .rs1(3), .rs2(3), .imm(0)),    //store addr value at that addr
        asm_instr(.op(OP_LW),   .rd(4),  .rs1(3), .imm(0)),    //read it back
        asm_instr(.op(OP_ADD),  .rd(5),  .rs1(5), .rs2(4)),    //x5 += x4
        asm_instr(.op(OP_ADDI), .rd(3),  .rs1(3), .imm(4)),    //adv address
        asm_instr(.op(OP_ADDI), .rd(1),  .rs1(1), .imm(-1)),   //decrement counter
        asm_instr(.op(OP_BEQ),  .rs1(1), .rs2(0), .imm(8)),     //exit only when counter hits 0
        asm_instr(.op(OP_BEQ),  .rs1(0), .rs2(0), .imm(-24)),   //otherwise loop back

        EBREAK_WORD
        };
        run_directed("dsram_full_depth", prog, 10000, 4);
        

        //Test 1.12: two back-to-back taken branches, each skipping instructions
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

        //Test 1.13: reproduce the exact back-to-back-store pattern, see if dsram_en_o goes high
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

        




        // CONSTRAINED-RANDOM TESTS
        // TODO: Add constrained-randomized testing for cpu_seq_item and cpu_xbar_item
        // For every random CPU program:
        //   1. print an iteration label so the seed and failure are reproducible,
        //   2. reset the CPU and call init_memories() before gen_program(),
        //   3. wait for program writes, run with the supplied bounded helper,
        //   4. queue the register and relevant memory reads needed by the scoreboard.
        // Keep randomized external-port traffic in a phase where the CPU is stopped.
        // The README explains why memory must be reinitialized every iteration.

        sb.ref_model.trace = 1'b1;  //asserted to help debug

        for (int i = 0; i < NUM_RANDOM_PROGRAMS; i++) begin
            automatic string test_name = $sformatf("random_%0d", i);
            automatic int    num_instrs = $urandom_range(ISRAM_WORDS - 1, 1);
            automatic int    num_xbar   = $urandom_range(NUM_RANDOM_XBAR, 0);

            // prints iteration label 
            $display("");
            $display("=================================================================");
            $display(" TEST: %s (%0d random instructions, %0d random xbar transactions)", test_name, num_instrs, num_xbar);
            $display("=================================================================");
            sb.set_test(test_name);

            //resets cpu and calls init_memories()
            drv.reset_task();
            init_memories();

            //gen_program() builds the random program and stages its ISRAM writes.
            seqr.gen_program(num_instrs, 1'b1);

            //waits for program writes, then runs with the supplied bounded helper
            seqr.wait_for_empty();
            repeat (num_instrs + 10) @(cpu_if.cb);
            drv.run_program(2000);

            //queues the register and relevant memory reads needed by the sb
            if (drv.last_run_completed) begin
                repeat (5) @(cpu_if.cb);
                readback(2, REG_COUNT);
                readback(1, DSRAM_WORDS);
            end 
            
            else begin
                $display($stime, " TB: Skipping %s readback after CPU timeout\n", test_name);
                drv.reset_task();
            end
        

            //randomizes external prt traffic while cpu is stopped
            if (num_xbar > 0) begin
            seqr.gen_xbar(num_xbar, 1'b1);
            seqr.wait_for_empty();
            end
        end
    end
            

        // TEST FINISH
        repeat (20) @(cpu_if.cb);
        total_errors = sb.errors + drv.timeouts + mon.errors + assertion_errors;
        if (sb.checks == 0) begin
            $error("Testbench performed zero checks; no results were verified");
        end

        $display("=================================================================");
        $display("  Scoreboard mismatches : %0d", sb.errors);
        $display("  Driver timeouts       : %0d", drv.timeouts);
        $display("  Monitor protocol errs : %0d", mon.errors);
        $display("  Assertion failures    : %0d", assertion_errors);
        $display("=================================================================");
        $display();

        if (total_errors == 0) begin
            $display("=================================================================");
            $display(" TEST PASSED!");
            $display("=================================================================");
        end else begin
            $display("=================================================================");
            $display(" TEST FAILED: %0d error(s)", total_errors);
            $display("=================================================================");
        end
        $finish;
    end

    // Stop a broken DUT or testbench instead of letting the simulation run forever
    initial begin
        #10ms;
        $display(" TEST FAILED - global timeout");
        $fatal(1, "global timeout");
    end

    initial begin
        void'($value$plusargs("SEED_LABEL=%s", requested_seed));
        if ($test$plusargs("BUG_HUNT_WAVES")) begin
            $shm_open("bug_hunt_waves.shm");
        end else begin
            $shm_open("waves.shm");
        end
        $shm_probe("AC");
    end

    wire rst = cpu_if.reset;
    // TODO: Add the required protocol or control assertions from the testplan

    // Example assertion
    // It checks one interface rule and sends failures through the testbench counter
    NO_SIMULTANEOUS_READ_WRITE:
        assert property (@(posedge clk) disable iff (rst)
            !(cpu_if.w_en && cpu_if.r_en))
        else assertion_fail("w_en_i and r_en_i were asserted together");

    
    X0_ALWAYS_ZERO:
        assert property (@(posedge clk)
            dut.cpu.reg_crossbar_o[0] == '0)
        else assertion_fail("x0 value malfunction");

    //test 1.2 implemented as an assertion
    CPU_HALT_PULSE_CHECK:
    assert property (@(posedge clk) disable iff (rst)
        $rose(cpu_if.cpu_halted) |-> cpu_if.cpu_active)
    else assertion_fail("cpu_halted_o rose when CPU was not active");


endmodule: cpu_tb_top
