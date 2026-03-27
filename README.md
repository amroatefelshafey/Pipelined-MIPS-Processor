Design & Implementation of a pipelined classical MIPS Processor used in educational settings.

The Processor implements the following instructions:

1 - add 
2 - sub
3 - multu
4 - sll
5 - slti
6 - ori
7 - lw
8 - sw
9 - beq
10 - jal

The specific instructions were chosen by us with the common goal of having all MIPS instruction formats (R-type, I-type, J-type) implemented in a way
different to what is typically taught in a classroom.

Since not all instructions from a specific type are identical (such as lw and an immediate arithemtic/logic instruction for instance), we had to think
about which instructions to choose such that all the addressing modes are implemented. Our instruction set is classified into the addressing modes as
follows:

-> Register Addressing: add, sub, multu, sll
-> Immediate Addressing: ori, slti
-> Base Addressing: lw, sw
-> PC-Relative Addressing: beq
-> Psuedodirect Addressing: jal

A collaboration between: Abdelrahman Mansour, Amro Elshafey, Mahmoud Halwani
