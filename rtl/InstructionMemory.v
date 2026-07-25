module InstructionMemory #(
    parameter XLEN  = 32,
    parameter DEPTH = 256
)(
    input  [XLEN-1:0] address,
    output [XLEN-1:0] instruction
);

    reg [XLEN-1:0] memory [0:DEPTH-1];
    initial begin
        $readmemh("program.mem", memory);
    end
    
    assign instruction = memory[address[31:2]];

endmodule
