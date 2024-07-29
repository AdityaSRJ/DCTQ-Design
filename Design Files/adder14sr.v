
/* 
Adds eight 12 bit numbers , 2's compliment numbers , n0 to n7
Five pipeline stages registered @posedge of clk
Result sum is 15 bit , 2's compliment not registered
*/

module adder14sr(
clk,
n0,n1,n2,n3,n4,n5,n6,n7,
dct
);

input clk;
input [13:0] n0,n1,n2,n3,n4,n5,n6,n7;

output [11:0] dct;

wire [16:0] sum_next;

wire [8:0] s00_lsb;    // sij  where i = stage of addition and j is the number group
wire [8:0] s01_lsb;
wire [8:0] s02_lsb;
wire [8:0] s03_lsb;

wire [6:0] s00_msb;
wire [6:0] s01_msb;
wire [6:0] s02_msb;
wire [6:0] s03_msb;

wire [8:0] s10_lsb;
wire [8:0] s11_lsb;

wire [7:0] s10_msb;
wire [7:0] s11_msb;

wire [8:0] s20_lsb;

reg [13:8] n0_reg1;
reg [13:8] n1_reg1;  //MSB in not computed so its needs to be propogated
reg [13:8] n2_reg1;
reg [13:8] n3_reg1;
reg [13:8] n4_reg1;
reg [13:8] n5_reg1;
reg [13:8] n6_reg1;
reg [13:8] n7_reg1;   


reg [8:0] s00_lsbreg1;
reg [8:0] s01_lsbreg1;
reg [8:0] s02_lsbreg1;
reg [8:0] s03_lsbreg1;

reg [6:0] s00_msbreg2;
reg [6:0] s01_msbreg2;
reg [6:0] s02_msbreg2;
reg [6:0] s03_msbreg2;

reg [7:0] s00_lsbreg2;
reg [7:0] s01_lsbreg2;
reg [7:0] s02_lsbreg2;
reg [7:0] s03_lsbreg2;

reg [8:0] s10_lsbreg3;
reg [8:0] s11_lsbreg3;

reg [6:0] s00_msbreg3;
reg [6:0] s01_msbreg3;
reg [6:0] s02_msbreg3;
reg [6:0] s03_msbreg3;

reg [7:0] s10_lsbreg4;
reg [7:0] s11_lsbreg4;

reg [7:0] s10_msbreg4;
reg [7:0] s11_msbreg4;

reg [7:0] s10_msbreg5;
reg [7:0] s11_msbreg5;


reg [8:0] s20_lsbreg5;
reg [16:0] sum;

wire [11:0] dct;

//first stage addition


//add lsb first where s00_lsb[8] is the carry
assign s00_lsb[8:0] = n0[7:0] + n1[7:0];
assign s01_lsb[8:0] = n2[7:0] + n3[7:0];
assign s02_lsb[8:0] = n4[7:0] + n5[7:0];
assign s03_lsb[8:0] = n6[7:0] + n7[7:0];
//n0 - n7 need not be registered as additon is already carried here

//Pipeline q: clk(1)  Register msb to continue addiotion of msb during clk(2)

always@(posedge clk)
begin

// preserve all lsb sum
	s00_lsbreg1[8:0] <= s00_lsb[8:0];
	s01_lsbreg1[8:0] <= s01_lsb[8:0];
	s02_lsbreg1[8:0] <= s02_lsb[8:0];
	s03_lsbreg1[8:0] <= s03_lsb[8:0];	

	n0_reg1[13:8] <= n0[13:8];
	n1_reg1[13:8] <= n1[13:8];
	n2_reg1[13:8] <= n2[13:8];
	n3_reg1[13:8] <= n3[13:8];
	n4_reg1[13:8] <= n4[13:8];
	n5_reg1[13:8] <= n5[13:8];
	n6_reg1[13:8] <= n6[13:8];
	n7_reg1[13:8] <= n7[13:8];

end


// Sign extend and MSB added with carry

assign s00_msb[6:0] = { n0_reg1[13] , n0_reg1[13:8] } + { n1_reg1[13] , n1_reg1[13:8] } + s00_lsbreg1[8];

assign s01_msb[6:0] = { n2_reg1[13] , n2_reg1[13:8] } + { n3_reg1[13] , n3_reg1[13:8] } + s01_lsbreg1[8];

assign s02_msb[6:0] = { n4_reg1[13] , n4_reg1[13:8] } + { n5_reg1[13] , n5_reg1[13:8] } + s02_lsbreg1[8];

assign s03_msb[6:0] = { n6_reg1[13] , n6_reg1[13:8] } + { n7_reg1[13] , n7_reg1[13:8] } + s03_lsbreg1[8];


// we have ignored s00_msb[7]  as it is duplicated sign bit


//Pipeline 2: clk(2)  Register msb to continue addition 
always@(posedge clk)
begin

//preserve all msb sum
	s00_msbreg2[6:0] <= s00_msb[6:0];
	s01_msbreg2[6:0] <= s01_msb[6:0];
	s02_msbreg2[6:0] <= s02_msb[6:0];
	s03_msbreg2[6:0] <= s03_msb[6:0];

// preserve all lsb sum
	s00_lsbreg2[7:0] <= s00_lsbreg1[7:0];
	s01_lsbreg2[7:0] <= s01_lsbreg1[7:0];
	s02_lsbreg2[7:0] <= s02_lsbreg1[7:0];
	s03_lsbreg2[7:0] <= s03_lsbreg1[7:0];
end

// Second Stage Addition

// Add lsb first

assign s10_lsb[8:0] = s00_lsbreg2[7:0] + s01_lsbreg2[7:0];
assign s11_lsb[8:0] = s02_lsbreg2[7:0] + s03_lsbreg2[7:0];

//s00 and s01 and s02 and s03 lsb need not be registered as addition is carried out here.

//Pipeline 3 : clk(3)  
always@(posedge clk)
begin

// preserve all lsb sum
	s10_lsbreg3[8:0] <= s10_lsb[8:0];
	s11_lsbreg3[8:0] <= s11_lsb[8:0];

// preserve all msb sum
	s00_msbreg3[6:0] <= s00_msbreg2[6:0];
	s01_msbreg3[6:0] <= s01_msbreg2[6:0];
	s02_msbreg3[6:0] <= s02_msbreg2[6:0];
	s03_msbreg3[6:0] <= s03_msbreg2[6:0];
end

// Add msb of second stage wth the sign bit extension and carry in from lsb
// s10_msb[8] is ignored as it is duplicated sign bit
assign s10_msb[7:0] = { s00_msbreg3[6] , s00_msbreg3[6:0] } + { s01_msbreg3[6] , s01_msbreg3[6:0] } + s10_lsbreg3[8];
assign s11_msb[7:0] = { s02_msbreg3[6] , s02_msbreg3[6:0] } + { s03_msbreg3[6] , s03_msbreg3[6:0] } + s11_lsbreg3[8];


// Pipeline 4: clk(4)

always@(posedge clk)
begin

	
// preserve msb and lsb
	s10_lsbreg4[7:0] <= s10_lsbreg3[7:0] ;
	s11_lsbreg4[7:0] <= s11_lsbreg3[7:0];

	s10_msbreg4[7:0] <= s10_msb[7:0];
	s11_msbreg4[7:0] <= s11_msb[7:0];  // last bit is sign bit

end

// Third Stage Addition

assign s20_lsb[8:0] = s10_lsbreg4[7:0] + s11_lsbreg4[7:0];


// pipeline 5: clk(5)

always@(posedge clk)
begin

//preserving all msb sum
	s10_msbreg5[7:0] <= s10_msbreg4[7:0];
	s11_msbreg5[7:0] <= s11_msbreg4[7:0];
	
// preserve lsb sum and its carry

	s20_lsbreg5[8:0]  <= s20_lsb[8:0];   // 8 bit + 1 carry

end

assign sum_next[16:0] = { ( { s10_msbreg5[7] , s10_msbreg5[7:0] } + 
		        {     s11_msbreg5[7] , s11_msbreg5[7:0] } + 
			      s20_lsbreg5[8] ), 
			      s20_lsbreg5[7:0] };

always@(posedge clk)
begin
	sum[16:0] <= sum_next[16:0];
end

assign dct[11:0] = sum[16:5];
endmodule

