import cpu_pkg::*;

//decides what to write into destination register
module writeback (
    input  instr_type_e instr_type_i,
    input  logic         commit_i, //external input from cpu top to check if the instr is complete
    input  logic [31:0]  alu_result_i,
    input  logic [31:0]  dsram_rdata_i,

    output logic         rd_write_en_o,
    output logic [31:0]  rd_data_o
);

    assign rd_write_en_o = commit_i && (instr_type_i == ADD  || instr_type_i == ADDI ||
                                         instr_type_i == SUB  || instr_type_i == SLL  ||
                                         instr_type_i == SRL  || instr_type_i == LOAD); //decides whether to write to a register this cycle

    assign rd_data_o = (instr_type_i == LOAD) ? dsram_rdata_i : alu_result_i; //chooses what val to write into destination reg - between memory(for load) and alu(other instrs)

endmodule