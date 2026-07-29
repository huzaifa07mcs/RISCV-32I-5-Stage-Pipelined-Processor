module MEM_WB(
    input         clk,
    input         reset,
    input         flush,
    input  [31:0] alu_result_in,
    input  [31:0] mem_read_data_in,
    input  [4:0]  rd_in,
    input  [31:0] pc_plus4_in,
    input         Jump_in,
    input         RegWrite_in,
    input         MemToReg_in,

    output reg [31:0] alu_result_out,
    output reg [31:0] mem_read_data_out,
    output reg [4:0]  rd_out,
    output reg [31:0] pc_plus4_out,
    output reg Jump_out,
    output reg RegWrite_out,
    output reg MemToReg_out
);

always @(posedge clk)
begin
    if (reset)
    begin
        
        alu_result_out    <= 32'b0;
        mem_read_data_out <= 32'b0;
        rd_out            <= 5'b0;
        pc_plus4_out      <= 32'b0;
        Jump_out          <= 1'b0;
        RegWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
    end
    else if (flush)
    begin
        
        alu_result_out    <= 32'b0;
        mem_read_data_out <= 32'b0;
        rd_out            <= 5'b0;
        pc_plus4_out      <= 32'b0;
        Jump_out          <= 1'b0;
        RegWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
    end
    else
    begin
       
        alu_result_out    <= alu_result_in;
        mem_read_data_out <= mem_read_data_in;
        rd_out            <= rd_in;
        pc_plus4_out      <= pc_plus4_in;
        Jump_out          <= Jump_in;
        RegWrite_out      <= RegWrite_in;
        MemToReg_out      <= MemToReg_in;
    end
end

endmodule
