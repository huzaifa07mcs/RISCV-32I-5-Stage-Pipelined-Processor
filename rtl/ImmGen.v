module ImmGen #(
    parameter XLEN = 32
)(
    input      [XLEN-1:0] instruction,
    input      [1:0]      ImmSrc,
    output reg [XLEN-1:0] imm_out
);

    always @(*) begin
        case (ImmSrc)
            2'b00: imm_out = { {20{instruction[31]}}, instruction[31:20] };                                   // I-type
            2'b01: imm_out = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };                // S-type
            2'b10: imm_out = { {19{instruction[31]}}, instruction[31], instruction[7],
                                instruction[30:25], instruction[11:8], 1'b0 };                                  // B-type
            2'b11: imm_out = { {11{instruction[31]}}, instruction[31], instruction[19:12],
                                instruction[20], instruction[30:21], 1'b0 };                                    // J-type
            default: imm_out = 32'b0;
        endcase
    end

endmodule
