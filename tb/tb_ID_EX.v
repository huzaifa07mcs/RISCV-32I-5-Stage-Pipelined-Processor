`timescale 1ns/1ps

module tb_ID_EX;

reg clk;
reg reset;
reg flush;

reg [31:0] pc_in;
reg [31:0] pc_plus4_in;
reg [31:0] rs1_data_in;
reg [31:0] rs2_data_in;
reg [31:0] imm_in;

reg [4:0] rs1_in;
reg [4:0] rs2_in;
reg [4:0] rd_in;

reg [2:0] funct3_in;
reg funct7_5_in;

reg ALUSrc_in;
reg [2:0] ALUControl_in;
reg Branch_in;
reg Jump_in;
reg MemWrite_in;
reg RegWrite_in;
reg MemToReg_in;

wire [31:0] pc_out;
wire [31:0] pc_plus4_out;
wire [31:0] rs1_data_out;
wire [31:0] rs2_data_out;
wire [31:0] imm_out;

wire [4:0] rs1_out;
wire [4:0] rs2_out;
wire [4:0] rd_out;

wire [2:0] funct3_out;
wire funct7_5_out;

wire ALUSrc_out;
wire [2:0] ALUControl_out;
wire Branch_out;
wire Jump_out;
wire MemWrite_out;
wire RegWrite_out;
wire MemToReg_out;

ID_EX dut(
    .clk(clk),
    .reset(reset),
    .flush(flush),

    .pc_in(pc_in),
    .pc_plus4_in(pc_plus4_in),
    .rs1_data_in(rs1_data_in),
    .rs2_data_in(rs2_data_in),
    .imm_in(imm_in),

    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .rd_in(rd_in),

    .funct3_in(funct3_in),
    .funct7_5_in(funct7_5_in),

    .ALUSrc_in(ALUSrc_in),
    .ALUControl_in(ALUControl_in),
    .Branch_in(Branch_in),
    .Jump_in(Jump_in),
    .MemWrite_in(MemWrite_in),
    .RegWrite_in(RegWrite_in),
    .MemToReg_in(MemToReg_in),

    .pc_out(pc_out),
    .pc_plus4_out(pc_plus4_out),
    .rs1_data_out(rs1_data_out),
    .rs2_data_out(rs2_data_out),
    .imm_out(imm_out),

    .rs1_out(rs1_out),
    .rs2_out(rs2_out),
    .rd_out(rd_out),

    .funct3_out(funct3_out),
    .funct7_5_out(funct7_5_out),

    .ALUSrc_out(ALUSrc_out),
    .ALUControl_out(ALUControl_out),
    .Branch_out(Branch_out),
    .Jump_out(Jump_out),
    .MemWrite_out(MemWrite_out),
    .RegWrite_out(RegWrite_out),
    .MemToReg_out(MemToReg_out)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 0;
    flush = 0;

    pc_in = 0;
    pc_plus4_in = 0;
    rs1_data_in = 0;
    rs2_data_in = 0;
    imm_in = 0;

    rs1_in = 0;
    rs2_in = 0;
    rd_in = 0;

    funct3_in = 0;
    funct7_5_in = 0;

    ALUSrc_in = 0;
    ALUControl_in = 0;
    Branch_in = 0;
    Jump_in = 0;
    MemWrite_in = 0;
    RegWrite_in = 0;
    MemToReg_in = 0;

    $monitor("Time=%0t | PC=%h | RS1=%h | RS2=%h | IMM=%h | RD=%d | RegWrite=%b",
    $time,
    pc_out,
    rs1_data_out,
    rs2_data_out,
    imm_out,
    rd_out,
    RegWrite_out);

    #10;

    reset = 1;
    #10;
    reset = 0;

    pc_in = 32'h00000010;
    pc_plus4_in = 32'h00000014;

    rs1_data_in = 32'h00000005;
    rs2_data_in = 32'h00000003;
    imm_in = 32'h00000000;

    rs1_in = 5'd1;
    rs2_in = 5'd2;
    rd_in = 5'd5;

    funct3_in = 3'b000;
    funct7_5_in = 1'b0;

    ALUSrc_in = 0;
    ALUControl_in = 3'b010;

    Branch_in = 0;
    Jump_in = 0;
    MemWrite_in = 0;
    RegWrite_in = 1;
    MemToReg_in = 0;

    #10;

    flush = 1;
    #10;
    flush = 0;

    #20;

    $finish;
end

endmodule
