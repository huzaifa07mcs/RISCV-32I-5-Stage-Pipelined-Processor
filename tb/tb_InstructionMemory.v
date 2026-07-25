`timescale 1ns / 1ps
module tb_InstructionMemory;
    parameter XLEN = 32;
    parameter DEPTH = 256;
    reg [XLEN-1:0] address;
    wire [XLEN-1:0] instruction;
InstructionMemory #(
        .XLEN(XLEN),
        .DEPTH(DEPTH)
    ) DUT (
        .address(address),
        .instruction(instruction)
    );  
initial begin

        address = 32'h00000000;
        #10;
        $display("Address = %h, Instruction = %h", address, instruction);
        
        address = 32'h00000004;
        #10;
        $display("Address = %h, Instruction = %h", address, instruction);

        address = 32'h00000008;
        #10;
        $display("Address = %h, Instruction = %h", address, instruction);

        address = 32'h0000000C;
        #10;
        $display("Address = %h, Instruction = %h", address, instruction);

        address = 32'h00000010;
        #10;
        $display("Address = %h, Instruction = %h", address, instruction);

        $finish;

    end
endmodule
