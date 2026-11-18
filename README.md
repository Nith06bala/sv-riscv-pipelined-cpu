# 5-Stage Pipelined RISC-V Processor (RV32I Subset)

A 32-bit, 5-stage pipelined RISC-V processor written in SystemVerilog. It supports a subset of the RV32I instruction set, with data forwarding, load-use hazard detection and branch flushing. It was simulated in ModelSim and implemented on a Cyclone V FPGA using Quartus Prime.

## Highlights

- 5-stage pipeline: Fetch, Decode, Execute, Memory, Write-back
- Forwarding unit to resolve RAW hazards without stalling
- Hazard detection unit that inserts a 1-cycle stall for load-use hazards
- Branch handling for `BEQ` with pipeline flush when the branch is taken
- 32 general-purpose registers, with `x0` hardwired to zero
- Separate instruction and data memories
- **Max frequency:** 102.86 MHz at 3% ALM utilization on Cyclone V
- **CPI:** 1.67 on a 12-instruction stress test (mixed ALU, load/store, data hazards and branches)

## Supported Instructions

| Type | Instructions | Description |
|------|--------------|-------------|
| R-type | `ADD`, `SUB`, `AND`, `OR` | Operate on two source registers |
| I-type | `ADDI` | Register plus sign-extended immediate |
| Load | `LW` | Load a 32-bit word from data memory |
| Store | `SW` | Store a 32-bit word to data memory |
| Branch | `BEQ` | Branch if two registers are equal |

## Pipeline and Hazard Handling

| Hazard | Example | Hardware behaviour |
|--------|---------|--------------------|
| RAW (ALU to ALU) | `add` then `sub` | Forwarding unit passes the result directly to the next instruction |
| Load-use | `lw` then `add` | Hazard detection stalls for 1 cycle (PC held), then the loaded value is forwarded |
| Store dependency | `add` then `sw` | The latest ALU value is stored |
| Control (not taken) | `beq` not taken | Execution continues sequentially |
| Control (taken) | `beq` taken | The branch is resolved in Execute, the two younger instructions are flushed (control signals zeroed, NOP inserted) and the PC is redirected |
| Zero register | write to `x0` | Write is ignored, `x0` stays 0 |

**Forward select signals:** `rs1_sel` and `rs2_sel` choose the operand source. `01` forwards the Execute-stage result (EX/MEM) and `10` forwards the Memory-stage result (MEM/WB). Otherwise the register file value is used.

## Design Notes

- **Memory:** Instruction memory is little-endian. Data memory is word-addressed: the computed address indexes a full 32-bit word, and byte or halfword access (`LB`, `SB`, and similar) is not supported.
- **Branch target:** `pc_branch = PC + immediate`, with `psel` selecting the branch target.
- **Immediate generation** is implemented for the supported instruction formats.

## Results

| Metric | Value |
|--------|-------|
| Max frequency | 102.86 MHz |
| Logic utilization | 3% ALM |
| CPI | 1.67 (12-instruction stress test) |
| Target | Intel Cyclone V (Quartus Prime) |

## Verification

The design was checked with directed testbenches in ModelSim. Waveform analysis and timestamp-based checks were used on each feature:

ALU operations, register file, instruction fetch, instruction decode, load/store, forwarding unit, hazard detection unit, branch flush and pipeline registers. All of these passed.

SystemVerilog Assertions (SVA) are planned but not yet implemented.

<details>
<summary><b>Test program and expected results</b></summary>

| PC | Instruction | Expected result |
|----|-------------|-----------------|
| 0x00 | `add x3,x1,x2` | x3 = 30 |
| 0x04 | `sub x4,x3,x1` | x4 = 20 |
| 0x08 | `add x5,x4,x3` | x5 = 50 |
| 0x0C | `lw x6,0(x1)` | x6 = 50 |
| 0x10 | `add x7,x6,x5` | x7 = 100 |
| 0x14 | `sw x7,4(x1)` | Data_mem[14] = 100 |
| 0x18 | `lw x8,4(x1)` | x8 = 100 |
| 0x1C | `add x0,x1,x2` | x0 stays 0 |
| 0x20 | `add x9,x0,x1` | x9 = 10 |
| 0x24 | `beq x1,x2,+8` | Branch not taken |
| 0x28 | `beq x1,x1,+8` | Branch taken |
| 0x2C | `add x10,x10,x10` | Skipped after flush |
| 0x30 | `add x11,x7,x8` | x11 = 200 |

</details>

## Documentation

The full report, with waveform screenshots and timestamp-by-timestamp explanations of forwarding, hazard detection, branching and the zero register, is in [`docs/RISCV_Documentation.pdf`](docs/RISCV_Documentation.pdf).

## How to Simulate

1. Open the project in ModelSim (or Quartus Prime).
2. Compile the RTL files and the testbench.
3. Run the testbench and open the waveform to see the pipeline signals.

## Planned Work

- Add SystemVerilog Assertions for the forwarding, stall and flush logic

## Author

Nithish Kanna B, B.Tech (VLSI Design Technology), SASTRA Deemed University
