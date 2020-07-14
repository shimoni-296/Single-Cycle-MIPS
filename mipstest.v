//////////////////////////////////////////////////////////////////////////////////
/*
	
	Testbench for Single Cycle MIPS.

*/
//////////////////////////////////////////////////////////////////////////////////

module testbench();

  reg         clk;
  reg         reset;

  wire [31:0] writeData, dataAddress;
  wire memoryWrite;

  // instantiate device to be tested
  top_view dut(clk, reset, writeData, dataAddress, memoryWrite);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check that 7 gets written to address 84
  always@(negedge clk)
    begin
      if(memoryWrite) begin
        if(dataAddress === 84 & writeData === 7) begin
          $display("Simulation succeeded");
          $stop;
        end else if (dataAddress !== 80) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule



