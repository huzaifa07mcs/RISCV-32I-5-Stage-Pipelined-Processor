module programcounter #(
    parameter XLEN = 32
)(
    input clk,
    input reset,
    input stall,
    input [XLEN-1:0] pc_next,
    output reg [XLEN-1:0] pc_current
);
always @(posedge clk) begin
    if (reset)
        pc_current <= {XLEN{1'b0}};
    else if (stall)
        pc_current <= pc_current;   // hold 
    else
        pc_current <= pc_next;
end
endmodule
