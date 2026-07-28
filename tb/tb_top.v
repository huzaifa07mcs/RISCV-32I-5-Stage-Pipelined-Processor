`timescale 1ns/1ps
module tb_Top;
reg clk;
reg reset;
wire [31:0] pc_out;
wire [31:0] instr_out;
wire [31:0] alu_result_out;
wire [31:0] writeback_out;
wire [31:0] mem_read_out;
wire [31:0] rs1_data_out;
wire [31:0] rs2_data_out;
wire [31:0] imm_out;
wire RegWrite_out;
wire MemWrite_out;
wire Branch_out;
wire Jump_out;
wire ALUSrc_out;
wire MemtoReg_out;
wire Zero_out;
wire [2:0] ALUControl_out;

Top DUT(
    .clk(clk),
    .reset(reset),

    .pc_out(pc_out),
    .instr_out(instr_out),
    .alu_result_out(alu_result_out),
    .writeback_out(writeback_out),
    .mem_read_out(mem_read_out),

    .rs1_data_out(rs1_data_out),
    .rs2_data_out(rs2_data_out),
    .imm_out(imm_out),

    .RegWrite_out(RegWrite_out),
    .MemWrite_out(MemWrite_out),
    .Branch_out(Branch_out),
    .Jump_out(Jump_out),
    .ALUSrc_out(ALUSrc_out),
    .MemtoReg_out(MemtoReg_out),
    .Zero_out(Zero_out),

    .ALUControl_out(ALUControl_out)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;

    #15;
    reset = 0;

    #500;

    $finish;
end

initial begin
    $monitor(
        "T=%0t PC=%h INST=%h ALU=%h WB=%h MEM=%h RS1=%h RS2=%h IMM=%h RegW=%b MemW=%b Branch=%b Jump=%b ALUSrc=%b MemtoReg=%b Zero=%b ALUCtrl=%b",
        $time,
        pc_out,
        instr_out,
        alu_result_out,
        writeback_out,
        mem_read_out,
        rs1_data_out,
        rs2_data_out,
        imm_out,
        RegWrite_out,
        MemWrite_out,
        Branch_out,
        Jump_out,
        ALUSrc_out,
        MemtoReg_out,
        Zero_out,
        ALUControl_out
    );
end

endmodule
