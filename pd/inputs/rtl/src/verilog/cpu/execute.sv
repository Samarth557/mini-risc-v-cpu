import cpu_pkg::*;

// executes operation using alu
module execute (
    input  logic [31:0] pc_i,
    input  logic [31:0] rs1_data_i,
    input  logic [31:0] rs2_data_i,
    input  logic [31:0] imm_i,
    input  instr_type_e instr_type_i, //input instr, tells alu which operation to perform

    output logic [31:0] alu_result_o, //stores result
    output logic        branch_vld_o, //branch instruction
    output logic        branch_taken_o, //branch condition 
    output logic [9:0]  branch_trgt_o //word-address target for fetch
);

    logic [31:0] branch_byte_addr; //adds to pc 

    always_comb begin
        alu_result_o = 32'd0;
        branch_vld_o = 1'b0;
        branch_taken_o = 1'b0;
        branch_trgt_o = 10'd0;
        branch_byte_addr = 32'd0;

        case (instr_type_i)
            ADD:  alu_result_o = rs1_data_i + rs2_data_i;
            ADDI: alu_result_o = rs1_data_i + imm_i;
            SUB:  alu_result_o = rs1_data_i - rs2_data_i;
            SLL:  alu_result_o = rs1_data_i << rs2_data_i[4:0];
            SRL:  alu_result_o = rs1_data_i >> rs2_data_i[4:0];

            LOAD, STORE: alu_result_o = rs1_data_i + imm_i;  //does not diffrentiate between load and store--> done in mem-access 

            BEQ: begin
                branch_vld_o = 1'b1; //tells fetch module that it is currently executing a branch instruction
                branch_taken_o = (rs1_data_i == rs2_data_i); //branch condition: checks if reg values are equal
                branch_byte_addr = pc_i + imm_i; //byte address, offsets current pc address by an imm value
                branch_trgt_o = branch_byte_addr[11:2];//word address 
            end

            default: ; //NOP-does nothing
        endcase
    end

endmodule