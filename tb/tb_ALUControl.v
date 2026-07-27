`timescale 1ns / 1ps
module tb_ALU_Control;

reg  [1:0] ALUOp;
reg  [2:0] funct3;
reg        funct7_5;
wire [2:0] ALUControl;

ALU_Control dut(
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .ALUControl(ALUControl)
);

task check(input [2:0] expected);
begin
    #10;
    if (ALUControl == expected)
        $display("PASS: ALUOp=%b funct3=%b funct7_5=%b -> ALUControl=%b", ALUOp, funct3, funct7_5, ALUControl);
    else
        $display("FAIL: ALUOp=%b funct3=%b funct7_5=%b -> expected %b, got %b", ALUOp, funct3, funct7_5, expected, ALUControl);
end
endtask

initial begin
    ALUOp=2'b00; funct3=3'b000; funct7_5=1'b0; check(3'b000);
    ALUOp=2'b11; funct3=3'b000; funct7_5=1'b0; check(3'b000);
    ALUOp=2'b01; funct3=3'b000; funct7_5=1'b0; check(3'b001);
    ALUOp=2'b10; funct3=3'b000; funct7_5=1'b0; check(3'b000);
    ALUOp=2'b10; funct3=3'b000; funct7_5=1'b1; check(3'b001);
    ALUOp=2'b10; funct3=3'b111; funct7_5=1'b0; check(3'b010);
    ALUOp=2'b10; funct3=3'b110; funct7_5=1'b0; check(3'b011);
    ALUOp=2'b10; funct3=3'b100; funct7_5=1'b0; check(3'b100);
    ALUOp=2'b10; funct3=3'b010; funct7_5=1'b0; check(3'b101);
    ALUOp=2'b10; funct3=3'b011; funct7_5=1'b0; check(3'b000);
    ALUOp=2'b00; funct3=3'b111; funct7_5=1'b1; check(3'b000);

    $finish;
end
endmodule
