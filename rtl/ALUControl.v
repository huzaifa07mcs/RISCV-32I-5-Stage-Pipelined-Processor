module ALU_Control(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7_5,
    output reg [2:0] ALUControl
    );
always@(*)
begin 
case(ALUOp)
2'b00: ALUControl=3'b000;
2'b01: ALUControl=3'b001;
2'b11: ALUControl=3'b000;
2'b10: begin
case({funct7_5,funct3})
            4'b0_000: ALUControl = 3'b000;         // ADD
            4'b1_000: ALUControl = 3'b001;         // SUB
            4'b0_111: ALUControl = 3'b010;         // AND
            4'b0_110: ALUControl = 3'b011;         // OR
            4'b0_100: ALUControl = 3'b100;         // XOR
            4'b0_010: ALUControl = 3'b101;         // SLT
            default:  ALUControl = 3'b000;
            endcase
end
endcase
end
endmodule
