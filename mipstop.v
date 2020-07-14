`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

	Top view of Single cycle MIPS.

*/
//////////////////////////////////////////////////////////////////////////////////

module top_view(input clk, reset, 
           output [31:0] writeData, dataAddress, 
           output        memoryWrite);

  wire [31:0] pc, instruction, readData;
  
  // instantiate processor and memories
  mips mips(clk, reset, pc, instruction, memoryWrite, dataAddress, writeData, readData);
  InstMem imem(pc[7:2], instruction);
  DataMem dmem(clk, memoryWrite, dataAddress, writeData, readData);

endmodule