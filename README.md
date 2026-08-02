This project implements a 32-bit pipelined RISC processor in Verilog HDL. The processor is designed as an educational implementation of a classic 5-stage pipeline and supports a limited subset of RISC instructions. The objective of the project is to demonstrate instruction pipelining, register transfers between pipeline stages, ALU operations, memory access, and basic branch execution.

The processor uses a little-endian memory organization for both instruction memories.
32-bit processor datapath
5-stage instruction pipeline
Little-endian instruction memory
Separate instruction and data memories
32 general-purpose registers
Register x0 permanently hardwired to zero
Immediate generation for supported instruction formats
Basic branch support

Since it is not supporting bit level manipulation a whole 32 bit of data memory is used preffered over byte addressing

supported instruction sets add,sub,and,or,addi,lw,sw,beq
