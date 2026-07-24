`timescale 1ns / 1ps
module tb_PC;

    parameter XLEN = 32;
    reg clk;
    reg reset;
    reg [XLEN-1:0] pc_next;
    wire [XLEN-1:0] pc_current;

    
    programcounter #(
        .XLEN(XLEN)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        reset   = 1;
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

        $finish;
    end

endmodule
