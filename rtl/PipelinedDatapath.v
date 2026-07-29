`timescale 1ns / 1ps

module Datapath_Pipelined(
    input clk,
    input reset,

    // Debug Ports
    output [31:0] debug_pc, 
    output [31:0] debug_instruction,
    output [31:0] debug_if_id_pc,
    output [31:0] debug_if_id_instruction,
    output [31:0] debug_read_data1,
    output [31:0] debug_read_data2,
    output [31:0] debug_imm,
    output [4:0]  debug_id_rs1,
    output [4:0]  debug_id_rs2,
    output [4:0]  debug_id_rd,
    output [31:0] debug_id_ex_pc,
    output [4:0]  debug_id_ex_rs1,
    output [4:0]  debug_id_ex_rs2,
    output [4:0]  debug_id_ex_rd,
    output [31:0] debug_alu_result,
    output [2:0]  debug_ALUControl,
    output        debug_Zero,
    output [1:0]  debug_ForwardA,
    output [1:0]  debug_ForwardB,
    output        debug_stall,
    output        debug_flush,
    output [31:0] debug_ex_mem_alu_result,
    output [4:0]  debug_ex_mem_rd,
    output        debug_ex_mem_RegWrite,
    output        debug_ex_mem_MemWrite,
    output [31:0] debug_read_data,
    output [31:0] debug_mem_wb_alu_result,
    output [31:0] debug_mem_wb_mem_data,
    output [4:0]  debug_mem_wb_rd,
    output [31:0] debug_writeback,
    output        debug_mem_wb_RegWrite,
    output        debug_RegWrite,
    output        debug_MemWrite,
    output        debug_Branch,
    output        debug_Jump,
    output        debug_ALUSrc,
    output        debug_MemtoReg
);

    // IF Stage
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    wire [31:0] instruction;
    wire        stall;
    wire        ex_branch_taken;
    wire        ex_jump;
    wire [31:0] ex_target;
    wire        flush_control;

    assign flush_control = ex_branch_taken | ex_jump; // Flush Ctrl
    assign pc_plus4      = pc_current + 32'd4;        // PC + 4
    assign pc_next       = flush_control ? ex_target : pc_plus4; // Next PC

    programcounter PC (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    InstructionMemory IM (
        .address(pc_current),
        .instruction(instruction)
    );

    // IF/ID Reg
    wire [31:0] if_id_pc;
    wire [31:0] if_id_pc_plus4;
    wire [31:0] if_id_instruction;

    IF_ID IF_ID_REG (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush_control),
        .pc_current_in(pc_current),
        .pc_plus4_in(pc_plus4),
        .instruction_in(instruction),
        .pc_current_out(if_id_pc),
        .pc_plus4_out(if_id_pc_plus4),
        .instruction_out(if_id_instruction)
    );

    // ID Stage
    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire       funct7_5;

    assign opcode   = if_id_instruction[6:0];   // Opcode
    assign rd       = if_id_instruction[11:7];  // rd
    assign funct3   = if_id_instruction[14:12]; // Funct3
    assign rs1      = if_id_instruction[19:15]; // rs1
    assign rs2      = if_id_instruction[24:20]; // rs2
    assign funct7_5 = if_id_instruction[30];    // Funct7[5]

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] writeback_data;
    wire        mem_wb_RegWrite; 
    wire [4:0]  mem_wb_rd;       

    RegisterFile RF (
        .clk(clk),
        .reset(reset),
        .RegWrite(mem_wb_RegWrite),
        .read_addr1(rs1),          
        .read_addr2(rs2),          
        .write_addr(mem_wb_rd),     
        .write_data(writeback_data),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    wire Branch;
    wire Jump;
    wire MemWrite;
    wire RegWrite;
    wire MemToReg;
    wire ALUSrc;
    wire [1:0] ALUOp;
    wire [1:0] ImmSrc;         

    MainControl CONTROL (
        .opcode(opcode),
        .Branch(Branch),
        .Jump(Jump),
        .MemWrite(MemWrite),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc)            
    );

    wire [31:0] imm;

    ImmGen IMMGEN (
        .instruction(if_id_instruction),
        .ImmSrc(ImmSrc), // Imm type          
        .imm_out(imm)
    );

    // ID/EX Reg
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_pc_plus4;
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_imm;
    wire [4:0]  id_ex_rs1;
    wire [4:0]  id_ex_rs2;
    wire [4:0]  id_ex_rd;
    wire [2:0]  id_ex_funct3;
    wire        id_ex_funct7_5;
    wire        id_ex_ALUSrc;
    wire [1:0]  id_ex_ALUOp;
    wire        id_ex_Branch;
    wire        id_ex_Jump;
    wire        id_ex_MemWrite;
    wire        id_ex_RegWrite;
    wire        id_ex_MemToReg;
    wire        id_ex_flush;

    ID_EX ID_EX_REG (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush),
        .pc_in(if_id_pc),
        .pc_plus4_in(if_id_pc_plus4),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),
        .imm_in(imm),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .funct3_in(funct3),
        .funct7_5_in(funct7_5),
        .ALUSrc_in(ALUSrc),
        .ALUOp_in(ALUOp),
        .Branch_in(Branch),
        .Jump_in(Jump),
        .MemWrite_in(MemWrite),
        .RegWrite_in(RegWrite),
        .MemToReg_in(MemToReg),
        .pc_out(id_ex_pc),
        .pc_plus4_out(id_ex_pc_plus4),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_5_out(id_ex_funct7_5),
        .ALUSrc_out(id_ex_ALUSrc),
        .ALUOp_out(id_ex_ALUOp),
        .Branch_out(id_ex_Branch),
        .Jump_out(id_ex_Jump),
        .MemWrite_out(id_ex_MemWrite),
        .RegWrite_out(id_ex_RegWrite),
        .MemToReg_out(id_ex_MemToReg)
    );

    // EX Stage
    wire [2:0] alu_control;       

    ALU_Control ALU_CTRL (
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7_5(id_ex_funct7_5),
        .ALUControl(alu_control) // ALU ctrl
    );

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    wire [4:0] ex_mem_rd;
    wire       ex_mem_RegWrite;

    Forwarding_Unit FU (
        .ID_EX_rs1(id_ex_rs1),
        .ID_EX_rs2(id_ex_rs2),
        .EX_MEM_rd(ex_mem_rd),
        .EX_MEM_RegWrite(ex_mem_RegWrite),
        .MEM_WB_rd(mem_wb_rd),
        .MEM_WB_RegWrite(mem_wb_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    wire [31:0] ex_mem_alu_result;

    wire [31:0] operand_A;
    assign operand_A = (ForwardA == 2'b00) ? id_ex_rs1_data :
                       (ForwardA == 2'b10) ? ex_mem_alu_result :
                                             writeback_data; // Src A

    wire [31:0] forwarded_rs2;
    assign forwarded_rs2 = (ForwardB == 2'b00) ? id_ex_rs2_data :
                           (ForwardB == 2'b10) ? ex_mem_alu_result :
                                                 writeback_data; // Src B

    wire [31:0] operand_B;
    assign operand_B = id_ex_ALUSrc ? id_ex_imm : forwarded_rs2; // ALU B

    wire [31:0] alu_result;
    wire        zero;

    ALU ALU1 (
        .operand_A(operand_A),     
        .operand_B(operand_B),     
        .ALUControl(alu_control),
        .ALU_result(alu_result),   
        .Zero(zero)
    );

    wire [31:0] ex_pc_plus_imm;
    assign ex_pc_plus_imm  = id_ex_pc + id_ex_imm;                // Target
    assign ex_branch_taken = id_ex_Branch & (zero ^ id_ex_funct3[0]); // Branch
    assign ex_jump         = id_ex_Jump;                          // Jump
    assign ex_target       = ex_pc_plus_imm;

    // EX/MEM Reg
    wire [31:0] ex_mem_rs2_data;
    wire [31:0] ex_mem_pc_plus4;
    wire        ex_mem_Jump;
    wire        ex_mem_MemWrite;
    wire        ex_mem_MemToReg;

    EX_MEM EX_MEM_REG (
        .clk(clk),
        .reset(reset),
        .flush(1'b0), // No flush             
        .alu_result_in(alu_result),
        .rs2_data_in(forwarded_rs2),
        .rd_in(id_ex_rd),
        .pc_plus4_in(id_ex_pc_plus4),
        .Jump_in(id_ex_Jump),
        .MemWrite_in(id_ex_MemWrite),
        .RegWrite_in(id_ex_RegWrite),
        .MemToReg_in(id_ex_MemToReg),
        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .rd_out(ex_mem_rd),
        .pc_plus4_out(ex_mem_pc_plus4),
        .Jump_out(ex_mem_Jump),
        .MemWrite_out(ex_mem_MemWrite),
        .RegWrite_out(ex_mem_RegWrite),
        .MemToReg_out(ex_mem_MemToReg)
    );

    // MEM Stage
    wire [31:0] mem_read_data;
    DataMemory DMEM (
        .clk(clk),
        .write_enable(ex_mem_MemWrite), // Mem write 
        .address(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .read_data(mem_read_data)
    );

    // MEM/WB Reg
    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_read_data;
    wire [31:0] mem_wb_pc_plus4;
    wire        mem_wb_Jump;
    wire        mem_wb_MemToReg;

    MEM_WB MEM_WB_REG (
        .clk(clk),
        .reset(reset),
        .flush(1'b0), // No flush             
        .alu_result_in(ex_mem_alu_result),
        .mem_read_data_in(mem_read_data),
        .rd_in(ex_mem_rd),
        .pc_plus4_in(ex_mem_pc_plus4),
        .Jump_in(ex_mem_Jump),
        .RegWrite_in(ex_mem_RegWrite),
        .MemToReg_in(ex_mem_MemToReg),
        .alu_result_out(mem_wb_alu_result),
        .mem_read_data_out(mem_wb_mem_read_data),
        .rd_out(mem_wb_rd),
        .pc_plus4_out(mem_wb_pc_plus4),
        .Jump_out(mem_wb_Jump),
        .RegWrite_out(mem_wb_RegWrite),
        .MemToReg_out(mem_wb_MemToReg)
    );

    // WB Stage
    wire [31:0] wb_data;

    assign wb_data        = mem_wb_MemToReg ? mem_wb_mem_read_data : mem_wb_alu_result; // WB mux
    assign writeback_data = mem_wb_Jump     ? mem_wb_pc_plus4       : wb_data;         // Final WB

    // Hazard Unit
    Hazard_Detection_Unit HDU (
        .ID_EX_rd(id_ex_rd),
        .ID_EX_MemToReg(id_ex_MemToReg),
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .stall(stall)
    );

    assign id_ex_flush = stall | flush_control; // Flush

    // Debug Assign
    assign debug_pc                  = pc_current;
    assign debug_instruction         = instruction;
    assign debug_if_id_pc            = if_id_pc;
    assign debug_if_id_instruction   = if_id_instruction;
    assign debug_read_data1          = rs1_data;
    assign debug_read_data2          = rs2_data;
    assign debug_imm                 = imm;
    assign debug_id_rs1              = rs1;
    assign debug_id_rs2              = rs2;
    assign debug_id_rd               = rd;
    assign debug_id_ex_pc            = id_ex_pc;
    assign debug_id_ex_rs1           = id_ex_rs1;
    assign debug_id_ex_rs2           = id_ex_rs2;
    assign debug_id_ex_rd            = id_ex_rd;
    assign debug_alu_result          = alu_result;
    assign debug_ALUControl          = alu_control;
    assign debug_Zero                = zero;
    assign debug_ForwardA            = ForwardA;
    assign debug_ForwardB            = ForwardB;
    assign debug_stall               = stall;
    assign debug_flush               = flush_control;
    assign debug_ex_mem_alu_result   = ex_mem_alu_result;
    assign debug_ex_mem_rd           = ex_mem_rd;
    assign debug_ex_mem_RegWrite     = ex_mem_RegWrite;
    assign debug_ex_mem_MemWrite     = ex_mem_MemWrite;
    assign debug_read_data           = mem_read_data;
    assign debug_mem_wb_alu_result   = mem_wb_alu_result;
    assign debug_mem_wb_mem_data     = mem_wb_mem_read_data;
    assign debug_mem_wb_rd           = mem_wb_rd;
    assign debug_writeback           = writeback_data;
    assign debug_mem_wb_RegWrite     = mem_wb_RegWrite;
    assign debug_RegWrite            = RegWrite;
    assign debug_MemWrite            = MemWrite;
    assign debug_Branch              = Branch;
    assign debug_Jump                = Jump;
    assign debug_ALUSrc              = ALUSrc;
    assign debug_MemtoReg            = MemToReg;

endmodule
