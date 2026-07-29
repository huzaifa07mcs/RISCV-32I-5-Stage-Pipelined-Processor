`timescale 1ns / 1ps
module tb_Forwarding_Unit;
reg [4:0] ID_EX_rs1;
reg [4:0] ID_EX_rs2;
reg [4:0] EX_MEM_rd;
reg       EX_MEM_RegWrite;
reg [4:0] MEM_WB_rd;
reg       MEM_WB_RegWrite;

wire [1:0] ForwardA;
wire [1:0] ForwardB;

Forwarding_Unit uut(
    .ID_EX_rs1(ID_EX_rs1),
    .ID_EX_rs2(ID_EX_rs2),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_rd(MEM_WB_rd),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),

    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

initial
begin
    // No hazard
    ID_EX_rs1 = 5'd1;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd3;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd4;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // EX/MEM hazard on rs1
    ID_EX_rs1 = 5'd5;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd5;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd7;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // EX/MEM hazard on rs2
    ID_EX_rs1 = 5'd1;
    ID_EX_rs2 = 5'd8;

    EX_MEM_rd = 5'd8;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd9;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // EX/MEM hazard on both
    ID_EX_rs1 = 5'd10;
    ID_EX_rs2 = 5'd10;

    EX_MEM_rd = 5'd10;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd11;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // MEM/WB hazard on rs1
    ID_EX_rs1 = 5'd12;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd3;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd12;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // MEM/WB hazard on rs2
    ID_EX_rs1 = 5'd1;
    ID_EX_rs2 = 5'd13;

    EX_MEM_rd = 5'd4;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd13;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // Priority 
    ID_EX_rs1 = 5'd14;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd14;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd14;
    MEM_WB_RegWrite = 1'b1;

    #10;

    // EX/MEM RegWrite = 0
    ID_EX_rs1 = 5'd15;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd15;
    EX_MEM_RegWrite = 1'b0;

    MEM_WB_rd = 5'd3;
    MEM_WB_RegWrite = 1'b0;

    #10;

    // MEM/WB RegWrite = 0
    ID_EX_rs1 = 5'd16;
    ID_EX_rs2 = 5'd2;

    EX_MEM_rd = 5'd3;
    EX_MEM_RegWrite = 1'b0;

    MEM_WB_rd = 5'd16;
    MEM_WB_RegWrite = 1'b0;

    #10;

    // EX/MEM rd = x0
    ID_EX_rs1 = 5'd0;
    ID_EX_rs2 = 5'd0;

    EX_MEM_rd = 5'd0;
    EX_MEM_RegWrite = 1'b1;

    MEM_WB_rd = 5'd4;
    MEM_WB_RegWrite = 1'b0;

    #10;

    // MEM/WB rd = x0
    ID_EX_rs1 = 5'd0;
    ID_EX_rs2 = 5'd0;

    EX_MEM_rd = 5'd3;
    EX_MEM_RegWrite = 1'b0;

    MEM_WB_rd = 5'd0;
    MEM_WB_RegWrite = 1'b1;

    #10;

    $finish;
end

initial
begin
    $monitor(
    "T=%0t | rs1=%0d rs2=%0d | EX(rd=%0d RW=%b) MEM(rd=%0d RW=%b) | ForwardA=%b ForwardB=%b",
    $time,
    ID_EX_rs1,
    ID_EX_rs2,
    EX_MEM_rd,
    EX_MEM_RegWrite,
    MEM_WB_rd,
    MEM_WB_RegWrite,
    ForwardA,
    ForwardB
    );
end

endmodule
