`timescale 1ns/1ps
module tb_DataMemory;
parameter XLEN  = 32;
parameter DEPTH = 256;
reg                 clk;
reg                 write_enable;
reg  [XLEN-1:0]     address;
reg  [XLEN-1:0]     write_data;
wire [XLEN-1:0]     read_data;

DataMemory #(XLEN, DEPTH) DUT (
    .clk(clk),
    .write_enable(write_enable),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    write_enable = 0;
    address = 0;
    write_data = 0;

    // Test 1: Write then read
    address = 8;
    write_data = 32'd100;
    write_enable = 1;

    @(posedge clk);
    write_enable <= 0;

    #1;
    if (read_data == 32'd100)
        $display("TEST1 PASS");
    else
        $display("TEST1 FAIL read_data = %0d", read_data);

    #10;

    // Test 2: Overwrite same address
    address = 8;
    write_data = 32'd250;
    write_enable = 1;

    @(posedge clk);
    write_enable <= 0;

    #1;
    if (read_data == 32'd250)
        $display("TEST2 PASS");
    else
        $display("TEST2 FAIL read_data = %0d", read_data);

    #10;

    // Test 3: Write different address
    address = 20;
    write_data = 32'd999;
    write_enable = 1;

    @(posedge clk);
    write_enable <= 0;

    #1;
    if (read_data == 32'd999)
        $display("TEST3 PASS");
    else
        $display("TEST3 FAIL read_data = %0d", read_data);

    #10;

    // Test 4: Write disabled
    address = 20;
    write_data = 32'd1;
    write_enable = 0;

    @(posedge clk);

    #1;
    if (read_data == 32'd999)
        $display("TEST4 PASS");
    else
        $display("TEST4 FAIL read_data = %0d", read_data);

    #10;

    // Test 5: Read unwritten address
    address = 100;

    #1;
    if (read_data == 32'd0)
        $display("TEST5 PASS");
    else
        $display("TEST5 FAIL read_data = %0d", read_data);

    #10;

    // Test 6: Address 0
    address = 0;
    write_data = 32'd11;
    write_enable = 1;

    @(posedge clk);
    write_enable <= 0;

    #1;
    if (read_data == 32'd11)
        $display("TEST6a PASS");
    else
        $display("TEST6a FAIL read_data = %0d", read_data);

    #10;

    // Test 7: Address 255
    address = 255;
    write_data = 32'd22;
    write_enable = 1;

    @(posedge clk);
    write_enable <= 0;

    #1;
    if (read_data == 32'd22)
        $display("TEST7 PASS");
    else
        $display("TEST7 FAIL read_data = %0d", read_data);

    #10;

    $finish;

end

endmodule
