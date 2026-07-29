`timescale 1ns / 1ps
module tb_PC;
    parameter XLEN = 32;
    reg clk;
    reg reset;
    reg stall;
    reg [XLEN-1:0] pc_next;
    wire [XLEN-1:0] pc_current;
    reg [XLEN-1:0] pc_before_stall;

    programcounter #(
        .XLEN(XLEN)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset   = 1;
        stall   = 0;
        pc_next = 32'h00000000;
        #10;
        reset = 0;

        pc_next = 32'h00000004;
        #10;
        pc_next = 32'h00000008;
        #10;
        pc_next = 32'h0000000C;
        #10;
        pc_next = 32'h00000100;
        #10;

        pc_before_stall = pc_current;
        stall = 1;
        pc_next = 32'h00000200;
        #10;
        if (pc_current == pc_before_stall)
            $display("PASS: stall held pc_current at %h", pc_current);
        else
            $display("FAIL: expected %h, got %h", pc_before_stall, pc_current);

        pc_next = 32'h00000300;
        #10;
        if (pc_current == pc_before_stall)
            $display("PASS: pc_current still held at %h", pc_current);
        else
            $display("FAIL: expected %h, got %h", pc_before_stall, pc_current);

        stall = 0;
        #10;
        if (pc_current == pc_next)
            $display("PASS: pc_current resumed to %h", pc_current);
        else
            $display("FAIL: expected %h, got %h", pc_next, pc_current);

        $finish;
    end
endmodule
