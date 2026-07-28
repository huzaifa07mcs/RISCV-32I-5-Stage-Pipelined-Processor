module Top(
    input clk,
    input reset,

    output [31:0] pc_out,
    output [31:0] instr_out,
    output [31:0] alu_result_out,
    output [31:0] writeback_out,
    output [31:0] mem_read_out,

    output [31:0] rs1_data_out,
    output [31:0] rs2_data_out,
    output [31:0] imm_out,

    output RegWrite_out,
    output MemWrite_out,
    output Branch_out,
    output Jump_out,
    output ALUSrc_out,
    output MemtoReg_out,
    output Zero_out,

    output [2:0] ALUControl_out
);
Datapath dp(
    .clk(clk),
    .reset(reset),

    .debug_pc(pc_out),
    .debug_instruction(instr_out),
    .debug_alu_result(alu_result_out),
    .debug_writeback(writeback_out),
    .debug_read_data(mem_read_out),

    .debug_read_data1(rs1_data_out),
    .debug_read_data2(rs2_data_out),
    .debug_imm(imm_out),

    .debug_RegWrite(RegWrite_out),
    .debug_MemWrite(MemWrite_out),
    .debug_Branch(Branch_out),
    .debug_Jump(Jump_out),
    .debug_ALUSrc(ALUSrc_out),
    .debug_MemtoReg(MemtoReg_out),
    .debug_Zero(Zero_out),

    .debug_ALUControl(ALUControl_out)
);
endmodule
