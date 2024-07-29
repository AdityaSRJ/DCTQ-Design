odule romc(clk , addr1 , addr2 , dout1 , dout2);

input clk;
input [2:0] addr1;
input [2:0] addr2;
output [63:0] dout1;
output [63:0] dout2;

reg [63:0] dout1_next; // this is the next value that will be loaded in dout1_reg1
reg [63:0] dout2_next; 

/* 
as it is a 2 level pipeling at the first posedge dou1_reg1 get the value 
of dout_next and at the next posedge we get tyhe actual output
*/
reg [63:0] dout1_reg1;
reg [63:0] dout2_reg1;
reg [63:0] dout1;
reg [63:0] dout2;     

wire [63:0] loc0;
wire [63:0] loc1;
wire [63:0] loc2;
wire [63:0] loc3;
wire [63:0] loc4;
wire [63:0] loc5;
wire [63:0] loc6;
wire [63:0] loc7;

// content of 8 addresses
assign loc0 = 64'h5B5B5B5B5B5B5B5B;
assign loc1 = 64'h7E6A4719E7B99682;
assign loc2 = 64'h7631CF8A8ACF3176;
assign loc3 = 64'h6AE782B9477E1996;
assign loc4 = 64'h5BA5A55B5BA5A55B;
assign loc5 = 64'h4782196A96E77EB9;
assign loc6 = 64'h318A76CFCF768A31;
assign loc7 = 64'h19B96A827E9647E7;

always@(loc0 or loc1 or loc2 or loc3 or loc4 or loc5 or loc6 or loc7 or addr1 or addr2)
begin

	case(addr1)
		3'b000 : dout1_next = loc0;
		3'b001 : dout1_next = loc1;
		3'b010 : dout1_next = loc2;
		3'b011 : dout1_next = loc3;
		3'b100 : dout1_next = loc4;
		3'b101 : dout1_next = loc5;
		3'b110 : dout1_next = loc6;
		3'b111 : dout1_next = loc7;
		default : dout1_next = loc0;
	endcase

	case(addr2)
		3'b000 : dout2_next = loc0;
		3'b001 : dout2_next = loc1;
		3'b010 : dout2_next = loc2;
		3'b011 : dout2_next = loc3;
		3'b100 : dout2_next = loc4;
		3'b101 : dout2_next = loc5;
		3'b110 : dout2_next = loc6;
		3'b111 : dout2_next = loc7;
		default : dout2_next = loc0;
	endcase
end

//first pipline

always@(posedge clk)
begin
	
	dout1_reg1 <= dout1_next;
	dout2_reg1 <= dout2_next;
end

//second pipeline

always@(posedge clk)
begin

	dout1 <= dout1_reg1;
	dout2 <= dout2_reg1;

end

endmodule

	




