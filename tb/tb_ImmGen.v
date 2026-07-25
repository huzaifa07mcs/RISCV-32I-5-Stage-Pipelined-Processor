`timescale 1ns / 1ps
module tb_ImmGen;

    parameter XLEN = 32;

    reg  [XLEN-1:0] instruction;
    reg  [1:0]      ImmSrc;
    wire [XLEN-1:0] imm_out;

    ImmGen #(
        .XLEN(XLEN)
    ) DUT (
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .imm_out(imm_out)
    );

    initial begin

        // ---- Test 1: I-type
        instruction = 32'hFFB00000;
        ImmSrc      = 2'b00;
        #10;
        
        // ---- Test 2: S-type
        instruction = 32'h00000500;
        ImmSrc      = 2'b01;
        #10;
       
        // ---- Test 3: B-type
        instruction = 32'h00000400;
        ImmSrc      = 2'b10;
        #10;
       
        // ---- Test 4: J-type
        instruction = 32'h01000000;
        ImmSrc      = 2'b11;
        #10;
       
        // ---- Test 5: default
        instruction = 32'hFFFFFFFF;
        ImmSrc      = 2'bxx;
        #10;
        
        $finish;
    end

endmodule
