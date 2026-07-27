`timescale 1ns / 1ps
module tb_MainControl;

reg  [6:0] opcode;
wire RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump;
wire [1:0] ALUOp, ImmSrc;

MainControl dut(
    .opcode(opcode),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .Branch(Branch),
    .Jump(Jump),
    .ALUOp(ALUOp),
    .ImmSrc(ImmSrc)
);

initial begin
    // R-type
    opcode = 7'b0110011;
    #10;
    if (RegWrite===1'b1 && ALUSrc===1'b0 && MemWrite===1'b0 && Branch===1'b0 && Jump===1'b0 && ALUOp===2'b10)
        $display("PASS: R-type opcode=%b", opcode);
    else
        $display("FAIL: R-type opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b Branch=%b Jump=%b ALUOp=%b", opcode, RegWrite, ALUSrc, MemWrite, Branch, Jump, ALUOp);

    // ADDI
    opcode = 7'b0010011;
    #10;
    if (RegWrite===1'b1 && ALUSrc===1'b1 && MemWrite===1'b0 && ALUOp===2'b11 && ImmSrc===2'b00)
        $display("PASS: ADDI opcode=%b", opcode);
    else
        $display("FAIL: ADDI opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b ALUOp=%b ImmSrc=%b", opcode, RegWrite, ALUSrc, MemWrite, ALUOp, ImmSrc);

    // LW
    opcode = 7'b0000011;
    #10;
    if (RegWrite===1'b1 && ALUSrc===1'b1 && MemWrite===1'b0 && MemtoReg===1'b1 && ALUOp===2'b00 && ImmSrc===2'b00)
        $display("PASS: LW opcode=%b", opcode);
    else
        $display("FAIL: LW opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b MemtoReg=%b ALUOp=%b ImmSrc=%b", opcode, RegWrite, ALUSrc, MemWrite, MemtoReg, ALUOp, ImmSrc);

    // SW
    opcode = 7'b0100011;
    #10;
    if (RegWrite===1'b0 && ALUSrc===1'b1 && MemWrite===1'b1 && ALUOp===2'b00 && ImmSrc===2'b01)
        $display("PASS: SW opcode=%b", opcode);
    else
        $display("FAIL: SW opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b ALUOp=%b ImmSrc=%b", opcode, RegWrite, ALUSrc, MemWrite, ALUOp, ImmSrc);

    // BEQ/BNE
    opcode = 7'b1100011;
    #10;
    if (RegWrite===1'b0 && ALUSrc===1'b0 && MemWrite===1'b0 && Branch===1'b1 && ALUOp===2'b01 && ImmSrc===2'b10)
        $display("PASS: BEQ/BNE opcode=%b", opcode);
    else
        $display("FAIL: BEQ/BNE opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b Branch=%b ALUOp=%b ImmSrc=%b", opcode, RegWrite, ALUSrc, MemWrite, Branch, ALUOp, ImmSrc);

    // JAL
    opcode = 7'b1101111;
    #10;
    if (RegWrite===1'b1 && MemWrite===1'b0 && Jump===1'b1 && ImmSrc===2'b11)
        $display("PASS: JAL opcode=%b", opcode);
    else
        $display("FAIL: JAL opcode=%b -> RegWrite=%b MemWrite=%b Jump=%b ImmSrc=%b", opcode, RegWrite, MemWrite, Jump, ImmSrc);

    // Invalid/default opcode
    opcode = 7'b1111111;
    #10;
    if (RegWrite===1'b0 && ALUSrc===1'b0 && MemWrite===1'b0 && Branch===1'b0 && Jump===1'b0 && ALUOp===2'b00 && ImmSrc===2'b00)
        $display("PASS: invalid opcode=%b", opcode);
    else
        $display("FAIL: invalid opcode=%b -> RegWrite=%b ALUSrc=%b MemWrite=%b Branch=%b Jump=%b ALUOp=%b ImmSrc=%b", opcode, RegWrite, ALUSrc, MemWrite, Branch, Jump, ALUOp, ImmSrc);

    $finish;
end
endmodule
