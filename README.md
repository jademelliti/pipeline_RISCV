# PIPELINE_RISCV

This project implements a pipelined RISC-V processor based on the RV32I architecture. It was developed in SystemVerilog as part of an advanced processor architecture course. The main objectives were to:

- Design and optimize a pipelined processor microarchitecture

- Understand and mitigate pipeline hazards (data/control dependencies)

- Evaluate the performance impact of cache hierarchies

--- 

Note: This report is written in French as it was originally prepared to fulfill course requirements at École des Mines de Saint-Étienne, where French is the primary language of instruction for this technical curriculum.

--- 

Key Features

1. Pipeline Design

    - 5-stage RISC pipeline (Fetch, Decode, Execute, Memory, Write-Back)

    - Implements full forwarding logic to minimize stalls

2. Hazard Management

    - Dual mitigation strategies:

        - Software: Compiler-inserted NOPs

        - Hardware: Dynamic stall generation and forwarding

3. Cache Subsystem

    - Implemented both:

        - Direct-mapped instruction cache

        - 2-way set-associative instruction cache

    - Configurable line size (16/32 bytes)

Repository Contents

- Only cache implementation files are included (single-way/two-way associative designs)

- Excluded: The base single-cycle processor code (provided as course material - not my original work)

The project successfully achieved all course objectives while maintaining a modular, well-documented codebase suitable for academic reference.