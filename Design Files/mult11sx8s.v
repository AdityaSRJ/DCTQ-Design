
/*

Signed multiplication of two numbers, n1 (11-bit) & n2(8-bit6)

n1 (Partial product, CX for example ) is ther multiplicand and is signed
n2 (cois term, CT for example) is the signed multiplier

Result (CX)CT is in twos cimpliment

This module has eight pipeline stages to increase the speed, input is not registered


*/

module mult11sx8s(

clk,
n1,
n2,
result
);

input clk;
input [10:0] n1;
input [7:0] n2;
output [18:0] result;

wire n1orn2x;

wire [10:0] p1;
wire [10:0] p2;
wire [10:0] p3;
wire [10:0] p4;
wire [10:0] p5;
wire [10:0] p6;
wire [10:0] p7;
wire [10:0] p8;


wire [6:0] s11a;
wire [6:0] s12a;
wire [6:0] s13a;
wire [6:0] s14a;

wire [5:0] s11b;
wire [5:0] s12b;
wire [5:0] s13b;
wire [5:0] s14b;

wire [12:0] s11;
wire [12:0] s12;
wire [12:0] s13;
wire [12:0] s14;

wire [7:0] s21a;
wire [7:0] s22a;

wire [6:0] s21b;
wire [6:0] s22b;

wire [14:0] s21;
wire [14:0] s22;

wire [8:0] s31a;
wire [7:0] s31b;

wire [17:0] s31;

wire res_sign;
wire [18:0] res;

reg [10:0] n1_mag;
reg [7:0] n2_mag;

reg [10:0] p1_reg1;
reg [10:0] p2_reg1;
reg [10:0] p3_reg1;
reg [10:0] p4_reg1;
reg [10:0] p5_reg1;
reg [10:0] p6_reg1;
reg [10:0] p7_reg1;
reg [10:0] p8_reg1;

reg [6:0] s11a_reg2;
reg [6:0] s12a_reg2;
reg [6:0] s13a_reg2;
reg [6:0] s14a_reg2;

reg n1_reg1;
reg n1_reg2;
reg n1_reg3;
reg n1_reg4;
reg n1_reg5;
reg n1_reg6;
reg n1_reg7;

reg n2_reg1;
reg n2_reg2;
reg n2_reg3;
reg n2_reg4;
reg n2_reg5;
reg n2_reg6;
reg n2_reg7;

reg n1orn2x_reg1;
reg n1orn2x_reg2;
reg n1orn2x_reg3;
reg n1orn2x_reg4;
reg n1orn2x_reg5;
reg n1orn2x_reg6;
reg n1orn2x_reg7;


reg [10:0] p1_reg2;
reg [10:0] p2_reg2;
reg [10:0] p3_reg2;
reg [10:0] p4_reg2;
reg [10:0] p5_reg2;
reg [10:0] p6_reg2;
reg [10:0] p7_reg2;
reg [10:0] p8_reg2;

reg [12:0] s11_reg3;
reg [12:0] s12_reg3;
reg [12:0] s13_reg3;
reg [12:0] s14_reg3;

reg [12:0] s11_reg4;
reg [12:0] s12_reg4;
reg [12:0] s13_reg4;
reg [12:0] s14_reg4;

reg [7:0] s21a_reg4;
reg [7:0] s22a_reg4;

reg [14:0] s21_reg5;
reg [14:0] s22_reg5;

reg [14:0] s21_reg6;
reg [14:0] s22_reg6;

reg [8:0] s31a_reg6;

reg [17:0] s31_reg7;
reg [18:0] result;


// EVALUATE MAGNITUDE THROUGH 2S COMPLIMENT
always@(n1)
begin

	if(n1[10] == 0)
		n1_mag[10:0] = n1[10:0];
	else
		n1_mag[10:0] = ~n1[10:0] + 1;
end

always@(n2)
begin

	if(n2[7] == 0)
		n2_mag[7:0] = n2[7:0];
	else
		n2_mag[7:0] = ~n2[7:0] + 1;
end

// If n1 or n2 is zero make final result 0
assign n1orn2x = ( (n1 == 11'd0) || (n2 == 7'd0) ) ? 1'b1 : 1'b0;

assign p1 = n1_mag[10:0] & { 11{ n2_mag[0] } } ;
assign p2 = n1_mag[10:0] & { 11{ n2_mag[1] } } ;
assign p3 = n1_mag[10:0] & { 11{ n2_mag[2] } } ;
assign p4 = n1_mag[10:0] & { 11{ n2_mag[3] } } ;
assign p5 = n1_mag[10:0] & { 11{ n2_mag[4] } } ;
assign p6 = n1_mag[10:0] & { 11{ n2_mag[5] } } ;
assign p7 = n1_mag[10:0] & { 11{ n2_mag[6] } } ;
assign p8 = n1_mag[10:0] & { 11{ n2_mag[7] } } ;


//FIRST PIPELINE clk(1)

always@(posedge clk)
begin

	p1_reg1[10:0] <= p1[10:0];
	p2_reg1[10:0] <= p2[10:0];
	p3_reg1[10:0] <= p3[10:0];
	p4_reg1[10:0] <= p4[10:0];
	p5_reg1[10:0] <= p5[10:0];
	p6_reg1[10:0] <= p6[10:0];
	p7_reg1[10:0] <= p7[10:0];
	p8_reg1[10:0] <= p8[10:0];

	n1_reg1 <= n1[10];
	n2_reg1 <= n2[7];
	n1orn2x_reg1 <= n1orn2x;

end

// Evaluate LSB partial sum

assign s11a[6:0] = p1_reg1[6:1] + p2_reg1[5:0];
assign s12a[6:0] = p3_reg1[6:1] + p4_reg1[5:0];
assign s13a[6:0] = p5_reg1[6:1] + p6_reg1[5:0];
assign s14a[6:0] = p7_reg1[6:1] + p8_reg1[5:0];

// p1_reg[0] will be p[rocessed at the next clk

//  PIPELINE 2 :ckl(2)

always@(posedge clk)
begin

//Store the LSB Partial sum
	s11a_reg2[6:0] <= s11a[6:0];
	s12a_reg2[6:0] <= s12a[6:0];
	s13a_reg2[6:0] <= s13a[6:0];
	s14a_reg2[6:0] <= s14a[6:0];

// Store the MSB partial products

	p1_reg2[10:7] <= p1_reg1[10:7];
	p2_reg2[10:6] <= p2_reg1[10:6];
	p3_reg2[10:7] <= p3_reg1[10:7];
	p4_reg2[10:6] <= p4_reg1[10:6];
	p5_reg2[10:7] <= p5_reg1[10:7];
	p6_reg2[10:6] <= p6_reg1[10:6];
	p7_reg2[10:7] <= p7_reg1[10:7];
	p8_reg2[10:6] <= p8_reg1[10:6];

//Store the 0th bit since it is not yet processed
	p1_reg2[0] <= p1_reg1[0];
	p3_reg2[0] <= p3_reg1[0];
	p5_reg2[0] <= p5_reg1[0];
	p7_reg2[0] <= p7_reg1[0];

// Aslo store the sifn bit and zero status

	n1_reg2 <= n1_reg1;
	n2_reg2 <= n2_reg1;
	n1orn2x_reg2 <= n1orn2x_reg1;
end

// Add MSB along woth carry bit


assign s11b[5:0] = {1'b0 , p1_reg2[10:7]} + p2_reg2[10:6] + s11a_reg2[6];
assign s12b[5:0] = {1'b0 , p3_reg2[10:7]} + p4_reg2[10:6] + s12a_reg2[6];
assign s13b[5:0] = {1'b0 , p5_reg2[10:7]} + p6_reg2[10:6] + s13a_reg2[6];
assign s14b[5:0] = {1'b0 , p7_reg2[10:7]} + p8_reg2[10:6] + s14a_reg2[6];



// Concatenate MSB and LSB


assign s11[12:0] = { s11b[5:0] , s11a_reg2[5:0] , p1_reg2[0]};
assign s12[12:0] = { s12b[5:0] , s12a_reg2[5:0] , p3_reg2[0]};
assign s13[12:0] = { s13b[5:0] , s13a_reg2[5:0] , p5_reg2[0]};
assign s14[12:0] = { s14b[5:0] , s14a_reg2[5:0] , p7_reg2[0]};


// THIRD STAGE PIPELINING clk(3)

always@(posedge clk) 
begin


	s11_reg3[12:0] <= s11[12:0];
	s12_reg3[12:0] <= s12[12:0];
	s13_reg3[12:0] <= s13[12:0];
	s14_reg3[12:0] <= s14[12:0];

	n1_reg3 <= n1_reg2;
	n2_reg3 <= n2_reg2;
	n1orn2x_reg3 <= n1orn2x_reg2;

end


// Evlauate the second stage LSB SUM
assign s21a[7:0] = s11_reg3[8:2] + s12_reg3[6:0];
assign s22a[7:0] = s13_reg3[8:2] + s14_reg3[6:0];



//FOURTH STAGE PIPELINING clk(4)
always@(posedge clk)
begin

//Store second stage LSB partial sum
	s21a_reg4[7:0] <= s21a[7:0];
	s22a_reg4[7:0] <= s22a[7:0];

// Store bits not yet processed
	s11_reg4[12:9] <= s11_reg3[12:9];
	s12_reg4[12:7] <= s12_reg3[12:7];
	s13_reg4[12:9] <= s13_reg3[12:9];	
	s14_reg4[12:7] <= s14_reg3[12:7];

	s11_reg4[1:0] <= s11_reg3[1:0];
	s13_reg4[1:0] <= s13_reg3[1:0];
	
	n1_reg4 <= n1_reg3;
	n2_reg4 <= n2_reg3;
	n1orn2x_reg4 <= n1orn2x_reg3;

end


// Add second stage MSB with carry

assign s21b[6:0] = {2'b0 , s11_reg4[12:9]} + s12_reg4[12:7] + s21a_reg4[7];
assign s22b[6:0] = {2'b0 , s13_reg4[12:9]} + s14_reg4[12:7] + s22a_reg4[7];

// Concatenate

assign s21[14:0] = { s21b[5:0] , s21a_reg4[6:0] , s11_reg4[1:0] };
assign s22[14:0] = { s22b[5:0] , s22a_reg4[6:0] , s13_reg4[1:0] };

// Result will never affect s21b[6] which is always 0


// FIFTH STAGE PIPLINING clk(5)

always@(posedge clk)
begin

	s21_reg5[14:0] <= s21[14:0];
	s22_reg5[14:0] <= s22[14:0];

	n1_reg5 <= n1_reg4;
	n2_reg5 <= n2_reg4;
	n1orn2x_reg5 <= n1orn2x_reg4;

end


// 3rd stage LSB SUM computed here

assign s31a[8:0] = s21_reg5[11:4] + s22_reg5[7:0];

// SIXTH PIPELINE clk(6)
always@(posedge clk)
begin
	s31a_reg6[8:0] <= s31a[8:0];

	s21_reg6[14:12] <= s21_reg5[14:12];
	s22_reg6[14:8]  <= s22_reg5[14:8];

	s21_reg6[3:0] <= s21_reg5[3:0];

	n1_reg6 <= n1_reg5;
	n2_reg6 <= n2_reg5;
	n1orn2x_reg6 <= n1orn2x_reg5;
end

assign s31b[7:0] = { 4'b0 , s21_reg6[14:12] } + s22_reg6[14:8] + s31a_reg6[8];

assign s31[17:0] = {s31b[5:0] , s31a_reg6[7:0] , s21_reg6[3:0]};

// Note that 3rd stage result will never affect s31b[6:5]  which is always 0


//SEVENTH PIPELINE STAGE clk(70
always@(posedge clk)
begin
	n1_reg7 <= n1_reg6;
	n2_reg7 <= n2_reg6;

	s31_reg7[17:0] <= s31[17:0];
	n1orn2x_reg7 <= n1orn2x_reg6;

end

assign res_sign = n1_reg7 ^ n2_reg7;

assign res[18:0] = res_sign  ? {1'b1 , (~s31_reg7 + 1)} : { 1'b0 , s31_reg7};

//EIGHTH STAGE PIPELINE clk(8)

always@(posedge clk)
begin
	if(n1orn2x_reg7 == 1'b1)
		result[18:0] <= 19'b0;

	else
		result[18:0] <= res[18:0];  // final result in twos compliment
end

endmodule
