

# add waves to waveform

add wave -divider {Top-level signals}
add wave Clock_50
add wave -decimal uut/top_state
add wave -decimal uut/M1_finish
add wave -unsigned uut/SRAM_address
add wave -unsigned uut/M1_unit/M1_state
add wave -unsigned uut/SRAM_read_data
add wave -hexadecimal uut/SRAM_write_data
add wave uut/SRAM_we_n

add wave -hexadecimal uut/M1_unit/R_clip_even
add wave -hexadecimal uut/M1_unit/G_clip_even
add wave -hexadecimal uut/M1_unit/B_clip_even



add wave -divider {RGB Signals To Write}



add wave -unsigned uut/M1_unit/U_Prime_odd_buf
add wave -unsigned uut/M1_unit/V_Prime_odd_buf


add wave -divider {M1 State}
add wave -unsigned uut/M1_unit/M1_state

add wave -divider {Lead Out Flags}
add wave -decimal uut/M1_unit/lead_Out_Y_flag
add wave -decimal uut/M1_unit/lead_Out_Interpolation_flag
add wave -decimal uut/M1_unit/lead_Out_START_NEW_ROW
add wave -decimal uut/M1_unit/lead_Out_HARD_flag

add wave -divider {Y Values}
add wave -hexadecimal uut/M1_unit/Y_even;
add wave -hexadecimal uut/M1_unit/Y_odd;
add wave -hexadecimal uut/M1_unit/Y_even_buf;
add wave -hexadecimal uut/M1_unit/Y_odd_buf;

add wave -divider {U and V Values}
add wave -hexadecimal uut/M1_unit/U_even;
add wave -hexadecimal uut/M1_unit/U_even_buf;
add wave -hexadecimal uut/M1_unit/U_odd;
add wave -hexadecimal uut/M1_unit/U_odd_buf;
add wave -hexadecimal uut/M1_unit/V_even;
add wave -hexadecimal uut/M1_unit/V_even_buf;
add wave -hexadecimal uut/M1_unit/V_odd;
add wave -hexadecimal uut/M1_unit/V_odd_buf;

add wave -divider {U Value Shift Registers}
add wave -hexadecimal uut/M1_unit/U_0;
add wave -hexadecimal uut/M1_unit/U_1;
add wave -hexadecimal uut/M1_unit/U_2;
add wave -hexadecimal uut/M1_unit/U_3;
add wave -hexadecimal uut/M1_unit/U_4;
add wave -hexadecimal uut/M1_unit/U_5;

add wave -divider {V Value Shift Registers}
add wave -hexadecimal uut/M1_unit/V_0;
add wave -hexadecimal uut/M1_unit/V_1;
add wave -hexadecimal uut/M1_unit/V_2;
add wave -hexadecimal uut/M1_unit/V_3;
add wave -hexadecimal uut/M1_unit/V_4;
add wave -hexadecimal uut/M1_unit/V_5;



