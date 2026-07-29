`timescale 1ns / 1ps

module tb_riscv_top;

    parameter CLK_PERIOD    = 10;
    parameter MAX_CYCLES    = 500;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_if_id_pc;
    wire [31:0] debug_if_id_instruction;
    wire [31:0] debug_read_data1;
    wire [31:0] debug_read_data2;
    wire [31:0] debug_imm;
    wire [4:0]  debug_id_rs1;
    wire [4:0]  debug_id_rs2;
    wire [4:0]  debug_id_rd;
    wire [31:0] debug_id_ex_pc;
    wire [4:0]  debug_id_ex_rs1;
    wire [4:0]  debug_id_ex_rs2;
    wire [4:0]  debug_id_ex_rd;
    wire [31:0] debug_alu_result;
    wire [2:0]  debug_ALUControl;
    wire        debug_Zero;
    wire [1:0]  debug_ForwardA;
    wire [1:0]  debug_ForwardB;
    wire        debug_stall;
    wire        debug_flush;
    wire [31:0] debug_ex_mem_alu_result;
    wire [4:0]  debug_ex_mem_rd;
    wire        debug_ex_mem_RegWrite;
    wire        debug_ex_mem_MemWrite;
    wire [31:0] debug_read_data;
    wire [31:0] debug_mem_wb_alu_result;
    wire [31:0] debug_mem_wb_mem_data;
    wire [4:0]  debug_mem_wb_rd;
    wire [31:0] debug_writeback;
    wire        debug_mem_wb_RegWrite;
    wire        debug_RegWrite;
    wire        debug_MemWrite;
    wire        debug_Branch;
    wire        debug_Jump;
    wire        debug_ALUSrc;
    wire        debug_MemtoReg;

    integer cycle_count;
    integer reg_writes_count;
    integer mem_writes_count;
    integer stall_count;
    integer flush_count;
    integer branch_count;
    reg     metrics_printed;

    // expected final architectural state, hand-traced from the program
    reg [31:0] expected_reg [1:31];
    reg [31:0] expected_mem [0:8];
    integer i;
    integer errors;

    initial begin
        expected_reg[1]  = 32'd183;
        expected_reg[2]  = 32'd148;
        expected_reg[3]  = 32'd20;
        expected_reg[4]  = 32'd29;
        expected_reg[5]  = 32'd170;
        expected_reg[6]  = 32'd0;
        expected_reg[7]  = 32'd35;
        expected_reg[8]  = 32'd40;
        expected_reg[9]  = 32'd292;
        expected_reg[10] = 32'd152;
        expected_reg[11] = 32'd0;
        expected_reg[12] = 32'd0;
        expected_reg[13] = 32'd0;
        expected_reg[14] = 32'd0;
        expected_reg[15] = 32'hFFFFFF68;
        expected_reg[16] = 32'hFFFFFF68;
        expected_reg[17] = 32'hFFFFFE4C;
        expected_reg[18] = 32'hFFFFFE6C;
        expected_reg[19] = 32'd32;
        expected_reg[20] = 32'd32;
        expected_reg[21] = 32'hFFFFFF76;
        expected_reg[22] = 32'hFFFFFF6B;
        expected_reg[23] = 32'hFFFFFF7F;
        expected_reg[24] = 32'd20;
        expected_reg[25] = 32'd1;
        expected_reg[26] = 32'd1;
        expected_reg[27] = 32'd2;
        expected_reg[28] = 32'd26;
        expected_reg[29] = 32'd26;
        expected_reg[30] = 32'd130;
        expected_reg[31] = 32'd143;

        expected_mem[0] = 32'd0;
        expected_mem[1] = 32'd5;
        expected_mem[2] = 32'hFFFFFFFB;
        expected_mem[3] = 32'd0;
        expected_mem[4] = 32'd1;
        expected_mem[5] = 32'd26;
        expected_mem[6] = 32'd0;
        expected_mem[7] = 32'hFFFFFF68;
        expected_mem[8] = 32'd1;
    end

    // clock
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // DUT
    riscv_top uut (
        .clk                     (clk),
        .reset                   (reset),
        .debug_pc                (debug_pc),
        .debug_instruction       (debug_instruction),
        .debug_if_id_pc          (debug_if_id_pc),
        .debug_if_id_instruction (debug_if_id_instruction),
        .debug_read_data1        (debug_read_data1),
        .debug_read_data2        (debug_read_data2),
        .debug_imm               (debug_imm),
        .debug_id_rs1            (debug_id_rs1),
        .debug_id_rs2            (debug_id_rs2),
        .debug_id_rd             (debug_id_rd),
        .debug_id_ex_pc          (debug_id_ex_pc),
        .debug_id_ex_rs1         (debug_id_ex_rs1),
        .debug_id_ex_rs2         (debug_id_ex_rs2),
        .debug_id_ex_rd          (debug_id_ex_rd),
        .debug_alu_result        (debug_alu_result),
        .debug_ALUControl        (debug_ALUControl),
        .debug_Zero              (debug_Zero),
        .debug_ForwardA          (debug_ForwardA),
        .debug_ForwardB          (debug_ForwardB),
        .debug_stall             (debug_stall),
        .debug_flush             (debug_flush),
        .debug_ex_mem_alu_result (debug_ex_mem_alu_result),
        .debug_ex_mem_rd         (debug_ex_mem_rd),
        .debug_ex_mem_RegWrite   (debug_ex_mem_RegWrite),
        .debug_ex_mem_MemWrite   (debug_ex_mem_MemWrite),
        .debug_read_data         (debug_read_data),
        .debug_mem_wb_alu_result (debug_mem_wb_alu_result),
        .debug_mem_wb_mem_data   (debug_mem_wb_mem_data),
        .debug_mem_wb_rd         (debug_mem_wb_rd),
        .debug_writeback         (debug_writeback),
        .debug_mem_wb_RegWrite   (debug_mem_wb_RegWrite),
        .debug_RegWrite          (debug_RegWrite),
        .debug_MemWrite          (debug_MemWrite),
        .debug_Branch            (debug_Branch),
        .debug_Jump              (debug_Jump),
        .debug_ALUSrc            (debug_ALUSrc),
        .debug_MemtoReg          (debug_MemtoReg)
    );

    // setup
    initial begin
        cycle_count      = 0;
        reg_writes_count = 0;
        mem_writes_count = 0;
        stall_count      = 0;
        flush_count      = 0;
        branch_count     = 0;
        metrics_printed  = 1'b0;

        reset = 1'b1;
        #(CLK_PERIOD * 2);
        reset = 1'b0;

        $display("==========================================================================================================");
        $display("                                 RISC-V PIPELINED PROCESSOR MONITOR                                       ");
        $display("==========================================================================================================");
        $display(" TIME (ns) | CYCLE |    PC    |   INSTRUCTION  | STAGE / OPERATION  | EVENT & EXECUTION DETAILS           ");
        $display("==========================================================================================================");
    end

    // cycle counter
    always @(posedge clk) begin
        if (!reset)
            cycle_count <= cycle_count + 1;
    end

    // live monitor
    always @(negedge clk) begin
        if (!reset && !metrics_printed) begin
            $display(" %9t | %5d | 0x%06h |   0x%08h   | [ IF Fetch ]      | Fetched Instruction",
                     $time, cycle_count, debug_pc[23:0], debug_instruction);

            if (debug_mem_wb_RegWrite && (debug_mem_wb_rd != 5'd0)) begin
                $display(" %9t | %5d |    --    |        --      | [ WB Writeback ]  | REG[x%02d] <= 0x%08h",
                         $time, cycle_count, debug_mem_wb_rd, debug_writeback);
                reg_writes_count = reg_writes_count + 1;
            end

            if (debug_ex_mem_MemWrite) begin
                $display(" %9t | %5d |    --    |        --      | [ MEM Store ]     | MEM[0x%08h] <= 0x%08h",
                         $time, cycle_count, debug_ex_mem_alu_result, uut.core.ex_mem_rs2_data);
                mem_writes_count = mem_writes_count + 1;
            end

            if (debug_Branch || debug_Jump) begin
                $display(" %9t | %5d |    --    |        --      | [ ID/EX Control ] | Target: 0x%08h (Taken: %b)",
                         $time, cycle_count, uut.core.ex_target, debug_flush);
                branch_count = branch_count + 1;
            end

            if (debug_stall) begin
                $display(" %9t | %5d |    --    |        --      | ---> [STALL]      | Load-Use Hazard Interlock Active",
                         $time, cycle_count);
                stall_count = stall_count + 1;
            end

            if (debug_flush) begin
                $display(" %9t | %5d |    --    |        --      | ---> [FLUSH]      | Pipeline Control Hazard Flush Active",
                         $time, cycle_count);
                flush_count = flush_count + 1;
            end

            $display("----------------------------------------------------------------------------------------------------------");
        end
    end

    // metrics printed once
    always @(posedge clk) begin
        if (!reset && !metrics_printed) begin
            if (cycle_count >= MAX_CYCLES) begin
                metrics_printed = 1'b1;
                errors = 0;

                $display("\n==========================================================================================================");
                $display("                                        SIMULATION EXECUTION METRICS                                      ");
                $display("==========================================================================================================");
                $display("  Total Executed Cycles    : %0d", cycle_count);
                $display("  Total Register Writes    : %0d", reg_writes_count);
                $display("  Total Data Memory Writes : %0d", mem_writes_count);
                $display("  Total Control Hazards    : %0d (Branches/Jumps Evaluated)", branch_count);
                $display("  Total Hazard Stalls      : %0d", stall_count);
                $display("  Total Pipeline Flushes   : %0d", flush_count);
                $display("==========================================================================================================");

                $display("\n==========================================================================================================");
                $display("                         REGISTER FILE CORRECTNESS CHECK (x1 - x31)                                       ");
                $display("==========================================================================================================");
                for (i = 1; i <= 31; i = i + 1) begin
                    if (uut.core.RF.regfile[i] === expected_reg[i])
                        $display("  PASS: x%0d = 0x%08h", i, uut.core.RF.regfile[i]);
                    else begin
                        $display("  FAIL: x%0d = 0x%08h, expected 0x%08h", i, uut.core.RF.regfile[i], expected_reg[i]);
                        errors = errors + 1;
                    end
                end

                $display("\n==========================================================================================================");
                $display("                         DATA MEMORY CORRECTNESS CHECK (word 0 - 8)                                       ");
                $display("==========================================================================================================");
                for (i = 0; i <= 8; i = i + 1) begin
                    if (uut.core.DMEM.mem[i] === expected_mem[i])
                        $display("  PASS: mem[word %0d] = 0x%08h", i, uut.core.DMEM.mem[i]);
                    else begin
                        $display("  FAIL: mem[word %0d] = 0x%08h, expected 0x%08h", i, uut.core.DMEM.mem[i], expected_mem[i]);
                        errors = errors + 1;
                    end
                end

                $display("\n==========================================================================================================");
                if (errors == 0)
                    $display("                    >>> STATUS: ALL 40 CHECKS PASSED - PROGRAM VERIFIED CORRECT <<<                     ");
                else
                    $display("                    >>> STATUS: %0d CHECK(S) FAILED - SEE DETAILS ABOVE <<<                          ", errors);
                $display("==========================================================================================================\n");
            end
        end
    end

   

endmodule
