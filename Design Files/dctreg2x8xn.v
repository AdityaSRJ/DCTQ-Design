/*

a set of 8 11 bit registers to store the partial products p , of CX matrix

*/


module dctreg2x8xn(clk , wa , din, enreg, qr0, qr1, qr2, qr3, qr4, qr5, qr6, qr7);

parameter WIDTH = 11;    // size of registers - programable

output[ (WIDTH-1) : 0]  qr0, qr1, qr2, qr3, qr4, qr5, qr6, qr7;

input[ (WIDTH-1) : 0] din;
input [2:0] wa;

input enreg , clk;

reg[ (WIDTH-1) : 0] qr0, qr1, qr2, qr3, qr4, qr5, qr6, qr7; 
reg[ (WIDTH-1) : 0] q0, q1, q2, q3, q4, q5, q6; 

always@(posedge clk)
begin
	
	if(enreg)
	begin
		case(wa)
		3'b000 : q0 <= din;
		3'b001 : q1 <= din;
		3'b010 : q2 <= din;
		3'b011 : q3 <= din;
		3'b100 : q4 <= din;
		3'b101 : q5 <= din;
		3'b110 : q6 <= din;
		3'b111 : begin
				qr0 <= q0;
				qr1 <= q1;
				qr2 <= q2;
				qr3 <= q3;
				qr4 <= q4;
				qr5 <= q5;
				qr6 <= q6;
				qr7 <= din;
			end
		endcase
	end
end
endmodule
			
