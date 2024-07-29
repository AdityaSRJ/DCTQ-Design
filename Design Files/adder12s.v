
/* 
Adds eight 12 bit numbers , 2's compliment numbers , n0 to n7
Five pipeline stages registered @posedge of clk
Result sum is 15 bit , 2's compliment not registered
*/

module adder12s(
clk,
n0,n1,n2,n3,n4,n5,n6,n7,
sum
);

input clk;
input [11:0] n0,n1,n2,n3,n4,n5,n6,n7;

output [14:0] sum;

wire [7:0] s00_lsb;    // sij  where i = stage of addition and j is the number group
wire [7:0] s01_lsb;
wire [7:0] s02_lsb;
wire [7:0] s03_lsb;

wire [5:0] s00_msb;
wire [5:0] s01_msb;
wire [5:0] s02_msb;
wire [5:0] s03_msb;

wire [7:0] s10_lsb;
wire [7:0] s11_lsb;

wire [6:0] s10_msb;
wire [6:0] s11_msb;

wire [7:0] s20_lsb;

reg [11:7] n0_reg1;
reg [11:7] n1_reg1;  //MSB in not computed so its needs to be propogated
reg [11:7] n2_reg1;
reg [11:7] n3_reg1;
reg [11:7] n4_reg1;
reg [11:7] n5_reg1;
reg [11:7] n6_reg1;
reg [11:7] n7_reg1;   


reg [7:0] s00_lsbreg1;
reg [7:0] s01_lsbreg1;
reg [7:0] s02_lsbreg1;
reg [7:0] s03_lsbreg1;

reg [5:0] s00_msbreg2;
reg [5:0] s01_msbreg2;
reg [5:0] s02_msbreg2;
reg [5:0] s03_msbreg2;

reg [6:0] s00_lsbreg2;
reg [6:0] s01_lsbreg2;
reg [6:0] s02_lsbreg2;
reg [6:0] s03_lsbreg2;

reg [7:0] s10_lsbreg3;
reg [7:0] s11_lsbreg3;

reg [5:0] s00_msbreg3;
reg [5:0] s01_msbreg3;
reg [5:0] s02_msbreg3;
reg [5:0] s03_msbreg3;

reg [6:0] s10_lsbreg4;
reg [6:0] s11_lsbreg4;

reg [6:0] s10_msbreg4;
reg [6:0] s11_msbreg4;

reg [6:0] s10_msbreg5;
reg [6:0] s11_msbreg5;

reg s20_lsbreg5cy;
reg [6:0] s20_lsbreg5;


//first stage addition


//add lsb first where s00_lsb[7} is the carry
assign s00_lsb[7:0] = n0[6:0] + n1[6:0];
assign s01_lsb[7:0] = n2[6:0] + n3[6:0];
assign s02_lsb[7:0] = n4[6:0] + n5[6:0];
assign s03_lsb[7:0] = n6[6:0] + n7[6:0];
//n0 - n7 need not be registered as additon is already carried here

//Pipeline q: clk(1)  Register msb to continue addiotion of msb during clk(2)

always@(posedge clk)
begin

// preserve all lsb sum
	s00_lsbreg1[7:0] <= s00_lsb[7:0];
	s01_lsbreg1[7:0] <= s01_lsb[7:0];
	s02_lsbreg1[7:0] <= s02_lsb[7:0];
	s03_lsbreg1[7:0] <= s03_lsb[7:0];	

	n0_reg1[11:7] <= n0[11:7];
	n1_reg1[11:7] <= n1[11:7];
	n2_reg1[11:7] <= n2[11:7];
	n3_reg1[11:7] <= n3[11:7];
	n4_reg1[11:7] <= n4[11:7];
	n5_reg1[11:7] <= n5[11:7];
	n6_reg1[11:7] <= n6[11:7];
	n7_reg1[11:7] <= n7[11:7];

end


// Sign extend and MSB added with carry

assign s00_msb[5:0] = { n0_reg1[11] , n0_reg1[11:7] } + { n1_reg1[11] , n1_reg1[11:7] } + s00_lsbreg1[7];

assign s01_msb[5:0] = { n2_reg1[11] , n2_reg1[11:7] } + { n3_reg1[11] , n3_reg1[11:7] } + s01_lsbreg1[7];

assign s02_msb[5:0] = { n4_reg1[11] , n4_reg1[11:7] } + { n5_reg1[11] , n5_reg1[11:7] } + s02_lsbreg1[7];

assign s03_msb[5:0] = { n6_reg1[11] , n6_reg1[11:7] } + { n7_reg1[11] , n7_reg1[11:7] } + s03_lsbreg1[7];


// we have ignored s00_msb[6]  


//Pipeline 2: clk(2)  Register msb to continue addition 
always@(posedge clk)
begin

//preserve all msb sum
	s00_msbreg2[5:0] <= s00_msb[5:0];
	s01_msbreg2[5:0] <= s01_msb[5:0];
	s02_msbreg2[5:0] <= s02_msb[5:0];
	s03_msbreg2[5:0] <= s03_msb[5:0];

// preserve all lsb sum
	s00_lsbreg2[6:0] <= s00_lsbreg1[6:0];
	s01_lsbreg2[6:0] <= s01_lsbreg1[6:0];
	s02_lsbreg2[6:0] <= s02_lsbreg1[6:0];
	s03_lsbreg2[6:0] <= s03_lsbreg1[6:0];
end

// Second Stage Addition

// Add lsb first

assign s10_lsb[7:0] = s00_lsbreg2[6:0] + s01_lsbreg2[6:0];
assign s11_lsb[7:0] = s02_lsbreg2[6:0] + s03_lsbreg2[6:0];

//s00 and s01 and s02 and s03 lsb need not be registered as addition is carried out here.

//Pipeline 3 : clk(3)  
always@(posedge clk)
begin

// preserve all lsb sum
	s10_lsbreg3[7:0] <= s10_lsb[7:0];
	s11_lsbreg3[7:0] <= s11_lsb[7:0];

// preserve all msb sum
	s00_msbreg3[5:0] <= s00_msbreg2[5:0];
	s01_msbreg3[5:0] <= s01_msbreg2[5:0];
	s02_msbreg3[5:0] <= s02_msbreg2[5:0];
	s03_msbreg3[5:0] <= s03_msbreg2[5:0];
end

// Add msb of second stage wth the sign bit extension and carry in from lsb
// s10_msb[7] is ignored as it is duplicated sign bit
assign s10_msb[6:0] = { s00_msbreg3[5] , s00_msbreg3[5:0] } + { s01_msbreg3[5] , s01_msbreg3[5:0] } + s10_lsbreg3[7];

assign s11_msb[6:0] = { s02_msbreg3[5] , s02_msbreg3[5:0] } + { s03_msbreg3[5] , s03_msbreg3[5:0] } + s11_lsbreg3[7];


// Pipeline 4: clk(4)

always@(posedge clk)
begin

	
// preserve msb and lsb
	s10_lsbreg4[6:0] <= s10_lsbreg3[6:0] ;
	s11_lsbreg4[6:0] <= s11_lsbreg3[6:0];

	s10_msbreg4[6:0] <= s10_msb[6:0];
	s11_msbreg4[6:0] <= s11_msb[6:0];  // last bit is sign bit

end

// Third Stage Addition

assign s20_lsb[7:0] = s10_lsbreg4[6:0] + s11_lsbreg4[6:0];


// pipeline 5: clk(5)

always@(posedge clk)
begin

//preserving all msb sum
	s10_msbreg5[6:0] <= s10_msbreg4[6:0];
	s11_msbreg5[6:0] <= s11_msbreg4[6:0];
	
// preserve lsb sum and its carry

	s20_lsbreg5cy <= s20_lsb[7];
	s20_lsbreg5  <= s20_lsb[6:0];

end


// add third stage MSB result  nad concatenate with LSB result to get final sum


assign sum[14:0] = { ( { s10_msbreg5[6] , s10_msbreg5[6:0] } + 
		       { s11_msbreg5[6] , s11_msbreg5[6:0] } + 
			 s20_lsbreg5cy ), 
			 s20_lsbreg5[6:0] };

endmodule

