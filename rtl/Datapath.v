module Datapath(
    input clk, reset,
     // for testbench observation
    output [31:0] debug_pc, 
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result,
    output [31:0] debug_writeback,
    output [31:0] debug_read_data,
    output [31:0] debug_read_data1,
    output [31:0] debug_read_data2,
    output [31:0] debug_imm,

    output        debug_RegWrite,
    output        debug_MemWrite,
    output        debug_Branch,
    output        debug_Jump,
    output        debug_ALUSrc,
    output        debug_MemtoReg,
    output        debug_Zero,

output [2:0] debug_ALUControl
);
    // IF stage
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] instruction;
    wire [31:0] pc_plus4;
    wire [31:0] pc_plus_imm;
    wire        branch_taken;
    wire [31:0] mux1_out;

    programcounter pc (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );
    InstructionMemory imem (
        .address(pc_current),
        .instruction(instruction)
    );

    // ID stage
    wire [6:0] opcode   = instruction[6:0];
    wire [4:0] rd       = instruction[11:7];
    wire [2:0] funct3   = instruction[14:12];
    wire [4:0] rs1      = instruction[19:15];
    wire [4:0] rs2      = instruction[24:20];
    wire       funct7_5 = instruction[30];

    wire RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump;
    wire [1:0] ALUOp;
    wire [1:0] ImmSrc;
    wire [31:0] read_data1, read_data2;
    wire [31:0] imm_out;
    wire [31:0] writeback_data;

    MainControl mc (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc)
    );
    RegisterFile rf (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(writeback_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    ImmGen immgen (
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .imm_out(imm_out)
    );

    // EX stage
    wire [2:0]  ALUControl;
    wire [31:0] operand_B;
    wire [31:0] ALU_result;
    wire        Zero;

    ALU_Control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );
    assign operand_B = (ALUSrc) ? imm_out : read_data2; //ALUSRC MUX
    ALU alu (
        .operand_A(read_data1),
        .operand_B(operand_B),
        .ALUControl(ALUControl),
        .Zero(Zero),
        .ALU_result(ALU_result)
    );

    // MEM stage
    wire [31:0] read_data;
    DataMemory dmem (
        .clk(clk),
        .write_enable(MemWrite),
        .address(ALU_result),
        .write_data(read_data2),
        .read_data(read_data)
    );

    // WB stage
    wire [31:0] wb_data;
    assign wb_data        = (MemtoReg) ? read_data : ALU_result; //MEM TO REG MUX
    assign writeback_data = (Jump) ? pc_plus4 : wb_data;   // JAL writes PC+4, not ALU/mem result

    // PC update
    assign pc_plus4     = pc_current + 32'd4;
    assign pc_plus_imm  = pc_current + imm_out;
    assign branch_taken = Branch & (Zero ^ funct3[0]);     // handles BEQ and BNE both
    assign mux1_out     = branch_taken ? pc_plus_imm : pc_plus4;
    assign pc_next      = Jump ? pc_plus_imm : mux1_out;

    // debug outputs it keeps synthesis from pruning the whole design
    assign debug_pc          = pc_current;
    assign debug_instruction = instruction;
    assign debug_alu_result  = ALU_result;
    assign debug_writeback   = writeback_data;
    assign debug_read_data   = read_data;
    assign debug_read_data1  = read_data1;
    assign debug_read_data2  = read_data2;
    assign debug_imm         = imm_out;
    assign debug_RegWrite    = RegWrite;
    assign debug_MemWrite    = MemWrite;
    assign debug_Branch      = Branch;
    assign debug_Jump        = Jump;
    assign debug_ALUSrc      = ALUSrc;
    assign debug_MemtoReg    = MemtoReg;
    assign debug_Zero        = Zero;
    assign debug_ALUControl  = ALUControl;

endmodule
