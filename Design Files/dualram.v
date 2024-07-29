/*
ram1 and ram2 are two dual rams 8x64 bits each

if ram1 is in read only mode then ram2 is automatically configured in write only mode

write ram row wise and read it column wise


*/
`include "ram_rc.v"    // invoked twice to make a dual ram

module dualram(

clk,
pci_clk,
rnw,
be,
ra,
wa,
di,
din_valid,
do

);

input clk;
input pci_clk;
input rnw;


input [7:0] be;

input din_valid; // data_in valid

input [2:0] wa; 
input [2:0] ra;


input [63:0] di;
output [63:0] do;  //data in and out of dual ram

wire switch_bank; 
wire [63:0] do1;
wire [63:0] do2;
wire [63:0] do_next;


reg [63:0] do;
reg rnw_delay;

assign switch_bank = ~rnw;


//configure ram1 and ram2 for read/write mode resp. to start with


ram_rc ram1(   //similar to our module except for the fact that only one ram is invoked
.clk(clk),
.pci_clk(pci_clk),
.rnw(rnw),
.be(be),
.wa(wa),
.ra(ra),
.di(di),
.din_valid(din_valid),
.do(do1)

);

ram_rc ram2(   //similar to our module except for the fact that only one ram is invoked
.clk(clk),
.pci_clk(pci_clk),
.rnw(switch_bank),
.be(be),
.wa(wa),
.ra(ra),
.di(di),
.din_valid(din_valid),
.do(do2)

);


// if rnw = 1  ram1 is configured for write mode and ram2 to read mode
assign do_next = rnw_delay ? do2 : do1;

always@(posedge clk)
begin

	rnw_delay <= rnw; //delay the rnw  signal by one clock to keep pace with output
        do <= do_next;

end // so we are writting and reading simultaneously thats why the delay

endmodule // this top design was only for deciding from which rom to read 




/*
this is a single bock ram called by dualram.v

ram size is 8 locations with width 64 bits

writing is done with row addressing and reading with column

*/

	
	
	




