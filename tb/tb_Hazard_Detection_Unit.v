`timescale 1ns / 1ps
module tb_Hazard_Detection_Unit;
reg [4:0] ID_EX_rd;
reg       ID_EX_MemToReg;
reg [4:0] IF_ID_rs1;
reg [4:0] IF_ID_rs2;

wire stall;

Hazard_Detection_Unit uut(
    .ID_EX_rd(ID_EX_rd),
    .ID_EX_MemToReg(ID_EX_MemToReg),
    .IF_ID_rs1(IF_ID_rs1),
    .IF_ID_rs2(IF_ID_rs2),
    .stall(stall)
);

initial
begin
    // No hazard
    ID_EX_rd = 5'd5;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd1;
    IF_ID_rs2 = 5'd2;
    #10;

    // Hazard on rs1
    ID_EX_rd = 5'd5;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd5;
    IF_ID_rs2 = 5'd2;
    #10;

    // Hazard on rs2
    ID_EX_rd = 5'd6;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd1;
    IF_ID_rs2 = 5'd6;
    #10;

    // Hazard on both rs1 and rs2
    ID_EX_rd = 5'd7;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd7;
    IF_ID_rs2 = 5'd7;
    #10;

    // Match but MemToReg = 0
    ID_EX_rd = 5'd8;
    ID_EX_MemToReg = 1'b0;
    IF_ID_rs1 = 5'd8;
    IF_ID_rs2 = 5'd2;
    #10;

    // rd = x0
    ID_EX_rd = 5'd0;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd0;
    IF_ID_rs2 = 5'd0;
    #10;

    // Stall after hazard
    ID_EX_rd = 5'd9;
    ID_EX_MemToReg = 1'b1;
    IF_ID_rs1 = 5'd9;
    IF_ID_rs2 = 5'd2;
    #10;

    ID_EX_rd = 5'd9;
    ID_EX_MemToReg = 1'b0;
    IF_ID_rs1 = 5'd9;
    IF_ID_rs2 = 5'd2;
    #10;

    $finish;
end

initial
begin
    $monitor(
    "T=%0t | rd=%0d MemToReg=%b rs1=%0d rs2=%0d | stall=%b",
    $time,
    ID_EX_rd,
    ID_EX_MemToReg,
    IF_ID_rs1,
    IF_ID_rs2,
    stall
    );
end

endmodule
