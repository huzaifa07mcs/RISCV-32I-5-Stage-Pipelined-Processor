1. Module Name
RegisterFile

2. Purpose
The Register File stores the 32 general-purpose registers (x0–x31) used by the processor. It provides two combinational read ports for source operands (rs1, rs2) and one synchronous write port for the destination register (rd). Register x0 is hardwired to zero and cannot be modified.

3. Inputs

Signal	Width	Description
clk	1-bit	Clock signal, write occurs on rising edge
reset	1-bit	Synchronous active-high reset
read_addr1	5-bit	Register address for rs1
read_addr2	5-bit	Register address for rs2
write_addr	5-bit	Register address for rd (destination)
write_data	32-bit	Data to be written to write_addr
RegWrite	1-bit	Control signal enabling write on rising edge

4. Outputs

Signal	Width	Description
read_data1	32-bit	Data read from read_addr1 (rs1)
read_data2	32-bit	Data read from read_addr2 (rs2)

5. Parameters

Parameter	Value	Description
XLEN	32	Processor data width
NUM_REGS	32	Number of general-purpose registers

6. Internal Storage
Memory Type: Register array (flip-flop based, not ROM/RAM macro)
Word Width: 32 bits
Number of Words: 32
Declaration: reg [31:0] regfile [0:31];

7. Initialization
No external file loading required. On reset, all registers are cleared to 0 (see Reset Behavior). x0 is enforced to remain 0 at all times through write-side gating, not through periodic re-initialization.

8. Functional Behavior
Read (combinational, asynchronous):

read_data1 = (read_addr1 == 5'b0) ? 32'b0 : regfile[read_addr1];
read_data2 = (read_addr2 == 5'b0) ? 32'b0 : regfile[read_addr2];

Write (synchronous, on posedge clk):

if (RegWrite && write_addr != 5'b0)
    regfile[write_addr] <= write_data;

x0 is protected on both sides — read side always forces 0 regardless of what's stored, and write side blocks any write to address 0. This double-guard means even if something goes wrong on the write path, reads of x0 are still safe.

Same-cycle write-then-read (write_addr == read_addr1 or read_addr2 in the same cycle):
Read returns the old value, since reads are combinational off current regfile contents and the write only updates regfile at the next clock edge. This is standard single-cycle behavior. (Note: this becomes a data hazard in the pipelined version and will be resolved later by the Forwarding Unit — flag this here for your own future reference.)

9. Reset Behavior
On synchronous reset (reset == 1 at posedge clk), all 32 registers are cleared to 0:

if (reset) begin
    for (i = 0; i < 32; i = i + 1)
        regfile[i] <= 32'b0;
end

10. Verification
The following test cases shall be verified:

Reset: confirm all 32 registers read as 0 immediately after reset.
Write to x1, then read x1 — confirm write_data is returned.
Write to x0 — confirm read_data for x0 remains 0 (write should have no effect).
Simultaneous read of two different non-zero registers (read_addr1 ≠ read_addr2) — confirm both read_data outputs are correct independently.
Read x1 and x2 as read_addr1 and read_addr2 simultaneously where rs1 == rs2 (same address on both ports) — confirm both outputs match.
Write and read the same register in the same clock cycle (write_addr == read_addr1) — confirm read_data returns the old value, not write_data (validates combinational-read-before-write timing).
RegWrite == 0 with valid write_addr and write_data — confirm no write occurs (register value unchanged).
Write to every register x1–x31 individually and confirm each holds its correct value independent of the others (no cross-write corruption).

11. Notes

x0 is hardwired to zero at both the write path (no write allowed) and read path (forced output), as a safety redundancy.
Reads are purely combinational — required for single-cycle datapath where the ALU needs rs1/rs2 values in the same cycle as decode.
In the pipelined version, this same-cycle write/read behavior directly creates a RAW hazard scenario when WB stage writes back while ID stage reads — this module will be reused without modification, but the Forwarding Unit and Hazard Detection Unit (added in Phase 3) will handle correctness around it.
Designed for the single-cycle processor and reused without modification in the pipelined processor (write port moves to WB stage, read ports stay in ID stage).
