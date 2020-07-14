`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

	Components - ALU, Register File, Adder, Sign Extension and Multiplexer.

*/
//////////////////////////////////////////////////////////////////////////////////

module priority_encoder(
			input [24:0] significand,
			input [7:0] Exponent_a,
			output reg [24:0] Significand,
			output [7:0] ExpSub
			);

reg [4:0] shift;

always @(significand)
begin
	casex (significand)
		25'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx :	begin
													Significand = significand;
									 				shift = 5'd0;
								 			  	end
		25'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 1;
									 				shift = 5'd1;
								 			  	end

		25'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin						
										 			Significand = significand << 2;
									 				shift = 5'd2;
								 				end

		25'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	begin 							
													Significand = significand << 3;
								 	 				shift = 5'd3;
								 				end

		25'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 4;
								 	 				shift = 5'd4;
								 				end

		25'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	begin						
									 				Significand = significand << 5;
								 	 				shift = 5'd5;
								 				end

		25'b1_0000_001x_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h020000
									 				Significand = significand << 6;
								 	 				shift = 5'd6;
								 				end

		25'b1_0000_0001_xxxx_xxxx_xxxx_xxxx : 	begin						// 24'h010000
									 				Significand = significand << 7;
								 	 				shift = 5'd7;
								 				end

		25'b1_0000_0000_1xxx_xxxx_xxxx_xxxx : 	begin						// 24'h008000
									 				Significand = significand << 8;
								 	 				shift = 5'd8;
								 				end

		25'b1_0000_0000_01xx_xxxx_xxxx_xxxx : 	begin						// 24'h004000
									 				Significand = significand << 9;
								 	 				shift = 5'd9;
								 				end

		25'b1_0000_0000_001x_xxxx_xxxx_xxxx : 	begin						// 24'h002000
									 				Significand = significand << 10;
								 	 				shift = 5'd10;
								 				end

		25'b1_0000_0000_0001_xxxx_xxxx_xxxx : 	begin						// 24'h001000
									 				Significand = significand << 11;
								 	 				shift = 5'd11;
								 				end

		25'b1_0000_0000_0000_1xxx_xxxx_xxxx : 	begin						// 24'h000800
									 				Significand = significand << 12;
								 	 				shift = 5'd12;
								 				end

		25'b1_0000_0000_0000_01xx_xxxx_xxxx : 	begin						// 24'h000400
									 				Significand = significand << 13;
								 	 				shift = 5'd13;
								 				end

		25'b1_0000_0000_0000_001x_xxxx_xxxx : 	begin						// 24'h000200
									 				Significand = significand << 14;
								 	 				shift = 5'd14;
								 				end

		25'b1_0000_0000_0000_0001_xxxx_xxxx  : 	begin						// 24'h000100
									 				Significand = significand << 15;
								 	 				shift = 5'd15;
								 				end

		25'b1_0000_0000_0000_0000_1xxx_xxxx : 	begin						// 24'h000080
									 				Significand = significand << 16;
								 	 				shift = 5'd16;
								 				end

		25'b1_0000_0000_0000_0000_01xx_xxxx : 	begin						// 24'h000040
											 		Significand = significand << 17;
										 	 		shift = 5'd17;
												end

		25'b1_0000_0000_0000_0000_001x_xxxx : 	begin						// 24'h000020
									 				Significand = significand << 18;
								 	 				shift = 5'd18;
								 				end

		25'b1_0000_0000_0000_0000_0001_xxxx : 	begin						// 24'h000010
									 				Significand = significand << 19;
								 	 				shift = 5'd19;
												end

		25'b1_0000_0000_0000_0000_0000_1xxx :	begin						// 24'h000008
									 				Significand = significand << 20;
								 					shift = 5'd20;
								 				end

		25'b1_0000_0000_0000_0000_0000_01xx : 	begin						// 24'h000004
									 				Significand = significand << 21;
								 	 				shift = 5'd21;
								 				end

		25'b1_0000_0000_0000_0000_0000_001x : 	begin						// 24'h000002
									 				Significand = significand << 22;
								 	 				shift = 5'd22;
								 				end

		25'b1_0000_0000_0000_0000_0000_0001 : 	begin						// 24'h000001
									 				Significand = significand << 23;
								 	 				shift = 5'd23;
								 				end

		25'b1_0000_0000_0000_0000_0000_0000 : 	begin						// 24'h000000
								 					Significand = significand << 24;
							 	 					shift = 5'd24;
								 				end
		default : 	begin
						Significand = (~significand) + 1'b1;
						shift = 8'd0;
					end

	endcase
end
assign ExpSub = Exponent_a - shift;

endmodule

module alu(input [31:0] a, b, 
           input [4:0]  shamt,
           input [3:0]  aluControl, 
           output reg [31:0] result, wd0, wd1,
           output zero);

  wire [31:0] b2, sum, slt, sra_sign, sra_aux;
  wire [63:0] product, quotient, remainder;
 
  assign b2 = aluControl[2] ? ~b:b; 
  assign sum = a + b2 + aluControl[2];
  assign slt = sum[31];
  assign sra_sign = 32'b1111_1111_1111_1111 << (32 - shamt);
  assign sra_aux = b >> shamt;
  assign product = a * b;
  assign quotient = a / b;
  assign remainder = a % b;

  // floating point operations - variables

  reg AddSubMode;
  wire AddSubOperation;
  wire OperandMode;
  wire SignBit;
  wire Exception;
  wire Overflow; // multiplication
  wire Underflow; // multiplication

  wire [31:0] FPUa,FPUb;
  wire [23:0] SigA,SigB;
  wire [7:0] ExpDiff;


  wire [23:0] SigAddSub;
  wire [7:0] ExpAddSub;

  wire [24:0] SigAdd;
  wire [30:0] AddSum;

  wire [23:0] SigSubComp;
  wire [24:0] SigSub;
  wire [30:0] SubDiff;
  wire [24:0] Subtraction; 
  wire [7:0] ExpSub;

  wire [31:0] result_fpu;
  wire [31:0] result_fpu_mult;
  
  wire Sign,RoundProduct,Normalised,MultZero;
  wire [8:0] Exponent,ExponentSum;
  wire [22:0] MantissaProduct;
  //wire [23:0] operand_a,operand_b;
  wire [47:0] MultProduct,NormalizedProduct; //48 Bits

  // end of floating point operations - variables

  // floating point calculations for addition/subtraction

  always@(*)
    case(aluControl[3:0])
       4'b1001: AddSubMode <= 1'b0;
       4'b1101: AddSubMode <= 1'b1;
    endcase

  assign {OperandMode,FPUa,FPUb} = (a[30:0] < b[30:0]) ? {1'b1,b,a} : {1'b0,a,b};

  assign exp_a = FPUa[30:23];
  assign exp_b = FPUb[30:23];

  //Exception flag sets 1 if either one of the exponent is 255.
  assign Exception = (&FPUa[30:23]) | (&FPUb[30:23]);

  assign SignBit = AddSubMode ? OperandMode ? !FPUa[31] : FPUa[31] : FPUa[31] ;

  assign AddSubOperation = AddSubMode ? FPUa[31] ^ FPUb[31] : ~(FPUa[31] ^ FPUb[31]);

  //Assigining significand values according to Hidden Bit.
  //If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1
  assign SigA = (|FPUa[30:23]) ? {1'b1,FPUa[22:0]} : {1'b0,FPUa[22:0]};
  assign SigB = (|FPUb[30:23]) ? {1'b1,FPUb[22:0]} : {1'b0,FPUb[22:0]};

  //Evaluating Exponent Difference
  assign ExpDiff = FPUa[30:23] - FPUb[30:23];

  //Shifting SigB according to ExpDiff
  assign SigAddSub = SigB >> ExpDiff;

  assign ExpAddSub = FPUb[30:23] + ExpDiff; 

  //Checking exponents are same or not
  assign perform = (FPUa[30:23] == ExpAddSub);

  // fpu addition

  assign SigAdd = (perform & AddSubOperation) ? (SigA + SigAddSub) : 25'd0; 

  //Result will be equal to Most 23 bits if carry generates else it will be Least 22 bits.
  assign AddSum[22:0] = SigAdd[24] ? SigAdd[23:1] : SigAdd[22:0];

  //If carry generates in sum value then exponent must be added with 1 else feed as it is.
  assign AddSum[30:23] = SigAdd[24] ? (1'b1 + FPUa[30:23]) : FPUa[30:23];

  // fpu subtraction

  assign SigSubComp = (perform & !AddSubOperation) ? ~(SigAddSub) + 24'd1 : 24'd0 ; 

  assign SigSub = perform ? (SigA + SigSubComp) : 25'd0;

  priority_encoder pe(SigSub,FPUa[30:23],Subtraction,ExpSub);

  assign SubDiff[30:23] = ExpSub;

  assign SubDiff[22:0] = Subtraction[22:0];

  assign result_fpu = Exception ? 32'b0 : ((!AddSubOperation) ? {SignBit,SubDiff} : {SignBit,AddSum});

  // end of floating point calculations - addition/subtraction


 // floating point calculations - multiplication
 
 assign Sign = a[31] ^ b[31];

 //Exception flag sets 1 if either one of the exponent is 255.
 assign Exception = (&a[30:23]) | (&b[30:23]);

 //Assigining significand values according to Hidden Bit.
 //If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1

 assign FPUa = (|a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]};

 assign FPUb = (|b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]};

 assign MultProduct = FPUa * FPUb;			//Calculating Product

 assign RoundProduct = |NormalizedProduct[22:0];  //Ending 22 bits are OR'ed for rounding operation.

 assign Normalised = MultProduct[47] ? 1'b1 : 1'b0;	

 assign NormalizedProduct = Normalised ? MultProduct : MultProduct << 1;	//Assigning Normalised value based on 48th bit

 //Final Manitssa.
 assign MantissaProduct = NormalizedProduct[46:24] + (NormalizedProduct[23] & RoundProduct); 

 assign MultZero = Exception ? 1'b0 : (MantissaProduct == 23'd0) ? 1'b1 : 1'b0;

 assign ExponentSum = a[30:23] + b[30:23];

 assign Exponent = ExponentSum - 8'd127 + Normalised;

 assign Overflow = ((Exponent[8] & !Exponent[7]) & !MultZero) ; //If overall exponent is greater than 255 then Overflow condition.
 //Exception Case when exponent reaches its maximu value that is 384.

 //If sum of both exponents is less than 127 then Underflow condition.
 assign Underflow = ((Exponent[8] & Exponent[7]) & !MultZero) ? 1'b1 : 1'b0; 

 assign result_fpu_mult = Exception ? 32'd0 : MultZero ? {Sign,31'd0} : Overflow ? {Sign,8'hFF,23'd0} : Underflow ? {Sign,31'd0} : {Sign,Exponent[7:0],MantissaProduct};
 
 // end of floating point calculations

  always@(*)
    case(aluControl[3:0])
      4'b0000: result <= a & b;
      4'b0001: result <= a | b;
      4'b0010: result <= sum;
      4'b0011: result <= b << shamt;
      4'b1011: result <= b << a;
      4'b0100: result <= b >> shamt;
      4'b1100: result <= b >> a;
      4'b0101: result <= sra_sign | sra_aux;
      4'b0110: result <= sum;
      4'b0111: result <= slt;
      4'b1010: 
        begin
          result <= product[31:0]; 
          wd0    <= product[31:0];
          wd1    <= product[63:32];
        end
      4'b1110: 
        begin
          result <= quotient; 
          wd0    <= quotient;
          wd1    <= remainder;
        end
      4'b1000: result <= b << 5'd16;

      4'b1001: // fpu_add
	begin
	  result <= result_fpu;
	end

      4'b1101:  // fpu_sub
	begin
	  result <= result_fpu;

	end

      4'b1111: // fpu_mult
	begin
		result <= result_fpu_mult;
	end
    endcase

  assign zero = (result == 32'd0);
endmodule

module regfile(input         clk, 
               input         we3, 
               input  [4:0]  ra1, ra2, wa3, 
               input  [31:0] wd3, 
               output [31:0] rd1, rd2);

  reg [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 0 hardwired to 0

  always @(posedge clk)
    if (we3) rf[wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module spregfile(input       clk, 
               input         we, 
               input         ra, 
               input  [31:0] wd0, wd1, 
               output [31:0] rd);

  reg [31:0] rf[1:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 0 hardwired to 0

  always @(posedge clk)
    if (we == 1'b1)
      begin
        rf[1'b0] <= wd0;
        rf[1'b1] <= wd1;
      end
   assign rd = (ra != 1'b0) ? rf[1'b1] : rf[1'b0];
endmodule

module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module sl2(input  [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext(input  [15:0] a,
               output [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input                  clk, reset,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset,
                 input                  en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (en)    q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]            s, 
              output [WIDTH-1:0] y);

  assign y = (s == 2'b00) ? d0 : ((s == 2'b01) ? d1 : d2); 
endmodule

