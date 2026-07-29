`timescale 1ns / 1ps
module tb_EX_MEM;
reg clk;
reg reset;
reg flush;
reg [31:0] alu_result_in;
reg [31:0] rs2_data_in;
reg [4:0]  rd_in;
reg [31:0] pc_plus4_in;
reg Jump_in;
reg MemWrite_in;
reg RegWrite_in;
reg MemToReg_in;

wire [31:0] alu_result_out;
wire [31:0] rs2_data_out;
wire [4:0]  rd_out;
wire [31:0] pc_plus4_out;
wire Jump_out;
wire MemWrite_out;
wire RegWrite_out;
wire MemToReg_out;

EX_MEM dut(
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .alu_result_in(alu_result_in),
    .rs2_data_in(rs2_data_in),
    .rd_in(rd_in),
    .pc_plus4_in(pc_plus4_in),
    .Jump_in(Jump_in),
    .MemWrite_in(MemWrite_in),
    .RegWrite_in(RegWrite_in),
    .MemToReg_in(MemToReg_in),

    .alu_result_out(alu_result_out),
    .rs2_data_out(rs2_data_out),
    .rd_out(rd_out),
    .pc_plus4_out(pc_plus4_out),
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
    alu_result_in = 0;
    rs2_data_in   = 0;
    rd_in         = 0;
    pc_plus4_in   = 0;
    Jump_in       = 0;
    MemWrite_in   = 0;
    RegWrite_in   = 0;
    MemToReg_in   = 0;

    // Reset
    reset = 1;
    #10;
    reset = 0;

    // Normal transfer
    alu_result_in = 32'h11111111;
    rs2_data_in   = 32'hAAAAAAAA;
    rd_in         = 5'd5;
    pc_plus4_in   = 32'h00001004;

    Jump_in       = 0;
    MemWrite_in   = 1;
    RegWrite_in   = 1;
    MemToReg_in   = 0;

    #10;

    //  JAL
    alu_result_in = 32'h22222222;
    rs2_data_in   = 32'hBBBBBBBB;
    rd_in         = 5'd1;
    pc_plus4_in   = 32'h00002004;

    Jump_in       = 1;
    MemWrite_in   = 0;
    RegWrite_in   = 1;
    MemToReg_in   = 0;

    #10;

    //Load
    alu_result_in = 32'h33333333;
    rs2_data_in   = 32'hCCCCCCCC;
    rd_in         = 5'd8;
    pc_plus4_in   = 32'h00003004;

    Jump_in       = 0;
    MemWrite_in   = 0;
    RegWrite_in   = 1;
    MemToReg_in   = 1;

    #10;

    // Flush
    flush = 1;
    #10;
    flush = 0;

    // Consecutive instruction 1
    alu_result_in = 32'h44444444;
    rs2_data_in   = 32'hDDDDDDDD;
    rd_in         = 5'd10;
    pc_plus4_in   = 32'h00004004;

    Jump_in       = 0;
    MemWrite_in   = 1;
    RegWrite_in   = 1;
    MemToReg_in   = 0;

    #10;

    // Consecutive instruction 2
    alu_result_in = 32'h55555555;
    rs2_data_in   = 32'hEEEEEEEE;
    rd_in         = 5'd12;
    pc_plus4_in   = 32'h00005004;

    Jump_in       = 0;
    MemWrite_in   = 0;
    RegWrite_in   = 1;
    MemToReg_in   = 1;

    #10;

    // Reset again
    reset = 1;
    #10;
    reset = 0;

    #10;
    $finish;
end

initial
begin
    $monitor(
        "T=%0t | Rst=%b Fl=%b | ALU=%h RS2=%h RD=%d PC4=%h J=%b MW=%b RW=%b M2R=%b",
        $time,
        reset,
        flush,
        alu_result_out,
        rs2_data_out,
        rd_out,
        pc_plus4_out,
        Jump_out,
        MemWrite_out,
        RegWrite_out,
        MemToReg_out
    );
end
endmodule
