module IF_ID(
    input reset,clk,flush,stall,
    input [31:0] pc_current_in, pc_plus4_in, instruction_in,
    output reg [31:0] pc_current_out, pc_plus4_out, instruction_out
    );
always@(posedge clk)
    
if(reset) begin
pc_current_out <= 32'b0;
pc_plus4_out <= 32'b0;
instruction_out <= 32'b0;
end
    
else if (flush)
begin
pc_current_out <= 32'b0;
pc_plus4_out <= 32'b0;
instruction_out <= 32'b0;
end
    
else if (stall)
begin
pc_current_out <= pc_current_out;
pc_plus4_out <= pc_plus4_out;
instruction_out <= instruction_out;
end
    
else
begin
pc_current_out <= pc_current_in;
pc_plus4_out <= pc_plus4_in;
instruction_out <= instruction_in;
end
endmodule
