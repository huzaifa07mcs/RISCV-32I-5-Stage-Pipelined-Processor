module MainControl(
    input [6:0] opcode,
    output reg RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump,
    output reg [1:0] ALUOp, ImmSrc
    );
always@(*)
begin
    RegWrite = 1'b0;
    ALUSrc   = 1'b0;
    MemWrite = 1'b0;
    MemtoReg = 1'b0;
    Branch   = 1'b0;
    Jump     = 1'b0;
    ALUOp    = 2'bxx;
    ImmSrc   = 2'bxx;

    case(opcode)
        7'b0110011: begin // R-type
            RegWrite = 1'b1;
            ALUOp    = 2'b10;
        end

        7'b0010011: begin // ADDI
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 2'b11;
            ImmSrc   = 2'b00;
        end

        7'b0000011: begin // LW
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b1;
            ALUOp    = 2'b00;
            ImmSrc   = 2'b00;
        end

        7'b0100011: begin // SW
            MemWrite = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 1'bx;
            ALUOp    = 2'b00;
            ImmSrc   = 2'b01;
        end

        7'b1100011: begin // BEQ/BNE
            MemtoReg = 1'bx;
            Branch   = 1'b1;
            ALUOp    = 2'b01;
            ImmSrc   = 2'b10;
        end

        7'b1101111: begin // JAL
            RegWrite = 1'b1;
            ALUSrc   = 1'bx;
            MemtoReg = 1'bx;
            ALUOp    = 2'bxx;
            Jump     = 1'b1;
            ImmSrc   = 2'b11;
        end

        default: begin // unsupported opcode
            RegWrite = 0; ALUSrc = 0; MemWrite = 0; MemtoReg = 0;
            Branch = 0;   Jump = 0;   ALUOp = 2'b00; ImmSrc = 2'b00;
        end
    endcase
end
endmodule
