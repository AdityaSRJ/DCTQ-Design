/*

This is the test bench to test the DCTQ Design.
Input image is  lena.txt. Change it for processng different image.

dctq.txt is the DCTQ output fo the image, lena.txt

*/
`timescale 1ns/100ps
`define clkperiodby2 5		//Both clocks operate at 100MHz
`define pci_clkperiodby2 5
`define NUM_BLKS 1024     	// Total pixels 256x256
				// one block 8x8 pixels
				// Total blocks = 1024 
`include "dctq.v"

module dctq_test;

reg pci_clk;
reg clk;
reg reset_n;
reg start;

reg hold;
reg din_valid;

reg [63:0] di;
reg [2:0] wa;
reg [7:0] be;

wire ready;
wire dctq_valid;
wire [8:0] dctq;
wire [5:0] addr;

wire stopproc;

reg eob;
wire [10:0] eobcnt_next;
reg  [10:0] eobcnt_reg;
reg start_din;  // to start dctq  processing

integer i;  // keeps track of the current number of blocks processed
integer fp1; // points the dctq output file.

reg [63:0] mem[8191:0];    // Memory to store one frame 
			  // one frame = 256 x 256 pixels = 256 x 256 x 8 bits = 64 x 8192 bits

//reg check;
reg [12:0] mem_addr; // 13 bits to address 8192 bits

dctq dctq1(

.pci_clk(pci_clk),
.clk(clk),
.reset_n(reset_n),
.di(di),
.din_valid(din_valid),
.wa(wa),
.be(be),
.hold(hold),
.start(start),
.ready(ready),
.dctq(dctq),
.dctq_valid(dctq_valid),
.addr(addr)

);

initial 
begin

$readmemh("lena.txt" , mem);  // mem receives the input iae frame lena.txt

fp1 = $fopen("dctq.txt");

	pci_clk = 0;
	clk = 0;
	reset_n = 1;
	start = 0;
	di = 0;
	din_valid = 0;
	wa = 0;
	be = 8'hff;
	hold = 0;
	//check = 0;

	mem_addr = 0;
	start_din = 1'b0;
	i = `NUM_BLKS;

#20	reset_n = 0;
#40	reset_n = 1'b1;
#10        start_din = 1'b1;

#700000

$fclose(fp1);
$stop;

end

always
	#`clkperiodby2 clk <= ~clk;

always
	#`pci_clkperiodby2 pci_clk <= ~pci_clk;


always@(start_din or i or clk or pci_clk or reset_n or wa or mem_addr)

begin

	if(start_din == 1'b1)
	begin		
		@(posedge pci_clk)
			if(i != 0)
			begin				
				@(posedge pci_clk);
				#1;
				   din_valid = 1'b1;
				   wa = 0;
				   di = mem[mem_addr]; // first row of image block
				   mem_addr = mem_addr + 1;

			
				repeat(7)
				begin
					@(posedge pci_clk);
					#1 ;
			   		din_valid = 1;
			   		wa = wa +1;
			   		di = mem[mem_addr];
			   		mem_addr = mem_addr  + 1;
				end
	
				@(posedge pci_clk);
				#1;
				din_valid = 0;
				wait(ready);   // wait for ready to go high
				@(posedge clk)
				#1 start = 1'b1; // Start the DCTQ processor after inputting the image block data
			                          // and when ready signal is hogh. 

	   			i = i - 1;
	 		end

			else
			begin
		//check = 1'b1;
				wait(eobcnt_reg == `NUM_BLKS);
		
				$fclose(fp1);
				$stop;
			end

	end
end


assign stopproc =( ( eobcnt_reg ==`NUM_BLKS-1 ) && ( eob== 1'b1 ) ) ? 1'b1 : 1'b0 ; 
// Condition to stop DCTQ processing. 


always @ (posedge clk) 
begin 

	if(dctq_valid == 1'b1) 
	begin 
		if (stopproc == 1'b0) // Means, the process has not stopped. 
		$fdisplay(fp1,"%h", dctq) ;  // DCTQ coefficients are written into
					     // the ?dctq? output file every time the DCTQ 
					     // is valid. Don?t write into ?dctq.txt? file 
	end				     // when all the coefficients are already written.
end						


always @ (posedge clk or negedge reset_n)
begin
	if(reset_n ==0)
		eob <= 1'b0;

	else if(addr == 6'd63)
		eob <= 1'b1;      // eob is issued when the last coefficent is bloc k is processed

	else
		eob <= 1'b0;
end


assign eobcnt_next = eobcnt_reg +1 ;   // count the number of blocks processed

always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 1'b0)
		eobcnt_reg <= 0;

	else if(eob == 1'b1)
		eobcnt_reg <= eobcnt_next;
end

endmodule

	
		




	



