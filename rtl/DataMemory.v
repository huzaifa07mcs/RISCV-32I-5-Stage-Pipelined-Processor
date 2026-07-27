module DataMemory #(
    parameter XLEN  = 32,
    parameter DEPTH = 256
)(
    input                   clk,
    input                   write_enable,
    input  [XLEN-1:0]       address,
    input  [XLEN-1:0]       write_data,
    output [XLEN-1:0]       read_data
);

reg [XLEN-1:0] mem [0:DEPTH-1];
integer i;
initial begin
    for (i = 0; i < DEPTH; i = i + 1)
        mem[i] = 0;
end

always @(posedge clk) begin
    if (write_enable)
        mem[address[7:0]] <= write_data;
end
assign read_data = mem[address[7:0]];

endmodule
