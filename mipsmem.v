`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

	Memeory modules of single cycle MIPS.

*/
//////////////////////////////////////////////////////////////////////////////////

module DataMem(input clk, we,
            input  [31:0] a, wd,
            output [31:0] rd);

  reg  [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we)
      RAM[a[31:2]] <= wd;
endmodule

module InstMem(input  [5:0] a,
            output [31:0] rd);

  reg  [31:0] RAM[63:0];

  initial
    begin
      $readmemh("memfile.dat",RAM);
    end

  assign rd = RAM[a]; // word aligned
endmodule

