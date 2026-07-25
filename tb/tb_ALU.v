`timescale 1ns / 1ps
module tb_ALU;

    parameter XLEN = 32;

    reg  [XLEN-1:0] operand_A, operand_B;
    reg  [2:0]      ALUControl;
    wire            Zero;
    wire [XLEN-1:0] ALU_result;

    ALU #(
        .XLEN(XLEN)
    ) DUT (
        .operand_A(operand_A),
        .operand_B(operand_B),
        .ALUControl(ALUControl),
        .Zero(Zero),
        .ALU_result(ALU_result)
    );

    initial begin

        // ADD:
        operand_A = 32'd5; operand_B = 32'd3; ALUControl = 3'b000;
        #10;

        // ADD: 
        operand_A = 32'd10; operand_B = -32'd4; ALUControl = 3'b000;
        #10;

        // SUB: 
        operand_A = 32'd10; operand_B = 32'd4; ALUControl = 3'b001;
        #10;

        // SUB: 
        operand_A = 32'd7; operand_B = 32'd7; ALUControl = 3'b001;
        #10;

        // SUB: 
        operand_A = 32'd7; operand_B = 32'd9; ALUControl = 3'b001;
        #10;

        // AND
        operand_A = 32'hF0F0F0F0; operand_B = 32'h0FF00FF0; ALUControl = 3'b010;
        #10;

        // OR
        operand_A = 32'hF0F0F0F0; operand_B = 32'h0FF00FF0; ALUControl = 3'b011;
        #10;

        // XOR
        operand_A = 32'hF0F0F0F0; operand_B = 32'h0FF00FF0; ALUControl = 3'b100;
        #10;

        // SLT: 
        operand_A = 32'd3; operand_B = 32'd8; ALUControl = 3'b101;
        #10;

        // SLT: 
        operand_A = 32'd8; operand_B = 32'd3; ALUControl = 3'b101;
        #10;

        // SLT: 
        operand_A = -32'd5; operand_B = 32'd3; ALUControl = 3'b101;
        #10;

        // SLT:
        operand_A = -32'd10; operand_B = -32'd2; ALUControl = 3'b101;
        #10;

        // SLT: 5 < -3 -> 0
        operand_A = 32'd5; operand_B = -32'd3; ALUControl = 3'b101;
        #10;

        $finish;
    end

endmodule
        
