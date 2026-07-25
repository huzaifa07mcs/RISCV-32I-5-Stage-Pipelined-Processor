module ALU #(
    parameter XLEN = 32
)(
    input      [XLEN-1:0] operand_A, operand_B,
    input      [2:0]      ALUControl,
    output reg             Zero,
    output reg [XLEN-1:0] ALU_result
);

    always @(*) begin
        case (ALUControl)
            3'b000: ALU_result = operand_A + operand_B;                                          // ADD
            3'b001: ALU_result = operand_A - operand_B;                                          // SUB
            3'b010: ALU_result = operand_A & operand_B;                                          // AND
            3'b011: ALU_result = operand_A | operand_B;                                          // OR
            3'b100: ALU_result = operand_A ^ operand_B;                                          // XOR
            3'b101: ALU_result = ($signed(operand_A) < $signed(operand_B)) ? 32'd1 : 32'd0;       // SLT
            default: ALU_result = 32'b0;
        endcase

        Zero = (ALU_result == 32'b0) ? 1'b1 : 1'b0;
    end

endmodule
