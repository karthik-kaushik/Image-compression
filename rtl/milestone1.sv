
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module milestone1 (
   input  logic            CLOCK_50_I,
   input  logic            Resetn,

   input  logic            M1_start,
   output  logic           M1_finish,

   output logic   [17:0]   M1_SRAM_address,
   output logic   [15:0]   M1_SRAM_write_data,
   output logic            M1_SRAM_we_n,
   input logic [15:0]	   SRAM_read_data
);


parameter 	Y_ADDRESS = 18'd0,
				U_ADDRESS = 18'd38400, 
				V_ADDRESS = 18'd57600, 
				RGB_ADDRESS = 18'd146944,

				F_const1 = 5'd21,
				F_const2 = 5'd52,
				F_const3 = 5'd159,

				S_const1 = 'd76284,
				S_const2 = 'd25624,
				S_const3 = 'd132251,
				S_const4 = 'd104595,
				S_const5 = 'd53281;


logic [32:0] Y_OFST_CTR;
logic [32:0] U_OFST_CTR;
logic [32:0] V_OFST_CTR;
logic [32:0] RGB_OFST_CTR;
logic [32:0] CC_ITER;

logic [10:0] row_counter;
logic [9:0] pixel_counter;

logic lead_Out_Interpolation_flag;
logic lead_Out_Y_flag;
logic lead_Out_HARD_flag;
logic lead_Out_START_NEW_ROW;



logic [7:0] Y_even;
logic [7:0] U_even;
logic [7:0] V_even;

logic [7:0] Y_even_buf;
logic [7:0] Y_odd_buf;

logic [7:0] Y_odd;
logic [7:0] U_odd;
logic [7:0] V_odd;

logic [7:0] U_odd_buf;
logic [7:0] V_odd_buf;
logic [7:0] U_even_buf;
logic [7:0] V_even_buf;

logic [64:0] U_Prime_Accum;
logic [64:0] V_Prime_Accum;


logic [64:0] U_Prime_odd_buf;
logic [64:0] V_Prime_odd_buf;

logic [7:0] U_0;
logic [7:0] U_1;
logic [7:0] U_2;
logic [7:0] U_3;
logic [7:0] U_4;
logic [7:0] U_5;

logic [7:0] U_Prime_even_buf;

logic [7:0] V_0;
logic [7:0] V_1;
logic [7:0] V_2;
logic [7:0] V_3;
logic [7:0] V_4;
logic [7:0] V_5;

logic [63:0] RGB_E_ACCUM;
logic [63:0] RGB_O_ACCUM;


logic [63:0] RGB_Buf_E_RED;
logic [63:0] RGB_Buf_E_GREEN;
logic [63:0] RGB_Buf_E_BLUE;
logic [63:0] RGB_Buf_O_RED;
logic [63:0] RGB_Buf_O_GREEN;
logic [63:0] RGB_Buf_O_BLUE;

logic [63:0] RGB_RED_Even;
logic [63:0] RGB_GREEN_Even;
logic [63:0] RGB_BLUE_Even;

logic [63:0] RGB_RED_Odd;
logic [63:0] RGB_GREEN_Odd;
logic [63:0] RGB_BLUE_Odd;

logic [7:0] U_Buf_Even;
logic [7:0] V_Buf_Even;


logic [7:0] U_Buf_Odd;
logic [7:0] V_Buf_Odd;

logic [31:0] Mult1_1;
logic [31:0] Mult1_2;
logic [31:0] Mult2_1;
logic [31:0] Mult2_2;
logic [31:0] Mult3_1;
logic [31:0] Mult3_2;
logic [31:0] Mult4_1;
logic [31:0] Mult4_2;

logic [63:0] Mult1_RL;
logic [63:0] Mult1_out;
logic [63:0] Mult2_RL;
logic [63:0] Mult2_out;
logic [63:0] Mult3_RL;
logic [63:0] Mult3_out;
logic [63:0] Mult4_RL;
logic [63:0] Mult4_out;


//multiplying
assign Mult1_out = Mult1_1*Mult1_2;

assign Mult2_out = Mult2_1*Mult2_2;

assign Mult3_out = Mult3_1*Mult3_2;

assign Mult4_out = Mult4_1*Mult4_2;


logic [7:0] R_clip_even;
logic [7:0] R_clip_odd;

logic [7:0] G_clip_even;
logic [7:0] G_clip_odd;

logic [7:0] B_clip_even;
logic [7:0] B_clip_odd;

logic [7:0] R_clip_even_buf;
logic [7:0] R_clip_odd_buf;

logic [7:0] G_clip_even_buf;
logic [7:0] G_clip_odd_buf;

logic [7:0] B_clip_even_buf;
logic [7:0] B_clip_odd_buf;



assign R_clip_even = RGB_RED_Even[31]? 8'b0 : (|RGB_RED_Even[30:24] ? 8'hFF : RGB_RED_Even[23:16]);
assign R_clip_odd = RGB_RED_Odd[31]? 8'b0 : |RGB_RED_Odd[30:24] ? 8'hFF : RGB_RED_Odd[23:16];

assign G_clip_even = RGB_GREEN_Even[31]? 8'b0 : (|RGB_GREEN_Even[30:24] ? 8'hFF : RGB_GREEN_Even[23:16]);
assign G_clip_odd = RGB_GREEN_Odd[31]? 8'b0 : |RGB_GREEN_Odd[30:24] ? 8'hFF : RGB_GREEN_Odd[23:16];

assign B_clip_even = RGB_BLUE_Even[31]? 8'b0 : |RGB_BLUE_Even[30:24] ? 8'hFF : RGB_BLUE_Even[23:16];
assign B_clip_odd = RGB_BLUE_Odd[31]? 8'b0 : |RGB_BLUE_Odd[30:24] ? 8'hFF : RGB_BLUE_Odd[23:16];
 
 
logic [63:0] Y_16_Buf_Even;
logic [63:0] Y_16_Buf_Odd;
M1_state_type M1_state;


logic finishedHere;


always_ff @ (posedge CLOCK_50_I or negedge Resetn) begin
	if (Resetn == 1'b0) begin
			M1_state <= S_IDLE_M1;

			M1_SRAM_we_n <= 1'b1;
			U_Prime_Accum <= 32'd0;
			V_Prime_Accum <= 32'd0;
			Y_OFST_CTR <= 16'd0;
			U_OFST_CTR <= 15'd0;
			V_OFST_CTR <= 15'd0;
			RGB_OFST_CTR <= 15'd0;
			row_counter <= 8'd0;
			CC_ITER <= 16'd0;
			pixel_counter <= 10'd0;
			M1_SRAM_write_data <= 16'd0;
			M1_SRAM_address <= 18'd0;
			
			Y_16_Buf_Even <= 64'd0;
			Y_16_Buf_Odd <= 64'd0;
			
			Y_even_buf<= 16'd0;
			Y_odd_buf<= 16'd0;
			
			Y_even <= 16'd0;
			Y_odd <= 16'd0;
			U_even <= 16'd0;
			U_odd <= 16'd0;
			V_even <= 16'd0;
			V_odd <= 16'd0;
			
			U_Prime_even_buf<='d0;
			
			RGB_RED_Even<=64'd0;
			RGB_GREEN_Even<=64'd0; 
			RGB_BLUE_Even<=64'd0;

			RGB_RED_Odd<=64'd0;
			RGB_GREEN_Odd<=64'd0;
			RGB_BLUE_Odd<=64'd0;

			
			U_odd_buf<= 16'd0;
			V_odd_buf<= 16'd0;
			U_even_buf<= 16'd0;
			V_even_buf<= 16'd0;

			U_Buf_Even <= 16'd0;
			G_clip_even_buf <= 8'd0;
			
			U_Prime_odd_buf<=64'd0;
			V_Prime_odd_buf<=64'd0;
			
			RGB_Buf_E_RED<= 64'd0;
			RGB_Buf_E_GREEN<= 64'd0;
			RGB_Buf_E_BLUE<= 64'd0;
			RGB_Buf_O_RED<= 64'd0;
			RGB_Buf_O_GREEN<= 64'd0;
			RGB_Buf_O_BLUE<= 64'd0;
			
			RGB_E_ACCUM<= 64'd0;
			RGB_O_ACCUM<= 64'd0;
			RGB_RED_Even<=64'd0;
			RGB_GREEN_Even<=64'd0;
			RGB_BLUE_Even<=64'd0;

			RGB_RED_Odd<=64'd0;
			RGB_GREEN_Odd<=64'd0;
			RGB_BLUE_Odd<=64'd0;
			
			U_0<= 'd0;  
			U_1<= 'd0;  
			U_2<= 'd0;	
			U_3<= 'd0;  	
			U_4<= 'd0;	
			U_5<= 'd0;  
			
			V_0<= 'd0; 
			V_1<= 'd0;	
			V_2<= 'd0;	
			V_3<= 'd0;  
			V_4<= 'd0;	
			V_5<= 'd0;  

			M1_finish <= 1'b0;
			
			finishedHere <= 1'b0;

			end else begin
			case (M1_state)
			S_IDLE_M1: begin
				if(M1_start && !finishedHere)
					M1_state <= S_LEAD_IN_STALL;
			end
			
			S_LEAD_IN_STALL: begin

			
			
			if(row_counter==8'd240 && pixel_counter==1'd0) begin
				M1_SRAM_we_n <= 1'b1;
				finishedHere <= 1'b1;
				M1_finish <= 1'b1;
				M1_state <= S_IDLE_M1;
			end else begin

					M1_SRAM_address <= Y_ADDRESS + Y_OFST_CTR;
					Y_OFST_CTR <= Y_OFST_CTR + 16'd1;

					pixel_counter <= 10'd0;
					
					
			M1_SRAM_we_n <= 1'b1;
			U_Prime_Accum <= 32'd0;
			V_Prime_Accum <= 32'd0;
			
			Y_16_Buf_Even <= 64'd0;
			Y_16_Buf_Odd <= 64'd0;
			
			Y_even_buf<= 16'd0;
			Y_odd_buf<= 16'd0;
			
			Y_even <= 16'd0;
			Y_odd <= 16'd0;
			U_even <= 16'd0;
			U_odd <= 16'd0;
			V_even <= 16'd0;
			V_odd <= 16'd0;
			
			U_Prime_even_buf<='d0;
			
			RGB_RED_Even<=64'd0;
			RGB_GREEN_Even<=64'd0;
			RGB_BLUE_Even<=64'd0;

			RGB_RED_Odd<=64'd0; 
			RGB_GREEN_Odd<=64'd0;
			RGB_BLUE_Odd<=64'd0; 

			
			U_odd_buf<= 16'd0;
			V_odd_buf<= 16'd0;
			U_even_buf<= 16'd0;
			V_even_buf<= 16'd0;

			U_Buf_Even <= 16'd0;
			G_clip_even_buf <= 8'd0;
			
			U_Prime_odd_buf<=64'd0;
			V_Prime_odd_buf<=64'd0;
			
			RGB_Buf_E_RED<= 64'd0;
			RGB_Buf_E_GREEN<= 64'd0; 
			RGB_Buf_E_BLUE<= 64'd0; 
			RGB_Buf_O_RED<= 64'd0; 
			RGB_Buf_O_GREEN<= 64'd0;
			RGB_Buf_O_BLUE<= 64'd0;
			
			RGB_E_ACCUM<= 64'd0;
			RGB_O_ACCUM<= 64'd0;
			RGB_RED_Even<=64'd0;
			RGB_GREEN_Even<=64'd0;
			RGB_BLUE_Even<=64'd0;

			RGB_RED_Odd<=64'd0;
			RGB_GREEN_Odd<=64'd0;
			RGB_BLUE_Odd<=64'd0;
			
			U_0<= 'd0;  
			U_1<= 'd0;  
			U_2<= 'd0;	
			U_3<= 'd0;  	
			U_4<= 'd0;	
			U_5<= 'd0;  
			
			V_0<= 'd0; 
			V_1<= 'd0;	
			V_2<= 'd0;	
			V_3<= 'd0;  
			V_4<= 'd0;	
			V_5<= 'd0;  
			

				M1_state <= S_LEAD_IN_0;
				end
			end
			
			S_LEAD_IN_0: begin 
					M1_SRAM_address <= U_ADDRESS + U_OFST_CTR;
					U_OFST_CTR <= U_OFST_CTR + 16'd1;
			
				M1_state <= S_LEAD_IN_1;
			end
			
			S_LEAD_IN_1: begin
					M1_SRAM_address <= V_ADDRESS + V_OFST_CTR;
					V_OFST_CTR <= V_OFST_CTR + 15'd1;
				M1_state <= S_LEAD_IN_2;

			end
			
			S_LEAD_IN_2: begin 
					M1_SRAM_address <= U_ADDRESS + U_OFST_CTR;
					U_OFST_CTR <= U_OFST_CTR + 15'd1;
					Y_even <= SRAM_read_data[15:8]; 
					Y_odd <= SRAM_read_data[7:0]; 
					M1_state <= S_LEAD_IN_3;

			end
			S_LEAD_IN_3: begin 
					M1_SRAM_address <= V_ADDRESS + V_OFST_CTR;
					V_OFST_CTR<= V_OFST_CTR + 'd1;
					U_even <= SRAM_read_data[15:8];
					U_odd <= SRAM_read_data[7:0];
					
					U_Buf_Even<= SRAM_read_data[15:8];
					U_Buf_Odd<= SRAM_read_data[7:0];
					U_0<= SRAM_read_data[15:8]; 
					U_1<= SRAM_read_data[15:8];
					U_2<= SRAM_read_data[15:8]; 
					U_3<= SRAM_read_data[7:0];
				M1_state <= S_LEAD_IN_4;

			end
			S_LEAD_IN_4: begin 
					M1_SRAM_address <= U_ADDRESS + U_OFST_CTR;
					U_OFST_CTR<= U_OFST_CTR + 'd1;			
					V_0<= SRAM_read_data[15:8];
					V_1<= SRAM_read_data[15:8];
					V_2<= SRAM_read_data[15:8];
					V_3<= SRAM_read_data[7:0];
					V_even <= SRAM_read_data[15:8];
					V_odd <= SRAM_read_data[7:0]; 

					V_Buf_Even<= SRAM_read_data[15:8]; 
					V_Buf_Odd<= SRAM_read_data[7:0];  
					U_Prime_Accum <=  Mult1_out - Mult2_out + Mult3_out + Mult4_out; 
				M1_state <= S_LEAD_IN_5;

			end
			S_LEAD_IN_5:begin
					M1_SRAM_address <= V_ADDRESS + V_OFST_CTR;
					V_OFST_CTR<= V_OFST_CTR + 'd1;
					  U_4<= SRAM_read_data[15:8];
					  U_5<= SRAM_read_data[7:0]; 
					V_Prime_Accum <=  Mult1_out - Mult2_out + Mult3_out + Mult4_out;

					M1_state <= S_LEAD_IN_6;
			end
			S_LEAD_IN_6: begin
					V_even <= SRAM_read_data[15:8];
					V_odd <= SRAM_read_data[7:0];

					V_4<= SRAM_read_data[15:8];
					V_5<= SRAM_read_data[7:0];
					U_Prime_odd_buf <= (U_Prime_Accum - Mult1_out + Mult2_out + 'd128) >> 8;
					U_Prime_Accum<=1'd0;
					M1_state <= S_LEAD_IN_7;
			end
			S_LEAD_IN_7: begin
					U_even <= SRAM_read_data[15:8];
					U_odd <= SRAM_read_data[7:0]; 
					V_Prime_odd_buf<=(V_Prime_Accum-Mult1_out+Mult2_out + 'd128) >> 8; 
					V_Prime_Accum<=1'd0;	
					M1_state <= S_LEAD_IN_8;

			end

			S_LEAD_IN_8: begin 
					V_even <= SRAM_read_data[15:8];
					V_odd <= SRAM_read_data[7:0];
				RGB_Buf_E_RED <= Mult1_out + Mult2_out; 
				RGB_Buf_O_RED<= Mult3_out + Mult4_out; 
				
				RGB_E_ACCUM<=64'd0;
				RGB_O_ACCUM<=64'd0;
						
				Y_16_Buf_Even<=Mult1_out; 
				Y_16_Buf_Odd<=Mult3_out;
				
	 
					M1_state <= S_LEAD_IN_9;
			end
			S_LEAD_IN_9: begin 
					M1_SRAM_address <= U_ADDRESS + U_OFST_CTR; 
					U_OFST_CTR <= U_OFST_CTR + 15'd1;
					
					U_0<=U_1; 
					U_1<=U_2; 
					U_2<=U_3; 
					U_3<=U_4;
					U_4<=U_5; 
					U_5<=U_even; 
					
					V_0<=V_1; 
					V_1<=V_2;
					V_2<=V_3; 
					V_3<=V_4;
					V_4<=V_5; 
					V_5<=V_even; 
					M1_state <= S_LEAD_IN_10;
			end

			S_LEAD_IN_10: begin 
					M1_SRAM_address <= V_ADDRESS + V_OFST_CTR; 
					V_OFST_CTR <= V_OFST_CTR + 15'd1;
				
				RGB_Buf_E_GREEN <=Y_16_Buf_Even- Mult1_out - Mult2_out; //G0
				RGB_Buf_O_GREEN<= Y_16_Buf_Odd- Mult3_out - Mult4_out;  //G1
					M1_state <= S_LEAD_IN_11;

			end
			
			S_LEAD_IN_11: begin
					M1_SRAM_address <= Y_ADDRESS + Y_OFST_CTR; 
					Y_OFST_CTR <= Y_OFST_CTR + 16'd1;
				
				M1_state <= S_LEAD_IN_12;

			end
			
			S_LEAD_IN_12: begin 
				U_even_buf<=SRAM_read_data[15:8];
				U_odd_buf<=SRAM_read_data[7:0];
				U_Prime_Accum <= Mult1_out - Mult2_out + Mult3_out + Mult4_out;

				M1_state <= S_LEAD_IN_13;

			end
			
			S_LEAD_IN_13: begin
			
					V_even_buf<=SRAM_read_data[15:8];
					V_odd_buf<=SRAM_read_data[7:0];
				
					V_Prime_Accum <=  Mult1_out - Mult2_out + Mult3_out + Mult4_out;
					M1_state <= S_LEAD_IN_14;	

			end
					
			S_LEAD_IN_14: begin
					Y_even_buf<=SRAM_read_data[15:8];
					Y_odd_buf<=SRAM_read_data[7:0];
					
					U_Prime_even_buf<=U_2;
					
					U_Prime_Accum<=U_Prime_Accum-Mult1_out; 
					
					V_Prime_Accum<=V_Prime_Accum-Mult2_out; 
					
				RGB_RED_Even<=RGB_Buf_E_RED;
				RGB_GREEN_Even<=RGB_Buf_E_GREEN;

				RGB_RED_Odd<=RGB_Buf_O_RED;
				RGB_GREEN_Odd<=RGB_Buf_O_GREEN;
				
				U_Prime_even_buf<=U_0;
					
					
				M1_state <= S_COMMON_CASE_STALL;
		

			end
					
	S_COMMON_CASE_STALL: begin 

					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
					M1_SRAM_we_n<=1'b0;
					M1_SRAM_write_data <= {R_clip_even, G_clip_even}; 

					U_0<=U_1; 
					U_1<=U_2; 
					U_2<=U_3; 
					U_3<=U_4;
					U_4<=U_5; 
					U_5<=U_odd; 
					
					V_0<=V_1; 
					V_1<=V_2; 
					V_2<=V_3; 
					V_3<=V_4; 
					V_4<=V_5; 
					V_5<=V_odd; 
					
					if(!lead_Out_Interpolation_flag)
					begin
					U_even<=U_even_buf;
					U_odd<=U_odd_buf;
					
					V_even<=V_even_buf;
					V_odd<=V_odd_buf;
					end
					Y_even<=Y_even_buf;
					Y_odd<=Y_odd_buf;

					
					


				U_Prime_odd_buf <= (U_Prime_Accum + Mult1_out + 'd128) >> 8; 
				U_Prime_Accum<='0;

				V_Prime_odd_buf<=(V_Prime_Accum + Mult2_out + 'd128) >> 8; 
				V_Prime_Accum<='0;	

				RGB_Buf_E_BLUE<=(Y_16_Buf_Even+Mult3_out);
				RGB_Buf_O_BLUE<=(Y_16_Buf_Odd+Mult4_out); 
				
				RGB_BLUE_Even<=(Y_16_Buf_Even+Mult3_out);
				RGB_BLUE_Odd<=(Y_16_Buf_Odd+Mult4_out);


				M1_state <= S_COMMON_CASE_0;

			end
			 
	S_COMMON_CASE_0: begin 
				if(!lead_Out_START_NEW_ROW)
				begin
					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
				
					M1_SRAM_write_data <= {B_clip_even, R_clip_odd}; 
					pixel_counter <= pixel_counter + 10'd1;
					M1_SRAM_we_n<=1'b0;
				end
				
					U_Prime_Accum <= Mult1_out; 
					V_Prime_Accum <= Mult2_out; 
			
					
					RGB_E_ACCUM <= Mult3_out;
					RGB_O_ACCUM <= Mult4_out;

					Y_16_Buf_Even <= Mult3_out;
					Y_16_Buf_Odd <= Mult4_out;
				if(lead_Out_START_NEW_ROW)
				begin
					pixel_counter<='d0;
					row_counter<=row_counter+'d1;
					M1_SRAM_we_n<=1'b1;
					M1_state <=S_LEAD_IN_STALL;
				end
					
					M1_state <= S_COMMON_CASE_1;

			end
			
	S_COMMON_CASE_1: begin 
					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
					M1_SRAM_we_n<=1'b0;

	
					M1_SRAM_write_data <= {G_clip_odd, B_clip_odd}; 
					pixel_counter <= pixel_counter + 10'd1;
					

					U_Prime_Accum <= U_Prime_Accum - Mult1_out; 
					V_Prime_Accum <= V_Prime_Accum - Mult2_out; 

					RGB_E_ACCUM<= 64'd0;
					RGB_O_ACCUM<= 64'd0;

					RGB_Buf_E_RED<= (RGB_E_ACCUM + Mult3_out); 
					RGB_Buf_O_RED<= (RGB_O_ACCUM + Mult4_out); 

					M1_state <= S_COMMON_CASE_2;

			end
			
	S_COMMON_CASE_2: begin
		 if(!lead_Out_Y_flag)
			begin
					M1_SRAM_address <= Y_ADDRESS + Y_OFST_CTR;
					Y_OFST_CTR <= Y_OFST_CTR + 16'd1;
					
			end
			M1_SRAM_we_n<=1'b1;
		 
					U_Prime_Accum <= U_Prime_Accum + Mult1_out;
					V_Prime_Accum <= V_Prime_Accum + Mult2_out;
	
					RGB_E_ACCUM<= Y_16_Buf_Even - Mult3_out;
					RGB_O_ACCUM<= Y_16_Buf_Odd - Mult4_out;
					M1_state <= S_COMMON_CASE_3;
			end
	S_COMMON_CASE_3: begin
		 if (!lead_Out_Interpolation_flag)
				begin
					M1_SRAM_address <= U_ADDRESS + U_OFST_CTR;
					U_OFST_CTR <= U_OFST_CTR + 15'd1;
				end
		 
				U_Prime_Accum <= U_Prime_Accum + Mult1_out; 
				V_Prime_Accum <= V_Prime_Accum + Mult2_out; 
				M1_SRAM_we_n<=1'b1;

				RGB_E_ACCUM<= 64'd0;
				RGB_O_ACCUM<= 64'd0;

				RGB_Buf_E_GREEN <= (RGB_E_ACCUM - Mult3_out); 
				RGB_Buf_O_GREEN <= (RGB_O_ACCUM - Mult4_out) ; 
				
				M1_state <= S_COMMON_CASE_4;

			end
	S_COMMON_CASE_4: begin
			if (!lead_Out_Interpolation_flag)
				begin
					M1_SRAM_address <= V_ADDRESS + V_OFST_CTR;
					V_OFST_CTR <= V_OFST_CTR + 15'd1;
				end

			U_Prime_Accum <= U_Prime_Accum - Mult1_out;
			V_Prime_Accum <= V_Prime_Accum - Mult2_out;

			RGB_Buf_E_BLUE<= Y_16_Buf_Even + Mult3_out;
			RGB_Buf_O_BLUE<= Y_16_Buf_Odd + Mult4_out;

			M1_state <= S_COMMON_CASE_5;

		 end
	S_COMMON_CASE_5: begin 
			 if(!lead_Out_Y_flag)
				begin
					M1_SRAM_address <= Y_ADDRESS + Y_OFST_CTR;
					Y_OFST_CTR <= Y_OFST_CTR + 16'd1;
					Y_even<=SRAM_read_data[15:8];
					Y_odd=SRAM_read_data[7:0];
				end
					U_0<=U_1; 
					U_1<=U_2; 
					U_2<=U_3; 
					U_3<=U_4;
					U_4<=U_5; 
					
					if(pixel_counter<310)
					begin
						U_5<=U_even;
						V_5<=V_even;
					end
					else 
					begin
						U_5<=U_odd; 
						V_5<=V_odd; 
					end
					
					
					V_0<=V_1; 
					V_1<=V_2; 
					V_2<=V_3; 
					V_3<=V_4; 
					V_4<=V_5; 
					
					

				RGB_RED_Even<=RGB_Buf_E_RED;
				RGB_GREEN_Even<=RGB_Buf_E_GREEN;
				RGB_BLUE_Even<=RGB_Buf_E_BLUE;

				RGB_RED_Odd<=RGB_Buf_O_RED;
				RGB_GREEN_Odd<=RGB_Buf_O_GREEN;
				RGB_BLUE_Odd<=RGB_Buf_O_BLUE;


			U_Prime_odd_buf <= (U_Prime_Accum + Mult1_out + 'd128) >> 8;
			U_Prime_Accum<='0;

			V_Prime_odd_buf<=(V_Prime_Accum + Mult2_out + 'd128) >> 8;
			V_Prime_Accum<='0;

			M1_state <= S_LEAD_OUT_0;
		 end
	S_LEAD_OUT_0: begin 
	if (!lead_Out_Interpolation_flag)
				begin
					U_even_buf<=SRAM_read_data[15:8];
					U_odd_buf<=SRAM_read_data[7:0];
				end
				
				U_Prime_Accum<= Mult1_out - Mult2_out;
				V_Prime_Accum<= Mult3_out-Mult4_out;
				M1_state <= S_LEAD_OUT_1;

			end
	S_LEAD_OUT_1: begin 

					M1_SRAM_we_n<=1'b1;
		 if (!lead_Out_Interpolation_flag)
				begin
					V_even_buf<=SRAM_read_data[15:8];
					V_odd_buf<=SRAM_read_data[7:0];
				end

				RGB_E_ACCUM<=Mult3_out;
				RGB_O_ACCUM<=Mult4_out;
				Y_16_Buf_Even<=Mult3_out; 
				Y_16_Buf_Odd<=Mult4_out; 
				M1_state <= S_LEAD_OUT_2;

			end
	S_LEAD_OUT_2: begin 
		 if (!lead_Out_Y_flag)
				begin
					Y_even_buf<=SRAM_read_data[15:8];
					Y_odd_buf<=SRAM_read_data[7:0];
				end

					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
					M1_SRAM_we_n<=1'b0;
					M1_SRAM_write_data <= {R_clip_even, G_clip_even};
				U_Prime_Accum<=U_Prime_Accum+Mult1_out;
				V_Prime_Accum<=V_Prime_Accum+Mult2_out;
				
				RGB_E_ACCUM<= 64'd0;
				RGB_Buf_E_RED<=Y_16_Buf_Even+Mult3_out;
				RGB_O_ACCUM<= 64'd0;
				RGB_Buf_O_RED <= Y_16_Buf_Odd+Mult4_out;
			M1_state <= S_LEAD_OUT_3;
			end
	S_LEAD_OUT_3: begin 
					
					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
					M1_SRAM_write_data <= {B_clip_even, R_clip_odd}; 
					M1_SRAM_we_n<=1'b0;
					pixel_counter <= pixel_counter + 10'd1;

				U_Prime_Accum<=U_Prime_Accum+Mult1_out;
				V_Prime_Accum<=V_Prime_Accum+Mult2_out;
			
			RGB_E_ACCUM<=Y_16_Buf_Even-Mult3_out;
			RGB_O_ACCUM<=Y_16_Buf_Odd-Mult4_out;

				M1_state <= S_LEAD_OUT_4;

			  end
	S_LEAD_OUT_4: begin 
					M1_SRAM_address <= RGB_ADDRESS + RGB_OFST_CTR;
					RGB_OFST_CTR <= RGB_OFST_CTR + 'd1;
					M1_SRAM_we_n<=1'b0;
					M1_SRAM_write_data <= {G_clip_odd, B_clip_odd};
					pixel_counter <= pixel_counter + 10'd1;

				U_Prime_even_buf<=U_1;
				U_Prime_Accum<=U_Prime_Accum-Mult1_out;
				V_Prime_Accum<=V_Prime_Accum-Mult2_out;

				RGB_Buf_E_GREEN<=RGB_E_ACCUM-Mult3_out; 
				RGB_Buf_O_GREEN<=RGB_O_ACCUM-Mult4_out; 
				RGB_E_ACCUM<= 64'd0;
				RGB_E_ACCUM<= 64'd0;
				
				RGB_RED_Even<=RGB_Buf_E_RED;
				RGB_GREEN_Even<=RGB_E_ACCUM-Mult3_out;

				RGB_RED_Odd<=RGB_Buf_O_RED;
				RGB_GREEN_Odd<=RGB_O_ACCUM-Mult4_out;  

				CC_ITER <= CC_ITER + 'd1;
				
			
				if(lead_Out_START_NEW_ROW) begin
					pixel_counter<='d0;
					row_counter<=row_counter+'d1;
					M1_state <=S_LEAD_IN_STALL;
				end else 
					M1_state <= S_COMMON_CASE_STALL;
					
					
	 end

			default: M1_state <= S_IDLE_M1;
			
			endcase;
		end
end

always_comb begin
  Mult1_1='d0;
  Mult1_2='d0;

  Mult2_1='d0;
  Mult2_2='d0;

  Mult3_1='d0;
  Mult3_2='d0;

  Mult4_1='d0;
  Mult4_2='d0;
  
	lead_Out_Interpolation_flag= pixel_counter>'d304 ? 1'b1:1'b0; 
	lead_Out_Y_flag= pixel_counter>'d314 ? 1'b1:1'b0; 
	lead_Out_START_NEW_ROW= pixel_counter>'d318 ? 1'b1:1'b0; 
	
	lead_Out_HARD_flag= row_counter>'d238 ? 1'b1:1'b0; 
case(M1_state)


S_LEAD_IN_4: begin 

	Mult1_1=32'd21;
	Mult1_2=U_0;

	Mult2_1=32'd52;
	Mult2_2=U_1;

	Mult3_1=32'd159;
	Mult3_2=U_2;

	Mult4_1=32'd159;
	Mult4_2=U_3;

end

S_LEAD_IN_5:begin 
//
	Mult1_1=32'd21;
	Mult1_2=V_0;

	Mult2_1=32'd52;
	Mult2_2=V_1;

	Mult3_1=32'd159;
	Mult3_2=V_2;

	Mult4_1=32'd159;
	Mult4_2=V_3;
//---

end
S_LEAD_IN_6: begin 

	Mult1_1=32'd52;
	Mult1_2=U_4;

	Mult2_1=32'd21;
	Mult2_2=U_5;
//-----



end
S_LEAD_IN_7: begin

	Mult1_1=32'd52;
	Mult1_2=V_4;

	Mult2_1=32'd21;
	Mult2_2=V_5;



end

S_LEAD_IN_8: begin 

   Mult1_1=32'd76284;
	Mult1_2=Y_even-8'd16;
	
	Mult2_1=32'd104595;
	Mult2_2=V_0-32'd128; 

	Mult3_1=32'd76284;
	Mult3_2=Y_odd-8'd16;

	Mult4_1=32'd104595;
	Mult4_2=V_Prime_odd_buf-32'd128;

end
S_LEAD_OUT_0: begin 
  Mult1_1=32'd21;
  Mult1_2=U_0;

  Mult2_1=32'd52;
  Mult2_2=U_1;

  Mult3_1=32'd21;
  Mult3_2=V_0;

  Mult4_1=32'd52;
  Mult4_2=V_1;

end
S_LEAD_OUT_1: begin 
  Mult3_1=32'd76284;
  Mult3_2=Y_even -32'd16; 

  Mult4_1=32'd76284;
  Mult4_2=Y_odd -32'd16;

end
S_LEAD_OUT_2: begin 
  Mult1_1=32'd159;
  Mult1_2=U_2;

  Mult2_1=32'd159;
  Mult2_2=V_2;

  Mult3_1=32'd104595;
  Mult3_2=V_1-32'd128;

  Mult4_1=32'd104595;
  Mult4_2=V_Prime_odd_buf-32'd128;

end
S_LEAD_OUT_3: begin
  Mult1_1=32'd159;
  Mult1_2=U_3;

  Mult2_1=32'd159;
  Mult2_2=V_3;

  Mult3_1=32'd25624;
  Mult3_2=U_1-32'd128;

  Mult4_1=32'd25624;
  Mult4_2=U_Prime_odd_buf-32'd128;

end
S_LEAD_OUT_4: begin 
  Mult1_1=32'd52;
  Mult1_2=U_4;

  Mult2_1=32'd52;
  Mult2_2=V_4;

  Mult3_1=32'd53281;
  Mult3_2=V_1-32'd128;

  Mult4_1=32'd53281;
  Mult4_2=V_Prime_odd_buf-32'd128;

end
S_LEAD_IN_10: begin 
 	Mult1_1=32'd25624;
  	Mult1_2=U_0- 32'd128;

  	Mult2_1=32'd53281;
  	Mult2_2=V_0-32'd128;
	
	Mult3_1=32'd25624;
  	Mult3_2=U_Prime_odd_buf- 32'd128;

 	Mult4_1=32'd53281;
  	Mult4_2=V_Prime_odd_buf-32'd128;
//----



end
S_LEAD_IN_11: begin 
 	 Mult1_1=32'd132251;
  	Mult1_2=U_2-32'd128;

 	 Mult2_1=32'd132251;
  	Mult2_2=U_Prime_odd_buf-32'd128;


end
S_LEAD_IN_12: begin 
	Mult1_1=32'd21;
	Mult1_2=U_0; 

	Mult2_1=32'd52;
	Mult2_2=U_1; 

	Mult3_1=32'd159;
	Mult3_2=U_2; 

	Mult4_1=32'D159;
	Mult4_2=U_3; 

end
S_LEAD_IN_13: begin 
	Mult1_1=32'd21;
	Mult1_2=V_0; 

	Mult2_1=32'd52;
	Mult2_2=V_1; 

	Mult3_1=32'd159;
	Mult3_2=V_2; 

	Mult4_1=32'd159;
	Mult4_2=V_3; 
end
S_LEAD_IN_14: begin

	Mult1_1=32'd52;
	Mult1_2=U_4; 

	Mult2_1=32'd52;
	Mult2_2=V_4;



end
S_COMMON_CASE_STALL: begin 
	Mult1_1=32'd21;
	Mult1_2=U_5; 

	Mult2_1=32'd21;
	Mult2_2=V_5; 

	Mult3_1=32'd132251;
	Mult3_2=U_1- 32'd128;; 

	Mult4_1=32'd132251;
	Mult4_2=U_Prime_odd_buf- 32'd128;;

end


S_COMMON_CASE_0: begin 
	Mult1_1=32'd21;
	Mult1_2=U_0; 

	Mult2_1=32'd21;
	Mult2_2=V_0; 

	Mult3_1=32'd76284;
	Mult3_2=Y_even-32'd16;

	Mult4_1=32'd76284;
	Mult4_2=Y_odd-32'd16;
end
S_COMMON_CASE_1: begin 
	Mult1_1=32'd52;
	Mult1_2=U_1;

	Mult2_1=32'd52;
	Mult2_2=V_1;

	Mult3_1=32'd104595;
	Mult3_2=V_1 - 32'd128;

	Mult4_1=32'd104595;
	Mult4_2=V_Prime_odd_buf - 32'd128;

end
S_COMMON_CASE_2: begin 
	Mult1_1=32'd159;
	Mult1_2=U_2;

	Mult2_1=32'd159;
	Mult2_2=V_2;

	Mult3_1=32'd25624;
	Mult3_2=U_1- 32'd128;

	Mult4_1=32'd25624;
	Mult4_2=U_Prime_odd_buf - 32'd128;

end
S_COMMON_CASE_3: begin 
	Mult1_1=32'd159;
	Mult1_2=U_3;

	Mult2_1=32'd159;
	Mult2_2=V_3;

	Mult3_1=32'd53281;
	Mult3_2=V_1- 32'd128;

	Mult4_1=32'd53281;
	Mult4_2=V_Prime_odd_buf - 32'd128;

end
S_COMMON_CASE_4: begin 
	Mult1_1=32'd52;
	Mult1_2=U_4;
	Mult2_1=32'd52;
	Mult2_2=V_4;

	Mult3_1=32'd132251;
	Mult3_2=U_1-32'd128;

	Mult4_1=32'd132251;
	Mult4_2=U_Prime_odd_buf-32'd128;

end
S_COMMON_CASE_5: begin
	Mult1_1=32'd21;
	Mult1_2=U_5;

	Mult2_1=32'd21;
	Mult2_2=V_5;


end



endcase

end


endmodule