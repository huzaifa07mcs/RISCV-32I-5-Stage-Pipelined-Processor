`timescale 1ns / 1ps
module tb_IF_ID;
reg clk;
reg reset;
reg flush;
reg stall;
reg [31:0] pc_current_in;
reg [31:0] pc_plus4_in;
reg [31:0] instruction_in;
wire [31:0] pc_current_out;
wire [31:0] pc_plus4_out;
wire [31:0] instruction_out;

IF_ID dut(
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .stall(stall),

    .pc_current_in(pc_current_in),
    .pc_plus4_in(pc_plus4_in),
    .instruction_in(instruction_in),

    .pc_current_out(pc_current_out),
    .pc_plus4_out(pc_plus4_out),
    .instruction_out(instruction_out)
);


always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 0;
    flush = 0;
    stall = 0;

    pc_current_in = 32'b0;
    pc_plus4_in = 32'b0;
    instruction_in = 32'b0;

    $monitor("Time=%0t | reset=%b stall=%b flush=%b | PC=%h PC4=%h INST=%h",
              $time,
              reset,
              stall,
              flush,
              pc_current_out,
              pc_plus4_out,
              instruction_out);


  
    //  Reset
    #10;
    reset = 1;
    #10;
    reset = 0;

     //  Normal Operation
    pc_current_in = 32'h00000010;
    pc_plus4_in   = 32'h00000014;
    instruction_in = 32'h00A00513;  
    #10;
  
     //  Stall
    stall = 1;

    pc_current_in = 32'h00000020;
    pc_plus4_in   = 32'h00000024;
    instruction_in = 32'h00100093;

    #10;
   stall = 0;

    #10;

  //  Flush
    flush = 1;
    #10;
    flush = 0;   
    #20;
    $finish;

end
endmodule
