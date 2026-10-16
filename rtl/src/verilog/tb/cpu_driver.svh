/*
 * Converts sequences from the sequencer into signals that drive the external
 * port of the DUT. This is the only class that drives the DUT. It uses the
 * clocking block to avoid races with the monitor.
 *
 * Check memory_controller to see how it arbitrates memory ownership between
 * the CPU and the external port, and acts as a crossbar (xbar) to route external
 * access to ISRAM, DSRAM, and registers.
 */
class cpu_driver #(int DataSize=32, int AddrSize=14);

    virtual interface cpu_if #(.DataSize(DataSize), .AddrSize(AddrSize)) cpuVif;

    mailbox #(cpu_xbar_item #(DataSize, AddrSize)) xbar_box;

    // Maximum cycles to wait for an external read to finish
    int xbar_timeout = 32;

    // Maximum cycles to wait for the CPU to halt
    int run_timeout = 20000;

    int timeouts;                // Counts timeout failures
    bit last_run_completed;      // High when the CPU reports a clean halt

    // Constructor
    function new(virtual interface cpu_if #(DataSize, AddrSize) cpuVif,
                 mailbox #(cpu_xbar_item #(DataSize, AddrSize)) xbar_box);
      this.cpuVif   = cpuVif;
      this.xbar_box = xbar_box;
      this.timeouts = 0;
      this.last_run_completed = 1'b0;
    endfunction: new

    // Put the DUT into a known reset state
    task reset_task();
        // TODO: Drive all requests inactive, hold reset for several clock
        // cycles, then release it and give the interface time to settle
        
        do begin
            while ((xbar_box.num() != 0) || cpuVif.cb.r_en || cpuVif.cb.w_en) begin //we want to wait until either there are no transactions in the mailbox or no read/write reqs
                @(cpuVif.cb); //loopback
            end
            @(cpuVif.cb);   //re-check one more cycle later, in case a transaction was mid-dequeue and hadnt raised r_en/w_en yet
                        
        end 
        while ((xbar_box.num() != 0) || cpuVif.cb.r_en || cpuVif.cb.w_en);

        cpuVif.cb.reset    <= 1'b1;
        cpuVif.cb.en_cpu   <= 1'b0;
        cpuVif.cb.halt_cpu <= 1'b0;
        cpuVif.cb.addr     <= '0;
        cpuVif.cb.wdata    <= '0;
        cpuVif.cb.w_en     <= 1'b0;
        cpuVif.cb.r_en     <= 1'b0;

        repeat (5) @(cpuVif.cb); //holds reset for 5 cycles

        cpuVif.cb.reset <= 1'b0;

        repeat (2) @(cpuVif.cb); //2 cycles given to settle  

        //$fatal(1, "implement cpu_driver.reset_task");
    endtask: reset_task

    // Send one write through the DUT's external memory port
    task xbar_write(input logic [AddrSize-1:0] addr, input logic [DataSize-1:0] data);
        if (addr[1:0] != 2'b00) begin
            $error($stime, " DRIVER: external write address 0x%0x is not word aligned\n", addr);
        end

        // TODO: Drive one external write through the clocking block for one request, 
        // then return the port to idle

        @(cpuVif.cb);
        cpuVif.cb.addr  <= addr;
        cpuVif.cb.wdata <= data;
        cpuVif.cb.w_en  <= 1'b1;

        @(cpuVif.cb);
        cpuVif.cb.w_en  <= 1'b0;
        cpuVif.cb.addr  <= '0;
        cpuVif.cb.wdata <= '0;

        //$fatal(1, "implement cpu_driver.xbar_write");
    endtask: xbar_write

    // Send one read through the external memory port and wait for its data
    task xbar_read(input logic [AddrSize-1:0] addr);
        bit timed_out;
        int count;

        $display($stime, " DEBUG xbar_read: starting read of addr 0x%04x", addr);

        if (addr[1:0] != 2'b00) begin
            $error($stime, " DRIVER: external read address 0x%0x is not word aligned\n", addr);
        end

        // TODO: Keep the request stable until rready, capture the returned
        // data, and set a timeout for the response

        timed_out = 1'b0;
        count = 0; //to count the cycles 

        @(cpuVif.cb);  //at clk edge of clocking block
        cpuVif.cb.addr <= addr; //drive read addr 
        cpuVif.cb.r_en <= 1'b1; //en read signal

        @(cpuVif.cb); //move to next cycle
        while (!cpuVif.cb.rready && !timed_out) begin //we want to keep waiting for a respionse until we time out 
            count++; //inc cycle counter
            if (count >= xbar_timeout) begin //cond for timeout
                timed_out = 1'b1; //we timed out 
                timeouts++; //timout counter for reporting
                $error($stime, " DRIVER: external read at addr 0x%0x timed out after %0d cycles\n",
                       addr, xbar_timeout);
            end else begin
                @(cpuVif.cb);  //not ready, wait one cycle and check again
            end
        end

        cpuVif.cb.r_en <= 1'b0; //req over/time out so we drop read en signal 
        cpuVif.cb.addr <= '0; //drive addr to 0 to clear it

        //$fatal(1, "implement cpu_driver.xbar_read");
    endtask: xbar_read

    // Drive a start request for one CPU run
    task start_cpu();
        // TODO: Pulse en_cpu
        @(cpuVif.cb);
        cpuVif.cb.en_cpu <= 1'b1;
        @(cpuVif.cb);
        cpuVif.cb.en_cpu <= 1'b0;

        //$fatal(1, "implement cpu_driver.start_cpu");
    endtask: start_cpu

    // Wait for the CPU to halt, or fail after the allowed number of cycles
    task wait_for_halt(output int cycles, input int max_cycles=0);
        int limit;

        limit  = (max_cycles == 0) ? run_timeout : max_cycles; //ternary to choose between defualt and user input for timeout 
        cycles = 0; //cycle counter 

        // TODO: Check cpu_halted on each cycle and report how many cycles
        // ran. Set last_run_completed only after a real halt. On a timeout, increment
        // timeouts and leave the flag low so the testbench can recover.

        last_run_completed = 1'b0; //run not completed yet

        while (!cpuVif.cb.cpu_halted && (cycles < limit)) begin //we want to keep going till no halt or timeout 
            @(cpuVif.cb);
            cycles++; //inc cycle counter
        end

        if (cpuVif.cb.cpu_halted) begin //if halt signal asserted
            last_run_completed = 1'b1; //our run is complete
        end else begin
            timeouts++; //otherwise we timed out, incr timeout for reproting
            $error($stime, " DRIVER: CPU did not halt after %0d cycles\n", limit); //report cycles
        end

        //$fatal(1, "implement cpu_driver.wait_for_halt");
    endtask: wait_for_halt

    // Start CPU and wait for it to halt
    task run_program(input int max_cycles=0);
        int cycles;

        last_run_completed = 1'b0;
        start_cpu();
        wait_for_halt(cycles, max_cycles);
    endtask: run_program

    // Stop a program through an external halt and wait for memory ownership
    // to return to the external port
    task halt_cpu_now();
        // TODO: Assert an external halt request and wait, with a bound,
        // until ownership returns to the external port

        //counter
        int count;
        bit timed_out; //flag for timeout 

        count = 0;
        timed_out = 1'b0;

        @(cpuVif.cb); 
        cpuVif.cb.halt_cpu <= 1'b1; //assert halt on cb edge
        @(cpuVif.cb);  //hold for one cuycle
        cpuVif.cb.halt_cpu <= 1'b0; //deassert

        while (cpuVif.cb.cpu_active && !timed_out) begin //wait till cpu is inactive or timeout 
            count++; //otherwise inc count
            if (count >= xbar_timeout) begin //cond for timeout
                timed_out = 1'b1;  //we timed out
                timeouts++; //incr counter
                $error($stime,
                       " DRIVER: halt_cpu_now timed out waiting for cpu_active to deassert after %0d cycles\n",
                       xbar_timeout);
            end else begin
                @(cpuVif.cb); //signal did not deassert, wait a cycle and loop back to check again 
            end
        end

        //$fatal(1, "TODO: implement cpu_driver.halt_cpu_now");
    endtask: halt_cpu_now

    // Main driver loop. Keeps taking transactions from the mailbox and
    // driving them through the DUT
    task run();
        cpu_xbar_item #(DataSize, AddrSize) trans;

        forever begin
            xbar_box.get(trans);
            if (trans.is_write) begin
                xbar_write(trans.addr, trans.data);
            end else begin
                xbar_read(trans.addr);
            end
        end
    endtask: run

endclass: cpu_driver