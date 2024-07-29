module romq(clk,a,d);

input clk;
input [5:0] a;
output [7:0] d;


reg [7:0] d;
wire[7:0] d_next;

reg [63:0] mem [7:0]  ; // this is a 8x64 bits memory but it is read byte-by-byte 
reg [7:0] byte_data [7:0]; // 8 register of 64 bit size are created

wire [63:0] mem_data;

wire [63:0] loc0;
wire [63:0] loc1;
wire [63:0] loc2;
wire [63:0] loc3;
wire [63:0] loc4;
wire [63:0] loc5;
wire [63:0] loc6;
wire [63:0] loc7;

//these are inverse quantization values

assign loc0 = 64'hFF806C5D4F4C473C; //there are 64 adresses and total of 8x64 output bits
assign loc1 = 64'h80805D554C473C37; //so each unit of adree gies 8 bits as output
assign loc2 = 64'h6C5D4F4C473C3C36; // 6'd0 addr will give output as 8'hFF
assign loc3 = 64'h5D5D4F4C473C3733;//6'd63 will give output as 8'h19
assign loc4 = 64'h5D4F4C47403B332B;
assign loc5 = 64'h4F4C47403B332B23;
assign loc6 = 64'h4F4C473C362D251E;
assign loc7 = 64'h4C473B362D251E19;

always@(loc0 or loc1 or loc2 or loc3 or loc4 or loc5 or loc6 or loc7)
begin

mem[0] = loc0;
mem[1] = loc1;
mem[2] = loc2;
mem[3] = loc3;
mem[4] = loc4;
mem[5] = loc5;
mem[6] = loc6;
mem[7] = loc7;
end


assign mem_data = mem[a[5:3]];  // choosing the location


//Bytes from each row accessed in raster scan order MSB first
//change of 64 bit into 8 bit annotation
always@(mem_data)
begin

byte_data[0]  =  mem_data[63:56];
byte_data[1]  =  mem_data[55:48];
byte_data[2]  =  mem_data[47:40];
byte_data[3]  =  mem_data[39:32];
byte_data[4]  =  mem_data[31:24];
byte_data[5]  =  mem_data[23:16];
byte_data[6]  =  mem_data[15:8];
byte_data[7]  =  mem_data[7:0];

end

assign d_next = byte_data[a[2:0]];  // choosing the byte from chosen location

always@(posedge clk)

begin

	d <= d_next;
end
endmodule




