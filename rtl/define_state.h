`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_M1_top
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [5:0] {
	S_IDLE_M1,
	S_LEAD_IN_STALL,
	S_LEAD_IN_0,
	S_LEAD_IN_1,
	S_LEAD_IN_2,
	S_LEAD_IN_3,
	S_LEAD_IN_4,
	S_LEAD_IN_5,
	S_LEAD_IN_6,
	S_LEAD_IN_7,
	S_LEAD_IN_8,
	S_LEAD_IN_9,
	S_LEAD_IN_10,
	S_LEAD_IN_11,
	S_LEAD_IN_12,
	S_LEAD_IN_13,
	S_LEAD_IN_14,
	S_LEAD_IN_15,
	S_LEAD_IN_16,
	S_LEAD_IN_17,
	S_COMMON_CASE_0,
	S_COMMON_CASE_1,
	S_COMMON_CASE_2,
	S_COMMON_CASE_3,
	S_COMMON_CASE_4,
	S_COMMON_CASE_5,
	S_LEAD_OUT_0,
	S_LEAD_OUT_1,
	S_LEAD_OUT_2,
	S_LEAD_OUT_3,
	S_LEAD_OUT_4,
	S_LEAD_OUT_5,
	S_HARD_LEAD_OUT_0,
	S_HARD_LEAD_OUT_1,
	S_HARD_LEAD_OUT_2,
	S_COMMON_CASE_STALL
} M1_state_type;  


typedef enum logic [5:0] {
	S_IDLE_M2,
	S_LEAD_M2_1
} M2_state_type; 

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
