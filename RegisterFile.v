module RegisterFile #(
    parameter XLEN     = 32,
    parameter NUM_REGS = 32
) (
    input clk, reset, RegWrite,
    input  [4:0]      read_addr1, read_addr2, write_addr,
    input  [XLEN-1:0] write_data,
    output [XLEN-1:0] read_data1, read_data2
);

    reg [XLEN-1:0] regfile [0:NUM_REGS-1];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < NUM_REGS; i = i + 1)
                regfile[i] <= {XLEN{1'b0}};
        end
        else if (RegWrite && write_addr != 5'b0) begin
            regfile[write_addr] <= write_data;
        end
    end
assign read_data1 = (read_addr1 == 5'b0) ? {XLEN{1'b0}} : regfile[read_addr1];
assign read_data2 = (read_addr2 == 5'b0) ? {XLEN{1'b0}} : regfile[read_addr2];

endmodule
