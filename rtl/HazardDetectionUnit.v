module Hazard_Detection_Unit(
    input [4:0] ID_EX_rd,
    input       ID_EX_MemToReg,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,

    output stall
);

assign stall = ID_EX_MemToReg &&
               (ID_EX_rd != 5'd0) &&
               ((ID_EX_rd == IF_ID_rs1) ||
                (ID_EX_rd == IF_ID_rs2));

endmodule
