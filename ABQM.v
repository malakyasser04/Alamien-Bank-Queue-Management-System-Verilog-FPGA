
module posege_detector(siginal,clk,out);
input siginal;
input clk;
output out;
reg signal_delay;
always @(posedge clk)begin

signal_delay<=siginal;
end
assign out=siginal &~signal_delay;
endmodule





module clock_divider1 ( clk , reset , slow_clk);
input clk, reset ;
output slow_clk;
reg slow_clk;
reg [24:0] count ;
always @( posedge clk or posedge reset )
	begin
		if( reset )
			begin
			count <= 0;
			slow_clk <= 0;
			end
		else
			begin
		if( count < 25_000_000 )
			count <= count + 1 ; 
		else 
			begin
			slow_clk = ~slow_clk ; 
			count <= 0 ;
			end
		end
	end		

endmodule


module FF(clk,d,q);
input clk,d;
output reg q;
	always @ (posedge clk)
		q<=d;
endmodule



module decoder_7seg (A, B, C, D, led_a, led_b, led_c, led_d, led_e, led_f, led_g);

input A, B, C, D;

output led_a, led_b, led_c, led_d, led_e, led_f,led_g;

assign led_a = ~(A |C | B&D | ~B&~D);

assign led_b = ~(~B | ~C&~D | C&D);

assign led_c = ~(B | ~C | D);

assign led_d = ~(~B&~D | C&~D | B&~C&D | ~B&C |A);

assign led_e = ~(~B&~D | C&~D);

assign led_f = ~(A | ~C&~D | B&~C | B&~D);

assign led_g = ~(A | B&~C | ~B&C | C&~D);

endmodule





module up_down_counter (input clk, reset,up,down, output reg [2:0] counter );



always @(posedge clk or posedge reset)begin

if(reset)begin
 counter <= 0;
end else if(up && ~down && counter!=3'b111) begin 
 counter <= counter + 1;
end else if(down && ~up && counter!=3'b000) begin
 counter <= counter - 1;
end 
end

endmodule



module FSM(clk, reset,counter, up,down, full, empty);
input clk, reset, up,down;
input wire [2:0] counter;
reg [2:0] state;
output reg full, empty;
parameter 	s0 = 3'b000, 
		s1 = 3'b001,
		s2 = 3'b010, 
		s3 = 3'b011, 
		s4 = 3'b100; 

always @(posedge clk or posedge reset) begin

begin
if(reset)
begin
state = 0;
empty = 1;
full = 0;
end
else
begin


case(state)
s0: 	
	if(up && ~down) 
		begin
		state = s1; 
		end

s1: 	
	if(counter == 7)  
		begin
		state = s4; 
		full = 1;
		empty = 0;
		end
	else 		
		begin
		state = s2; 
		full = 0;
		empty = 0;
		end

s2:	
	if(up && ~down) 
		begin
		state = s1; 
		end
	else if (down)	
		begin
		state = s3; 
		end

s3:	
	if(counter == 0)  
		begin
		state = s0; 
		full = 0;
		empty = 1;
		end
	else 		
		begin
		state = s2; 
		full = 0;
		empty = 0;
		end
s4:	
	if(down && ~up)
		begin
		state = s3; 
		end


default :state=s0;
endcase 

end

end
end

endmodule
module ROM (clk,pcount, tcount, wtime);
input clk;
input [2:0] pcount;
input [1:0] tcount;
output reg [4:0] wtime;
wire [4:0] rom;

assign rom = {tcount,pcount};
  always @(posedge clk )
    begin
      case(rom)       
        5'b01_000 : wtime <= 5'b00000;
        5'b01_001 : wtime <= 5'b00011; 
        5'b01_010 : wtime <= 5'b00110; 
        5'b01011 : wtime <= 5'b00100; 
        5'b01100 : wtime <= 5'b01110; 
        5'b01101 : wtime <= 5'b01111; 
        5'b01110 : wtime <= 5'b10010; 
        5'b01111 : wtime <= 5'b10101; 
        
        5'b10000 : wtime <= 5'b00000; 
        5'b10001 : wtime <= 5'b00011; 
        5'b10010 : wtime <= 5'b00100; 
        5'b10011 : wtime <= 5'b00110; 
        5'b10100 : wtime <= 5'b01001; 
        5'b10101 : wtime <= 5'b01010; 
        5'b10110 : wtime <= 5'b01100; 
        5'b10111 : wtime <= 5'b00110; 
        
        5'b11000 : wtime <= 5'b00000; 
        5'b11001 : wtime <= 5'b00011; 
        5'b11010 : wtime <= 5'b00100; 
        5'b11011 : wtime <= 5'b00101; 
        5'b11100 : wtime <= 5'b00110; 
        5'b11101 : wtime <= 5'b00111; 
        5'b11110 : wtime <= 5'b01000;
        5'b11111 : wtime <= 5'b01001; 
        default : wtime <= 5'b00000; 
endcase
end
endmodule



module topcounter(clk,reset,up,down,ledC,full,empty, Tcount,ledW,ledW2);
input clk;
input reset;
input up;
input down;
output wire [6:0] ledC;
output wire full;
output wire empty;
output wire [6:0] ledW;
output wire [6:0] ledW2;
input [1:0] Tcount;
wire [2:0] counter;

wire[4:0] wtime;


wire slow_clk; 
wire d_down;
wire d_up;

clock_divider1 dut ( clk , reset , slow_clk);
FF fdut(slow_clk,down,d_down);
FF fdut1(slow_clk,up,d_up);
up_down_counter dutc (slow_clk, reset,up,down, counter );
FSM dutfsm(slow_clk, reset,counter, up,down, full, empty);

ROM romdut(slow_clk,counter, Tcount, wtime);

decoder_7seg seg(1'b0, counter[2], counter[1], counter[0], ledC[6], ledC[5], ledC[4], ledC[3], ledC[2], ledC[1], ledC[0]);

wire [3:0]digit1=wtime%10;

wire [3:0] digit2=wtime/10;

decoder_7seg seg1(digit1[3], digit1[2], digit1[1], digit1[0], ledW[6], ledW[5], ledW[4], ledW[3], ledW[2], ledW[1], ledW[0]);

decoder_7seg seg2(digit2[3], digit2[2], digit2[1], digit2[0], ledW2[6], ledW2[5], ledW2[4], ledW2[3], ledW2[2], ledW2[1], ledW2[0]);




endmodule





module topcounterTest(clk,reset,up,down,ledC,full,empty, Tcount,ledW,ledW2,counter,wtime);
input clk;
input reset;
input up;
input down;
output wire [6:0] ledC;
output wire full;
output wire empty;
output wire [6:0] ledW;
output wire [6:0] ledW2;


input [1:0] Tcount;
output wire [2:0] counter;

output wire[4:0] wtime;



wire d_down;
wire d_up;
FF fdut2(clk,down,d_down);
FF fdut3(clk,up,d_up);
posege_detector d_ed(d_down,clk,d_out);
posege_detector d_ed1(d_up,clk,up_out);
up_down_counter dutc1 (clk, reset,up,down, counter );
FSM dutfsm1(clk, reset,counter, up,down, full, empty);

ROM romdut1(clk,counter, Tcount, wtime);

decoder_7seg segt(1'b0, counter[2], counter[1], counter[0], ledC[6], ledC[5], ledC[4], ledC[3], ledC[2], ledC[1], ledC[0]);

wire [3:0]digit1=wtime%10;

wire [3:0] digit2=wtime/10;

decoder_7seg seg1(digit1[3], digit1[2], digit1[1], digit1[0], ledW[6], ledW[5], ledW[4], ledW[3], ledW[2], ledW[1], ledW[0]);

decoder_7seg seg2(digit2[3], digit2[2], digit2[1], digit2[0], ledW2[6], ledW2[5], ledW2[4], ledW2[3], ledW2[2], ledW2[1], ledW2[0]);




endmodule


module test_ABQM();

reg clk, reset,up,down;
reg [1:0] Tcount;
wire full,empty;
wire [4:0] wtime;
wire [2:0] counter;
wire [6:0] ledC;
wire [6:0] ledW;
wire [6:0] ledW2;
topcounterTest tb(clk,reset,up,down,ledC,full,empty, Tcount,ledW,ledW2,counter,wtime);




initial begin 
clk=0;
forever #5 clk=~clk;
end


 initial
  begin 
  clk = 0;
  reset = 1;
  up=1;
 down=0;
 Tcount=1;


 #5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
 #5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
 #5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;
#5; reset = 0; up = 1; down=0; Tcount=1;
#5; reset = 0; up = 0; down=0; Tcount=1;



#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
#5; reset = 0; up = 0; down=1; Tcount=2;
#5; reset = 0; up = 0; down=0; Tcount=2;
 




end 
endmodule







