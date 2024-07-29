/*

This is the top level design module for the computation of DCTQ.

DCTQ prepares the groud for effective compression of data, especially that from images, be it still or 
motion pictures.

2D-DCTQ is a simple two stage multiplication of three 8x8 matrices. C,X,CT.

Input of DCTQ is a block  (8x8 pixels) of image information.

DCT produces 64 coefficents.
The first coefficient is reffered to as DC coeff. while all others are AC coeff.

*/
`include "ram_rc.v"
`include "dualram.v"

`include "adder12s.v"
`include "adder14sr.v"
`include "dctreg2x8xn.v"
`include "mult8ux8s.v"
`include "mult11sx8s.v"
`include "mult12sx8u.v"
`include "romc.v"
`include "romq.v"
`include "dctq_controller.v"


module dctq(

pci_clk,
clk,
reset_n,
start,
di,
din_valid,
wa,
be,
hold,
ready,
dctq,
dctq_valid,
addr

);


input pci_clk;
input clk;
input reset_n;
input start;
input[63:0] di;
input din_valid;
input[2:0] wa;
input[7:0] be;
input hold;

output ready;
output[8:0] dctq;
output dctq_valid;
output[5:0] addr;

wire ready;
wire [8:0] dctq;
wire dctq_valid;
wire [5:0] addr;

wire rnw;
wire encnt2;


wire [15:0] result1;
wire [15:0] result2;
wire [15:0] result3;
wire [15:0] result4;
wire [15:0] result5;
wire [15:0] result6;
wire [15:0] result7;
wire [15:0] result8;

wire [14:0] sum1;
wire [11:0] dct;

wire[63:0] do;
wire[63:0] d1;
wire[63:0] d2;

wire[10:0] qr0;
wire[10:0] qr1;
wire[10:0] qr2;
wire[10:0] qr3;
wire[10:0] qr4;
wire[10:0] qr5;
wire[10:0] qr6;
wire[10:0] qr7;


wire [18:0] res1;
wire [18:0] res2;
wire [18:0] res3;
wire [18:0] res4;
wire [18:0] res5;
wire [18:0] res6;
wire [18:0] res7;
wire [18:0] res8;

wire [5:0] cnt1_reg;
wire [2:0] cnt2_reg;
wire [2:0] cnt3_reg;
wire [5:0] cnt4_reg;


wire [7:0] qout;


// A good practice is that you should not have logic on your main top design module only calling of all submodules.
// Thus we see no registered outputs.

//Dual RAM to read image input block (8x8pixels) by block. This is X matrix.

dualram dualram1(

.clk(clk),
.pci_clk(pci_clk),
.rnw(rnw),
.be(be),
.ra(cnt1_reg[2:0]), // LSB stores the columns of X Matrix and MSB stores the rows of C Matrix
.wa(wa),		// We advance to the nect row of C only after processing eight colmun-elements of X
.di(di),
.din_valid(din_valid),
.do(do)

);

// Dual RAM has two pipeline registers, one after ram_rc and the other at the output of dualram


// The following module is a ROM storing 2C and 2CT - two times inorder to improve accuracy. We divide it by 2 later.

// C and CT are accessed simultaneously.
// Both require row accesses for computation of DCT as CT matrix will be the multiplier matrix.

romc romc1(

.clk(clk),
.addr1(cnt1_reg[5:3]),
.addr2(cnt3_reg[2:0]),
.dout1(d1),   // C Matrix
.dout2(d2)    // CT Matrix

);

// romc.v also has 2 pipeline registors to keep pace with dualram


// addr1 and addr2 are for fetching C and CT matrices. C is used in the first stage multiplication , U11-U18
// while CT is used in the second stage multiplication, U21-U28.


// CX is computed using follwing eight multipliers. do is the image input X(accessed column wise)
// d1 is the C input. 
// do is unsigned while d1 is signed. Result is in 2s compliment.

mult8ux8s u11(

.clk(clk),
.n1(do[63:56]),
.n2(d1[63:56]),
.result(result1)  // 16 bit signed

);

mult8ux8s u12(

.clk(clk),
.n1(do[55:48]),
.n2(d1[55:48]),
.result(result2)  // 16 bit signed

);

mult8ux8s u13(

.clk(clk),
.n1(do[47:40]),
.n2(d1[47:40]),
.result(result3)  // 16 bit signed

);

mult8ux8s u14(

.clk(clk),
.n1(do[39:32]),
.n2(d1[39:32]),
.result(result4)  // 16 bit signed

);

mult8ux8s u15(

.clk(clk),
.n1(do[31:24]),
.n2(d1[31:24]),
.result(result5)  // 16 bit signed

);

mult8ux8s u16(

.clk(clk),
.n1(do[23:16]),
.n2(d1[23:16]),
.result(result6)  // 16 bit signed

);

mult8ux8s u17(

.clk(clk),
.n1(do[15:8]),
.n2(d1[15:8]),
.result(result7)  // 16 bit signed

);

mult8ux8s u18(

.clk(clk),
.n1(do[7:0]),
.n2(d1[7:0]),
.result(result8)  // 16 bit signed

);


// Partial products of CX are added here

adder12s adder12s1(

.clk(clk),
.n0(result1[15:4]),		// 12 bit signed numbers ie precision is reduced         
.n1(result2[15:4]),		// five pipeline stages- sum not registered 
.n2(result3[15:4]),		
.n3(result4[15:4]),
.n4(result5[15:4]),
.n5(result6[15:4]),
.n6(result7[15:4]),
.n7(result8[15:4]),
.sum(sum1)
);

dctreg2x8xn#(11) dctreg1(

.clk(clk),
.din(sum1[14:4]),  // 11 bit signed integer-dropping 3 bits after decimal pt.
		   // C was actually stored as 2C so dropped LSB or right shifted whih is same as dividing by 2.
		   // Same for CT
.wa(cnt2_reg[2:0]),  // we have eight registers qr0-qr7
.enreg(encnt2),
.qr0(qr0),
.qr1(qr1),
.qr2(qr2),
.qr3(qr3),
.qr4(qr4),
.qr5(qr5),
.qr6(qr6),	// 11 bit signed
.qr7(qr7)
);


// 11 bit signed Partial sum of CX , 8 bit singed CT , result 19bits signed
mult11sx8s u21(

.clk(clk),
.n1(qr0),
.n2(d2[63:56]),
.result(res1)

);

mult11sx8s u22(

.clk(clk),
.n1(qr1),
.n2(d2[55:48]),
.result(res2)

);

mult11sx8s u23(

.clk(clk),
.n1(qr2),
.n2(d2[47:40]),
.result(res3)

);

mult11sx8s u24(

.clk(clk),
.n1(qr3),
.n2(d2[39:32]),
.result(res4)

);

mult11sx8s u25(

.clk(clk),
.n1(qr4),
.n2(d2[31:24]),
.result(res5)

);

mult11sx8s u26(

.clk(clk),
.n1(qr5),
.n2(d2[23:16]),
.result(res6)

);

mult11sx8s u27(

.clk(clk),
.n1(qr6),
.n2(d2[15:8]),
.result(res7)

);

mult11sx8s u28(

.clk(clk),
.n1(qr7),
.n2(d2[7:0]),
.result(res8)

);

adder14sr adder14sr1(

.clk(clk),
.n0( res1[18:5] ),   // 4 bits to be dropped + 1 right shift
.n1( res2[18:5] ),
.n2( res3[18:5] ),
.n3( res4[18:5] ),
.n4( res5[18:5] ),
.n5( res6[18:5] ),
.n6( res7[18:5] ),
.n7( res8[18:5] ),
.dct(dct[11:0])     //12bit signed

);


// This adder has 6 stage pipeline stages


// Quantization Stage - 64B ROM 

romq romq1(

.clk(clk),
.a(cnt4_reg),
.d(qout)
);

// 16/quantization value provided by romq
mult12sx8u u31(

.clk(clk),
.n1(dct[11:0]),
.n2(qout),
.dctq(dctq)

);

// n1 is DCT signed 12 bit integer
// n2 is unsigned 8 bit-decimal point before MSB
// 16/quantization value is multiplied with the DCT output above to get final DCTQ output.
// Result is divided by 16 in the mult12sx8u module to get 9 bit dctq


// dctq[8:0] confimrs to JPEG MPEG standards

/*

dctq_valid is assreted whenever dctq is valid and addr porvides the address of the coefficient

*/


//FOLLOWING IS THE DCTQ CONTROLLER

dctq_controller dctq_control1(

.clk(clk),
.reset_n(reset_n),
.start(start),
.hold(hold),
.ready(ready),
.rnw(rnw),
.dctq_valid(dctq_valid),
.encnt2(encnt2),
.cnt1_reg(cnt1_reg),
.cnt2_reg(cnt2_reg),
.cnt3_reg(cnt3_reg),
.cnt4_reg(cnt4_reg),
.addr(addr)              //this is essentially cnt5_reg[5:0]

);


endmodule


