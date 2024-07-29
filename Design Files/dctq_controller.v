module dctq_controller(

clk,
reset_n,
start,
hold,
ready,
rnw,
dctq_valid,
encnt2,
cnt1_reg,
cnt2_reg,
cnt3_reg,
cnt4_reg,
addr
);

input clk;
input reset_n;
input start;
input hold;

output ready;
output rnw;
output encnt2;
output dctq_valid;

output [5:0] cnt1_reg;
output [2:0] cnt2_reg;
output [2:0] cnt3_reg;
output [5:0] cnt4_reg;

output [5:0] addr;


reg ready;
reg rnw;
reg dctq_valid;

reg dctq_valid_prev;

reg start_reg1;

reg cnt_0;

reg [5:0] cnt1_reg;
reg [2:0] cnt2_reg;
reg [2:0] cnt3_reg;
reg [5:0] cnt4_reg;
reg [5:0] addr;

reg encnt1;
reg encnt2;
reg encnt3;
reg encnt4;
reg encnt5;



wire start_next1;
wire encnt1_next;
wire discnt1_next;

wire swrnw1;
wire swrnw2;
wire swon_ready;

wire [5:0] cnt1_next;
wire [5:0] cnt2_next;
wire [5:0] cnt3_next;
wire [5:0] cnt4_next;
wire [5:0] cnt5_next;

assign cnt1_next = cnt1_reg + 1;
assign cnt2_next = cnt2_reg + 1;
assign cnt3_next = cnt3_reg + 1;
assign cnt4_next = cnt4_reg + 1;
assign cnt5_next = addr + 1;

assign encnt1_next  = ( ( start_reg1 == 1'b1 ) && ( cnt1_reg == 0 ) ) ? 1'b1 : 1'b0;

assign discnt1_next = ( ( start_reg1 == 1'b0 ) && ( cnt1_reg == 6'd63 ) ) ? 1'b1 : 1'b0;



always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		encnt1 <= 1'b0;

	else if(hold == 1'b1)
		encnt1 <= encnt1;

	else if(encnt1_next == 1'b1)
		encnt1 <= 1'b1;

	else if(discnt1_next == 1'b1)
		encnt1 <= 0;

	else
		encnt1 <= encnt1;
end


always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		encnt2 <= 1'b0;

	else if(hold == 1'b1)
		encnt2 <= encnt2;

	else if(discnt1_next == 1'b1)
		encnt2 <= 0;

	else if(cnt1_reg == 6'd14)
		encnt2 <= 1'b1;     // cnt2 is enabled when cnt1_reg = 14dec

	else
		encnt2 <= encnt2;
end


always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		encnt3 <= 1'b0;

	else if(hold == 1'b1)
		encnt3 <= encnt3;

	else if(discnt1_next == 1'b1)
		encnt3 <= 0;

	else if(cnt1_reg == 6'd20)
		encnt3 <= 1'b1;     // cnt3 is enabled when cnt1_reg = 20dec
				    // since ROM CT has 2 pipeline stages
	else
		encnt3 <= encnt3;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		encnt4 <= 1'b0;

	else if(hold == 1'b1)
		encnt4 <= encnt4;

	else if(discnt1_next == 1'b1)
		encnt4 <= 0;

	else if(cnt1_reg == 6'd35)
		encnt4 <= 1'b1;     // cnt4 is enabled when cnt1_reg = 35 dec

	else
		encnt4 <= encnt4;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		encnt5 <= 1'b0;

	else if(hold == 1'b1)
		encnt5 <= encnt5;

	else if(discnt1_next == 1'b1)
		encnt5 <= 0;

	else if(cnt1_reg == 6'd44)
		encnt5 <= 1'b1;     // cnt5 is enabled when cnt1_reg = 44dec
					// 45 pipeline stagfes
	else
		encnt5 <= encnt5;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		cnt1_reg <= 6'd0;

	else if(hold == 1'b1)
		cnt1_reg <= cnt1_reg;

	else if(encnt1 == 1'b1)
		cnt1_reg <= cnt1_next;

	else
		cnt1_reg <= cnt1_reg;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		cnt2_reg <= 6'd0;

	else if(hold == 1'b1)
		cnt2_reg <= cnt2_reg;

	else if(encnt2 == 1'b1)
		cnt2_reg <= cnt2_next;

	else
		cnt2_reg <= cnt2_reg;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		cnt3_reg <= 6'd0;

	else if(hold == 1'b1)
		cnt3_reg <= cnt3_reg;

	else if(encnt3 == 1'b1)
		cnt3_reg <= cnt3_next;

	else
		cnt3_reg <= cnt3_reg;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		cnt4_reg <= 6'd0;

	else if(hold == 1'b1)
		cnt4_reg <= cnt4_reg;

	else if(encnt4 == 1'b1)
		cnt4_reg <= cnt4_next;

	else
		cnt4_reg <= cnt4_reg;
end

always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		addr <= 6'd0;

	else if(hold == 1'b1)
		addr <= addr;

	else if(encnt5 == 1'b1)
		addr <= cnt5_next;

	else
		addr <= addr;
end

assign swrnw1 = ( ( start_reg1 == 1'b1 ) && ( cnt1_reg == 0 ) && ( cnt_0 == 1'b1 ) ) ? 1'b1 : 1'b0;
assign swrnw2 = ( ( start_reg1 == 1'b1 ) && ( cnt1_reg == 6'd63 ) ) ? 1'b1 : 1'b0;

// swrnw1 is to differentiate between very first blck and other bolcks
// swrnw2 is to identify end of blck
always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 1'b0)
	begin
		cnt_0 <= 1'b1;
		rnw <= 1'b1;
	end

	else if(hold == 1'b1)
		rnw <= rnw;

	else if(swrnw1)
	begin
		cnt_0 <= 1'b0;
		rnw <= !rnw;
	end

	else if(swrnw2)
		rnw<= !rnw;

	else
		rnw <= rnw;

end

assign swon_ready = ( ( start_reg1 == 1'b1 ) && ( cnt1_reg == 6'd01 ) ) ? 1'b1 : 1'b0;
// THis implies that we have already processed DCTQ for previous block and have started the current block.
always@(posedge clk or negedge reset_n)
begin

	if(reset_n == 1'b0)
		ready <= 1'b1;

	else if(hold == 1'b1)
		ready<= ready;

	else if(swon_ready)
		ready <= 1'b1;

	else
		ready <= !start_reg1;
end


always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 1'b0)
	begin
		dctq_valid_prev <= 1'b0;
		dctq_valid <= 1'b0;
	end

	else if(hold ==1'b1)
		dctq_valid <= 1'b0;

	else if(cnt1_reg == 6'd44)   //dctq is valid from cnt1_reg = 44 onwards
	begin
		dctq_valid <= 1'b1;
		dctq_valid_prev <= 1'b1;
	end

	else if(hold == 1'b0)
		dctq_valid <= dctq_valid_prev;

	else
		dctq_valid <= dctq_valid;
end

assign start_next1 = ( start == 1'b1 )&&( cnt1_reg == 0 );

always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 0)
		start_reg1 <= 1'b0;

	else if(hold == 1'b1)
		start_reg1 <= start_reg1;

	else if(start_next1)
		start_reg1 <= 1'b1;

	else if( (start == 1'b0) && (cnt1_reg ==6'd62) ) // nearing the end of dctq processing
		start_reg1 <= 1'b0;

	else
		start_reg1 <= start_reg1;
end


endmodule