import cpu_pkg::*;

//Decodes the instruction by performing field extraction
module decode (
    input  logic [31:0] instr_i,

    output logic [4:0]  rs1_addr_o,
    output logic [4:0]  rs2_addr_o,
    output logic [4:0]  rd_addr_o,
    output logic [31:0] imm_o, //sign-extended immediate decided based on instr type

    output instr_type_e instr_type_o 
);

    //Internal Signals
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [31:0] imm_i_type;
    logic [31:0] imm_s_type;
    logic [31:0] imm_b_type;

    always_comb begin
        opcode = instr_i[6:0];
        rd_addr_o = instr_i[11:7]; //destination register
        funct3 = instr_i[14:12];
        rs1_addr_o = instr_i[19:15];
        rs2_addr_o = instr_i[24:20]; //ignored for I-type
        funct7 = instr_i[31:25]; //ignored for I-type

        
        imm_i_type = {{20{instr_i[31]}}, instr_i[31:20]}; //sign extended I-type immediate

        
        imm_s_type = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]}; //sign extended s-type immediate

        
        imm_b_type = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; //sign extended b-type immediate

        instr_type_o = NOP; //default, falls through in case of no operation
        imm_o = 32'd0; //hardwires to zero so no latches

        case (opcode)
            7'b0110011: begin // R-type
                case (funct3)
                    3'b000: instr_type_o = (funct7 == 7'b0100000) ? SUB : ADD; //ternary for add or sub
                    3'b001: instr_type_o = SLL;
                    3'b101: instr_type_o = SRL;
                    default: instr_type_o = NOP; //if default not provided, will try to latch prev value
                endcase
            end

            7'b0010011: begin // addi
                if (funct3 == 3'b000) begin
                    instr_type_o = ADDI;
                    imm_o = imm_i_type;
                end
            end

            7'b0000011: begin // lw
                if (funct3 == 3'b010) begin
                    instr_type_o = LOAD;
                    imm_o = imm_i_type;
                end
            end

            7'b0100011: begin // sw
                if (funct3 == 3'b010) begin
                    instr_type_o = STORE;
                    imm_o = imm_s_type;
                end
            end

            7'b1100011: begin // beq
                if (funct3 == 3'b000) begin
                    instr_type_o = BEQ;
                    imm_o = imm_b_type;
                end
            end

            7'b1110011: instr_type_o = EBREAK; //instr to make cpu halt

            default: instr_type_o = NOP; //for safety 
        endcase
    end

endmodule