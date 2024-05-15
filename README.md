
# 32-Bit MIPS Processor

Written in Verilog, this is a 32-bit MIPS processor that can support the following instructions:
- Arithmetic/Logic
    - AND, OR, NOR, ADD, SUB, SLT, ADDI, DIV, MULT
- Data Movement
    - LW, SW, MFHI, MFLO
- Flow Control
    - BEQ, J

Additionally, the processor is implemented with a five-stage pipelined data path and partitioned memory with a code section and a separate data section. 

## Background
MIPS is a Reduced Instruction Set Computer (RISC) architecture designed by MIPS Technologies. It stands for Microprocessor without Interlocked Pipeline Stages. RISC designs prioritize simplicity and efficiency by adopting a small set of fixed-length instructions that are executed in a single clock cycle. This design concept enables instructions to be executed more quickly and efficiently.

The "32-bit" designation refers to the size of the processor's data stream and registers. The data path in a 32-bit MIPS processor can handle data in 32-bit chunks, meaning it can process integers, memory locations, and other data types up to 32 bits in length. This size is important because it affects the greatest quantity of data that the processor can manipulate at the same time as well as the maximum addressable memory space.

The five-stage pipeline is an essential element in current processor architecture that seeks to increase performance by decomposing the instruction execution process into five consecutive stages: instruction fetch (IF), instruction decode (ID), execution (EX), memory access (MEM), and write back (WB). Multiple instructions can be executed concurrently in this pipeline, with each stage addressing a distinct instruction in parallel. This pipelining technique boosts the processor's total throughput and allows for faster instruction execution.

## Usage
A sample assembly program is provided in `MIPS_DEMO_CODE.asm` that was (roughly) compiled into `Program.txt`. Changes made to memory can be viewed using the "Memory List" feature of Intel ModelSim or by viewing `Memory.txt` to see the changes. Simulate or run the main testbench `CPU_test.vt` using either ModelSim or Icarus Verilog and VVP. 

The sample program already loaded into `Program.txt` will perform the following:

* Load data in first memory slot into $t1
    * Assumed to exist
    * Data for demo purposes: 0000000A
* Load data in second memory slot into $t2
    * Assumed to exist
    * Data for demo purposes: 00000008
* Perform division of $t1 and $t2
    * LO: integer division result
    * HI: remainder
* Move LO result into $t3
* Perform multiplication of “b” ($t2) with quotient (floor of “a”/”b”) held in $t3
* Subtract product from “a” ($t1)
    * Remainder calculated
* Place result into third memory slot
* Add immediate “0x777” to $zero and $t6
* Place that value into fourth memory slot
* Jump to “LiamBranch”
    * Effectively skipping the following operations:
        * Add immediate “0x666” to $t7
        * Store into fifth memory slot
* Branch if $t6 equals zero
    * $t6 still holds 0x777, will not branch
    * Proof of no branch:
        * Branching would’ve resulted in “0xBEEF” being placed into the seventh memory slot
* Jump to “exit”
    * Prove exit jump by placing “0xDEAD” into memory 

