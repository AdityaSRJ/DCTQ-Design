
/*

Signed multiplication of two numbers, n1 (8-bit) & n2(8-bit)

n1  is unsigned
n2 signed multiplier

Result (CX)CT is in twos cimpliment

This module has eight pipeline stages to increase the speed, input is not registered


*/

module mult8ux8s(

clk,
n1,
n2,
result
);

input clk;
input [7:0] n1;
input [7:0] n2;
output [15:0] result;

wire n1orn2x;

wire [7:0] p1;
wire [7:0] p2;
wire [7:0] p3;
wire [7:0] p4;
wire [7:0] p5;
wire [7:0] p6;
wire [7:0] p7;
wire [7:0] p8;


wire [4:0] s11a;
wire [4:0] s12a;
wire [4:0] s13a;
wire [4:0] s14a;

wire [4:0] s11b;
wire [4:0] s12b;
wire [4:0] s13b;
wire [4:0] s14b;

wire [9:0] s11;
wire [9:0] s12;
wire [9:0] s13;
wire [9:0] s14;

wire [5:0] s21a;
wire [5:0] s22a;

wire [5:0] s21b;
wire [5:0] s22b;

wire [11:0] s21;
wire [11:0] s22;

wire [6:0] s31a;
wire [6:0] s31b;

wire [14:0] s31;

wire res_sign;
wire [15:0] res;

reg [7:0] n1_mag;
reg [7:0] n2_mag;

reg [7:0] p1_reg1;
reg [7:0] p2_reg1;
reg [7:0] p3_reg1;
reg [7:0] p4_reg1;
reg [7:0] p5_reg1;
reg [7:0] p6_reg1;
reg [7:0] p7_reg1;
reg [7:0] p8_reg1;

reg [4:0] s11a_reg2;
reg [4:0] s12a_reg2;
reg [4:0] s13a_reg2;
reg [4:0] s14a_reg2;

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


reg [7:0] p1_reg2;
reg [7:0] p2_reg2;
reg [7:0] p3_reg2;
reg [7:0] p4_reg2;
reg [7:0] p5_reg2;
reg [7:0] p6_reg2;
reg [7:0] p7_reg2;
reg [7:0] p8_reg2;

reg [9:0] s11_reg3;
reg [9:0] s12_reg3;
reg [9:0] s13_reg3;
reg [9:0] s14_reg3;

reg [5:0] s21a_reg4;
reg [5:0] s22a_reg4;

reg [9:0] s11_reg4;
reg [9:0] s12_reg4;
reg [9:0] s13_reg4;
reg [9:0] s14_reg4;

reg [11:0] s21_reg5;
reg [11:0] s22_reg5;

reg [11:0] s21_reg6;
reg [11:0] s22_reg6;

reg [6:0] s31a_reg6;

reg [14:0] s31_reg7;
reg [15:0] result;


// EVALUATE MAGNITUDE THROUGH 2S COMPLIMENT



always@(n1)
begin

/*
	if(n1[10] == 0)
		n1_mag[10:0] = n1[10:0];
	else
		n1_mag[10:0] = ~n1[10:0] + 1;

*/
	n1_mag[7:0] <= n1[7:0];
end



always@(n2)
begin

	if(n2[7] == 0)
		n2_mag[7:0] <= n2[7:0];
	else
		n2_mag[7:0] <= ~n2[7:0] + 1;
end

// If n1 or n2 is zero make final result 0
assign n1orn2x = ( (n1 == 8'd0) || (n2 == 8'd0) ) ? 1'b1 : 1'b0;

assign p1 = n1_mag[7:0] & { 8{ n2_mag[0] } } ;
assign p2 = n1_mag[7:0] & { 8{ n2_mag[1] } } ;
assign p3 = n1_mag[7:0] & { 8{ n2_mag[2] } } ;
assign p4 = n1_mag[7:0] & { 8{ n2_mag[3] } } ;
assign p5 = n1_mag[7:0] & { 8{ n2_mag[4] } } ;
assign p6 = n1_mag[7:0] & { 8{ n2_mag[5] } } ;
assign p7 = n1_mag[7:0] & { 8{ n2_mag[6] } } ;
assign p8 = n1_mag[7:0] & { 8{ n2_mag[7] } } ;


//FIRST PIPELINE clk(1)

always@(posedge clk)
begin

	p1_reg1[7:0] <= p1[7:0];
	p2_reg1[7:0] <= p2[7:0];
	p3_reg1[7:0] <= p3[7:0];
	p4_reg1[7:0] <= p4[7:0];
	p5_reg1[7:0] <= p5[7:0];
	p6_reg1[7:0] <= p6[7:0];
	p7_reg1[7:0] <= p7[7:0];
	p8_reg1[7:0] <= p8[7:0];

	n1_reg1 <= 0;  // n1 always positive
	n2_reg1 <= n2[7];
	n1orn2x_reg1 <= n1orn2x;

end

// Evaluate LSB partial sum  4 bit + 4 bit

assign s11a[4:0] = p1_reg1[4:1] + p2_reg1[3:0];
assign s12a[4:0] = p3_reg1[4:1] + p4_reg1[3:0];
assign s13a[4:0] = p5_reg1[4:1] + p6_reg1[3:0];
assign s14a[4:0] = p7_reg1[4:1] + p8_reg1[3:0];

// p1_reg[0] will be p[rocessed at the next clk

//  PIPELINE 2 :ckl(2)

always@(posedge clk)
begin

//Store the LSB Partial sum
	s11a_reg2[4:0] <= s11a[4:0];
	s12a_reg2[4:0] <= s12a[4:0];
	s13a_reg2[4:0] <= s13a[4:0];
	s14a_reg2[4:0] <= s14a[4:0];

// Store the MSB partial products

	p1_reg2[7:5] <= p1_reg1[7:5];
	p2_reg2[7:4] <= p2_reg1[7:4];

	p3_reg2[7:5] <= p3_reg1[7:5];
	p4_reg2[7:4] <= p4_reg1[7:4];

	p5_reg2[7:5] <= p5_reg1[7:5];
	p6_reg2[7:4] <= p6_reg1[7:4];

	p7_reg2[7:5] <= p7_reg1[7:5];
	p8_reg2[7:4] <= p8_reg1[7:4];

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


assign s11b[4:0] = {1'b0 , p1_reg2[7:5]} + p2_reg2[7:4] + s11a_reg2[4];
assign s12b[4:0] = {1'b0 , p3_reg2[7:5]} + p4_reg2[7:4] + s12a_reg2[4];
assign s13b[4:0] = {1'b0 , p5_reg2[7:5]} + p6_reg2[7:4] + s13a_reg2[4];
assign s14b[4:0] = {1'b0 , p7_reg2[7:5]} + p8_reg2[7:4] + s14a_reg2[4];



// Concatenate MSB and LSB                                                  // MSB 5 bits 
                                                                            // LSB 4 bits  and 1 leftover bit
                                                                             
assign s11[9:0] = { s11b[4:0] , s11a_reg2[3:0] , p1_reg2[0]};
assign s12[9:0] = { s12b[4:0] , s12a_reg2[3:0] , p3_reg2[0]};
assign s13[9:0] = { s13b[4:0] , s13a_reg2[3:0] , p5_reg2[0]};
assign s14[9:0] = { s14b[4:0] , s14a_reg2[3:0] , p7_reg2[0]};


// THIRD STAGE PIPELINING clk(3)

always@(posedge clk) 
begin


	s11_reg3[9:0] <= s11[9:0];
	s12_reg3[9:0] <= s12[9:0];
	s13_reg3[9:0] <= s13[9:0];
	s14_reg3[9:0] <= s14[9:0];

	n1_reg3 <= n1_reg2;
	n2_reg3 <= n2_reg2;
	n1orn2x_reg3 <= n1orn2x_reg2;

end


// Evlauate the second stage LSB SUM
assign s21a[5:0] = s11_reg3[6:2] + s12_reg3[4:0];  // 5bit + 5 bit
assign s22a[5:0] = s13_reg3[6:2] + s14_reg3[4:0];



//FOURTH STAGE PIPELINING clk(4)
always@(posedge clk)
begin

//Store second stage LSB partial sum
	s21a_reg4[5:0] <= s21a[5:0];
	s22a_reg4[5:0] <= s22a[5:0];

// Store bits not yet processed
	s11_reg4[9:7] <= s11_reg3[9:7];
	s12_reg4[9:5] <= s12_reg3[9:5];

	s13_reg4[9:7] <= s13_reg3[9:7];	
	s14_reg4[9:5] <= s14_reg3[9:5];

	s11_reg4[1:0] <= s11_reg3[1:0];
	s13_reg4[1:0] <= s13_reg3[1:0];
	
	n1_reg4 <= n1_reg3;
	n2_reg4 <= n2_reg3;
	n1orn2x_reg4 <= n1orn2x_reg3;

end


// Add second stage MSB with carry

assign s21b[5:0] = {2'b0 , s11_reg4[9:7]} + s12_reg4[9:5] + s21a_reg4[5];
assign s22b[5:0] = {2'b0 , s13_reg4[9:7]} + s14_reg4[9:5] + s22a_reg4[5];

// Concatenate

assign s21[11:0] = { s21b[4:0] , s21a_reg4[4:0] , s11_reg4[1:0] };  // 5 + 5 + 2
assign s22[11:0] = { s22b[4:0] , s22a_reg4[4:0] , s13_reg4[1:0] };

// Result will never affect s21b[5] which is always 0


// FIFTH STAGE PIPLINING clk(5)

always@(posedge clk)
begin

	s21_reg5[11:0] <= s21[11:0];
	s22_reg5[11:0] <= s22[11:0];

	n1_reg5 <= n1_reg4;
	n2_reg5 <= n2_reg4;
	n1orn2x_reg5 <= n1orn2x_reg4;

end


// 3rd stage LSB SUM computed here

assign s31a[6:0] = s21_reg5[9:4] + s22_reg5[5:0];

// SIXTH PIPELINE clk(6)
always@(posedge clk)
begin
	s31a_reg6[6:0] <= s31a[6:0];

	s21_reg6[11:10] <= s21_reg5[11:10];
	s22_reg6[11:6]  <= s22_reg5[11:6];

	s21_reg6[3:0] <= s21_reg5[3:0];

	n1_reg6 <= n1_reg5;
	n2_reg6 <= n2_reg5;
	n1orn2x_reg6 <= n1orn2x_reg5;
end

assign s31b[6:0] = { 4'b0 , s21_reg6[11:10] } + s22_reg6[11:6] + s31a_reg6[6];

assign s31[14:0] = {s31b[4:0] , s31a_reg6[5:0] , s21_reg6[3:0]}; //5+ 6 + 4

// Note that 3rd stage result will never affect s31b[6:5]  which is always 0


//SEVENTH PIPELINE STAGE clk(70
always@(posedge clk)
begin
	n1_reg7 <= n1_reg6;
	n2_reg7 <= n2_reg6;

	s31_reg7[14:0] <= s31[14:0];
	n1orn2x_reg7 <= n1orn2x_reg6;

end

assign res_sign = n1_reg7 ^ n2_reg7;  //0^n2_reg7

assign res[15:0] = res_sign  ? {1'b1 , (~s31_reg7 + 1)} : { 1'b0 , s31_reg7};

//EIGHTH STAGE PIPELINE clk(8)

always@(posedge clk)
begin
	if(n1orn2x_reg7 == 1'b1)
		result[15:0] <= 15'b0;

	else
		result[15:0] <= res[15:0];  // final result in twos compliment
end

endmodule