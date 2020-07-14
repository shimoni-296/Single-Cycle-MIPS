### Objective

Design a single-cycle MIPS-based (32-bit) processor using Verilog for the instructions such as R-type (ADD, SUB, AND, OR, SLT), I/M-type (LW/SW/ADDI/SUBI) and BEQ and J-type instructions (JAL, J). Include the above designed processor both integer type operation and single-precision floating-point unit to handle add.s, sub.s, and mul.s.


### Files Description

1. mipstop.v
	Contains the top view of the MIPS. 

2. mipsmem.v
	Contains the memory modules of the single cycle MIPS (Data memory and instruction memory).

3. mips.v
	Contains the code for controller, Instruction decoder and ALU decoder of the MIPS.

4. mipsparts.v
	Contains the code for ALU, Register File, Adder, Sign Extension and Multiplexer of the MIPS.

5. mipstest.v
	Testbench for single cycle MIPS called from mipstop.v.

6. memfile.dat
	Contains all the instructions (machine format) that needs to be executed.