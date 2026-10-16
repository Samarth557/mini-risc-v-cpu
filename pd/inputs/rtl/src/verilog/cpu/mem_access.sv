import cpu_pkg::*;

//decides memory access for lw/sw instructions
module mem_access (
    input  logic         clk_i,
    input  logic         rst_i,
    input  instr_type_e instr_type_i,
    input  logic         instr_vld_i,
    input  logic         dsram_rready_i, 
    input  logic [31:0]  alu_result_i,
    input  logic [31:0]  rs2_data_i,

    output logic         dsram_en_o,
    output logic         dsram_write_en_o,
    output logic [9:0]   dsram_addr_o,
    output logic [31:0]  dsram_wdata_o,
    output logic         mem_wait_o

);

    logic load_req_active;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            load_req_active <= 1'b0;
        end 
        
        else if (instr_vld_i && instr_type_i == LOAD) begin
            if (!load_req_active)
                load_req_active <= 1'b1;
            else if (dsram_rready_i)
                load_req_active <= 1'b0;
        end 
        
        else begin
            load_req_active <= 1'b0;
        end
    end

    assign mem_wait_o = (instr_type_i == LOAD) && !(load_req_active && dsram_rready_i); //mem_wait is now a reg in mem_access

    logic mem_op; //for convenience
    assign mem_op = (instr_type_i == LOAD) || (instr_type_i == STORE); //boolean to check whether current instr is a lw/sw 

   assign dsram_en_o = instr_vld_i && (
                    ((instr_type_i == LOAD) && !(load_req_active && dsram_rready_i)) ||
                    (instr_type_i == STORE) ); //makes sure dsram_en_o does not carry stale values from prev cycles, ready gating is only applied for load instrs
    assign dsram_write_en_o = instr_vld_i && (instr_type_i == STORE); //makes write enable high only if instr is store word (removed gating on sram_ready)
    assign dsram_addr_o     = alu_result_i[11:2]; 
    assign dsram_wdata_o    = rs2_data_i; //value to be written from reg in register file



endmodule