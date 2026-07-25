`timescale 1ns / 1ps
module tb_RegisterFile;

    parameter XLEN     = 32;
    parameter NUM_REGS = 32;

    reg clk, reset, RegWrite;
    reg  [4:0]      read_addr1, read_addr2, write_addr;
    reg  [XLEN-1:0] write_data;
    wire [XLEN-1:0] read_data1, read_data2;

    RegisterFile #(
        .XLEN(XLEN),
        .NUM_REGS(NUM_REGS)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // ---- Test 1: Reset ----
        reset = 1; RegWrite = 0;
        read_addr1 = 0; read_addr2 = 0; write_addr = 0; write_data = 0;
        @(posedge clk);
        #1;
        $display("TEST 1 - After Reset: regfile[10] should be 0 -> read_data1 = %h", read_data1);
        reset = 0;

        // ---- Test 2: Write to x21 (5'b10101), then read it back ----
        @(negedge clk);
        RegWrite   = 1;
        write_addr = 5'b10101;
        write_data = 32'h10ABC120;
        @(posedge clk); // write happens here
        #1;
        RegWrite   = 0;
        read_addr1 = 5'b10101;
        #1;
        $display("TEST 2 - Write x21=0x10ABC120, Read x21: read_data1 = %h (expected 10ABC120)", read_data1);

        // ---- Test 3: Write to x20 (5'b10100), read both x20 and x21 simultaneously ----
        @(negedge clk);
        RegWrite   = 1;
        write_addr = 5'b10100;
        write_data = 32'h10FBC120;
        @(posedge clk);
        #1;
        RegWrite   = 0;
        read_addr1 = 5'b10100;
        read_addr2 = 5'b10101;
        #1;
        $display("TEST 3 - Read x20 & x21: read_data1 = %h (expected 10FBC120), read_data2 = %h (expected 10ABC120)",
                   read_data1, read_data2);

        // ---- Test 4: Attempt write to x0, confirm it stays 0 ----
        @(negedge clk);
        RegWrite   = 1;
        write_addr = 5'b00000;
        write_data = 32'hFFFFFFFF;
        @(posedge clk);
        #1;
        RegWrite   = 0;
        read_addr1 = 5'b00000;
        #1;
        $display("TEST 4 - Write attempt to x0: read_data1 = %h (expected 00000000)", read_data1);

        // ---- Test 5: RegWrite=0, confirm no write occurs ----
        @(negedge clk);
        RegWrite   = 0;
        write_addr = 5'b10101;
        write_data = 32'hDEADBEEF;
        @(posedge clk);
        #1;
        read_addr1 = 5'b10101;
        #1;
        $display("TEST 5 - RegWrite=0, write ignored: read_data1 = %h (expected 10ABC120, unchanged)", read_data1);

        $display("All tests completed.");
        $finish;
    end

endmodule
