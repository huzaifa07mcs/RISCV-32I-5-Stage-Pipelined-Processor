`timescale 1ns / 1ps
module tb_MEM_WB;
reg clk;
reg reset;
reg flush;
reg [31:0] alu_result_in;
reg [31:0] mem_read_data_in;
reg [4:0]  rd_in;
reg [31:0] pc_plus4_in;
reg Jump_in;
reg RegWrite_in;
reg MemToReg_in;

wire [31:0] alu_result_out;
wire [31:0] mem_read_data_out;
wire [4:0]  rd_out;
wire [31:0] pc_plus4_out;
wire Jump_out;
wire RegWrite_out;
wire MemToReg_out;

MEM_WB uut(
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .alu_result_in(alu_result_in),
    .mem_read_data_in(mem_read_data_in),
    .rd_in(rd_in),
    .pc_plus4_in(pc_plus4_in),
    .Jump_in(Jump_in),
    .RegWrite_in(RegWrite_in),
    .MemToReg_in(MemToReg_in),

    .alu_result_out(alu_result_out),
    .mem_read_data_out(mem_read_data_out),
    .rd_out(rd_out),
    .pc_plus4_out(pc_plus4_out),
    .Jump_out(Jump_out),
    .RegWrite_out(RegWrite_out),
    .MemToReg_out(MemToReg_out)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 0;
    flush = 0;
    alu_result_in    = 0;
    mem_read_data_in = 0;
    rd_in            = 0;
    pc_plus4_in      = 0;
    Jump_in          = 0;
    RegWrite_in      = 0;
    MemToReg_in      = 0;

    
    reset = 1;
    #10;
    reset = 0;

    // R-type
    alu_result_in    = 32'h11111111;
    mem_read_data_in = 32'hAAAAAAAA;
    rd_in            = 5'd5;
    pc_plus4_in      = 32'h00001004;
    Jump_in          = 0;
    RegWrite_in      = 1;
    MemToReg_in      = 0;

    #10;

    // LW
    alu_result_in    = 32'h22222222;
    mem_read_data_in = 32'hBBBBBBBB;
    rd_in            = 5'd8;
    pc_plus4_in      = 32'h00002004;
    Jump_in          = 0;
    RegWrite_in      = 1;
    MemToReg_in      = 1;

    #10;

    // JAL
    alu_result_in    = 32'h33333333;
    mem_read_data_in = 32'hCCCCCCCC;
    rd_in            = 5'd1;
    pc_plus4_in      = 32'h00003004;
    Jump_in          = 1;
    RegWrite_in      = 1;
    MemToReg_in      = 0;

    #10;

    // Flush
    flush = 1;
    #10;
    flush = 0;

    // Consecutive instruction 1
    alu_result_in    = 32'h44444444;
    mem_read_data_in = 32'hDDDDDDDD;
    rd_in            = 5'd10;
    pc_plus4_in      = 32'h00004004;
    Jump_in          = 0;
    RegWrite_in      = 1;
    MemToReg_in      = 0;

    #10;

    // Consecutive instruction 2
    alu_result_in    = 32'h55555555;
    mem_read_data_in = 32'hEEEEEEEE;
    rd_in            = 5'd12;
    pc_plus4_in      = 32'h00005004;
    Jump_in          = 0;
    RegWrite_in      = 1;
    MemToReg_in      = 1;

    #10;

    // Reset again
    reset = 1;
    #10;
    reset = 0;

    alu_result_in    = 0;
    mem_read_data_in = 0;
    rd_in            = 0;
    pc_plus4_in      = 0;
    Jump_in          = 0;
    RegWrite_in      = 0;
    MemToReg_in      = 0;

    #10;

    $finish;
end

initial
begin
    $monitor(
        "T=%0t | Rst=%b Fl=%b | ALU=%h MEM=%h RD=%0d PC4=%h J=%b RW=%b M2R=%b",
        $time,
        reset,
        flush,
        alu_result_out,
        mem_read_data_out,
        rd_out,
        pc_plus4_out,
        Jump_out,
        RegWrite_out,
        MemToReg_out
    );
end
endmodule
