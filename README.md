# 5-Stage Pipelined RISC-V Processor (RV32I Subset)

A 32-bit, 5-stage pipelined RISC-V processor written in SystemVerilog. It supports a subset of the RV32I instruction set, with data forwarding, load-use hazard detection and branch flushing. It was simulated in ModelSim and implemented on a Cyclone V FPGA using Quartus Prime.

## Highlights

- 5-stage pipeline: Fetch, Decode, Execute, Memory, Write-back
- Forwarding unit to resolve RAW hazards without stalling
- Hazard detection unit that inserts a 1-cycle stall for load-use hazards
- Branch handling for BEQ with pipeline flush when the branch is taken
- 32 general-purpose registers, with x0 hardwired to zero
- Separate instruction and data memories
- **Max frequency:** 102.86 MHz at 3% ALM utilization on Cyclone V
- **CPI:** 1.67 on a 12-instruction stress test (mixed ALU, load/store, data hazards and branches)

## Supported Instructions

 Type | Instructions | Description |
|------|--------------|-------------|
| R-type | ADD , SUB , AND , OR | Operate on two source registers |
| I-type | ADDI | Register plus sign-extended immediate |
| Load | LW | Load a 32-bit word from data memory |
| Store | SW | Store a 32-bit word to data memory |
| Branch | BEQ | Branch if two registers are equal |




## Design Notes

- **Memory:** Instruction memory is little-endian. Data memory is word-addressed: the computed address indexes a full 32-bit word, and byte or halfword access (LB, SB, and similar) is not supported.


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



</details>

## Documentation

The full report, with waveform screenshots and timestamp-by-timestamp explanations of forwarding, hazard detection, branching and the zero register, is in [`docs/RISCV_Documentation.pdf`](docs/RISCV_Documentation.pdf).

## How to Simulate

1. Open the project in ModelSim (or Quartus Prime).
2. Compile the RTL files and the testbench.
3. Run the testbench and open the waveform to see the pipeline signals.

## Planned Work

- Add SystemVerilog Assertions for the forwarding, stall and flush logic

Nithish Kanna B
