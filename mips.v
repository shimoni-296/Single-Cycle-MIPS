`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

Objective:
	Design a single-cycle MIPS-based (32-bit) processor using Verilog for the instructions such as 
	R-type (ADD, SUB, AND, OR, SLT), I/M-type (LW/SW/ADDI/SUBI) and BEQ and J-type instructions (JAL, J). 
	Consider only integer type of operation. To test the design one must use the mipstest.s file. 
	Find out the delay of the design.
	
	Components - Controller, Instruction Decoder, ALU Decoder.

*/
//////////////////////////////////////////////////////////////////////////////////

module mips(input         clk, reset,
            output [31:0] pc,
            input  [31:0] instruction,
            output        memoryWrite,
            output [31:0] aluOut, writeData,
            input  [31:0] readData);

  wire        branch, memToReg,
              pcSource, zero, spra,
              aluSource, regWrite, spregWrite, jump, jal, jumpReg, readHiLo;
  wire [1:0]  regDest;
  wire [3:0]  aluControl;

  controller c(instruction[31:26], instruction[5:0], instruction[10:6], zero,
               memoryWrite, pcSource,
               aluSource, regWrite, spregWrite, regDest, memToReg, jump, jal, jumpReg,
               aluControl, spra, readHiLo);
  datapath dp(clk, reset, memToReg, pcSource,
              aluSource, regDest, regWrite, spregWrite, jump, jal, jumpReg, instruction[10:6],
              aluControl,
              zero, pc, instruction,
              aluOut, writeData, readData, spra, readHiLo);
endmodule

module controller(input  [5:0] op, funct,
				  input  [4:0] shamt,
                  input        zero,
                  output       memoryWrite,
                  output       pcSource, aluSource,
                  output       regWrite, spregWrite,
                  output [1:0] regDest, 
                  output       memToReg,
                  output       jump, jal, jumpReg,
                  output [3:0] aluControl,
                  output       spra, readHiLo);

  wire [3:0] aluOp;
  wire       branch;

  mainDecoder md(op, funct, memoryWrite, branch,
             aluSource, regWrite, spregWrite, regDest, memToReg, jump, jal,
             aluOp, spra, readHiLo);
  aluDecoder ad(funct, shamt, aluOp, aluControl, jumpReg);

  assign pcSource = branch & zero;
endmodule

module mainDecoder(input  [5:0] op, funct,
               output       memoryWrite,
               output       branch, aluSource,
               output       regWrite, spregWrite,
               output [1:0] regDest, 
               output       memToReg,
               output       jump, jal,
               output [3:0] aluOp,
               output reg   spra,
               output       readHiLo);

  reg [14:0] controls;

  assign {regWrite, regDest, aluSource,
          branch, memoryWrite,
          memToReg, jump, jal, aluOp, spregWrite, readHiLo} = controls;

  always @(*)
    case(op)
      6'b000000: 
      	begin
      		case(funct)
      			6'b011000: controls <= 15'b101000000001010; //mult
      			6'b011010: controls <= 15'b101000000001010; //div
      			default:   
      			  begin
      			    case(funct)
      			      6'b010000: 
      			        begin
      			          spra <= 1'b1;
      			          controls <= 15'b101000000001001;
      			        end
      			      6'b010010: 
      			        begin
      			          spra <= 1'b0;
      			          controls <= 15'b101000000001001;
      			        end
      			      default: controls <= 15'b101000000001000; //other R-type
      			    endcase
      			  end
      		endcase
      	end
      6'b100011: controls <= 15'b100100100000000; //LW
      6'b101011: controls <= 15'b000101000000000; //SW
      6'b000100: controls <= 15'b000010000000100; //BEQ
      6'b001000: controls <= 15'b100100000000000; //ADDI
      6'b000010: controls <= 15'b000000010000000; //J
      6'b000011: controls <= 15'b111000011000000; //JAL
      6'b001100: controls <= 15'b100100000010000; //ANDI
      6'b001101: controls <= 15'b100100000010100; //ORI
      6'b001010: controls <= 15'b100100000011100; //SLTI
      6'b001111: controls <= 15'b100100000100000; //LUI
      default:   controls <= 15'bxxxxxxxxxxxxxx; //???
    endcase
endmodule

module aluDecoder(input      [5:0] funct,
              input      [4:0] shamt,
              input      [3:0] aluOp,
              output reg [3:0] aluControl,
              output     jumpReg);

  always @(*)
    case(aluOp)
      4'b0000: aluControl <= 4'b0010;  // add
      4'b0001: aluControl <= 4'b0110;  // sub
      4'b0100: aluControl <= 4'b0000;	 // and
      4'b0101: aluControl <= 4'b0001;  // or
      4'b0111: aluControl <= 4'b0111;  // slt
      4'b1000: aluControl <= 4'b1000;  // lui
      4'b1001: aluControl <= 4'b1001; // fpu_add
      4'b1101: aluControl <= 4'b1101; // fpu_sub	
      4'b1111: aluControl <= 4'b1111; // fpu_mult
      default: case(funct)          // RTYPE
          6'b100000: aluControl <= 4'b0010; // ADD
          6'b100010: aluControl <= 4'b0110; // SUB
          6'b100100: aluControl <= 4'b0000; // AND
          6'b100101: aluControl <= 4'b0001; // OR
          6'b101010: aluControl <= 4'b0111; // SLT
          6'b000000: aluControl <= 4'b0011; // SLL
          6'b000010: aluControl <= 4'b0100; // SRL
          6'b000011: aluControl <= 4'b0101; // SRA
          6'b000100: aluControl <= 4'b1011; // SLLV
          6'b000110: aluControl <= 4'b1100; // SRLV
          6'b011000: aluControl <= 4'b1010; // MULT
          6'b011010: aluControl <= 4'b1110; // DIV
          default:   aluControl <= 4'bxxxx; // ???
        endcase
    endcase
    assign jumpReg = (funct == 6'b001000) ? 1 : 0;
endmodule

module datapath(input         clk, reset,
                input         memToReg, 
                input         pcSource,
                input         aluSource, 
                input  [1:0]  regDest,
                input         regWrite, spregWrite, jump, jal, jumpReg,
                input  [4:0]  shamt,
                input  [3:0]  aluControl,
                output        zero,
                output [31:0] pc,
                input  [31:0] instruction,
                output [31:0] aluOut, writeData,
                input  [31:0] readData,
                input         spra, readHiLo);

  wire [4:0]  writeReg;
  wire [31:0] pcNextJr, pcNext, pcNextBr, pcPlus4, pcBranch;
  wire [31:0] signImm, signImmSh;
  wire [31:0] srcA, srcB, wd0, wd1, sprd;
  wire [31:0] result, resultJal, resultHiLo;

  // next PC logic
  flopr #(32) pcreg(clk, reset, pcNext, pc);
  adder       pcadd1(pc, 32'b100, pcPlus4);
  sl2         immsh(signImm, signImmSh);
  adder       pcadd2(pcPlus4, signImmSh, pcBranch);
  mux2 #(32)  pcbrmux(pcPlus4, pcBranch, pcSource,
                      pcNextBr);
  mux2 #(32)  pcmux(pcNextBr, {pcPlus4[31:28], 
                    instruction[25:0], 2'b00}, 
                    jump, pcNext);
  mux2 #(32)  pcmuxjr(pcNext, srcA, 
                    jumpReg, pcNextJr);


  // register file logic
  regfile     rf(clk, regWrite, instruction[25:21],
                 instruction[20:16], writeReg,
                 resultHiLo, srcA, writeData);
  mux3 #(5)   wrmux(instruction[20:16], instruction[15:11], 5'b11111,
                    regDest, writeReg);
  mux2 #(32)  resmux(aluOut, readData,
                     memToReg, result);
  mux2 #(32)  wrmuxjal(result, pcPlus4, jal,
                      resultJal);
  mux2 #(32)  wrmuxhilo(resultJal, sprd, readHiLo, resultHiLo);
  signext     se(instruction[15:0], signImm);

  // ALU logic
  mux2 #(32)  srcbmux(writeData, signImm, aluSource,
                      srcB);
  alu         alu(srcA, srcB, shamt, aluControl,
                  aluOut, wd0, wd1, zero);
  // special register file logic
  spregfile   sprf(clk, spregWrite, spra, wd0, wd1, sprd);
endmodule
