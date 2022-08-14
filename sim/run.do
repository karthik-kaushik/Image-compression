set rtl ../rtl
set tb ../tb
set sim .
set top TB

onbreak {resume}

transcript on

if {[file exists my_work]} {
	vdel -lib my_work -all
}

vlib my_work
vmap work my_work


vlog -sv -work my_work +define+DISABLE_DEFAULT_NET +define+SIMULATION $rtl/SRAM_Controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/PB_Controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/VGA_Controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/convert_hex_to_seven_segment.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET +define+SIMULATION $rtl/UART_Receive_Controller.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/UART_SRAM_interface.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/VGA_SRAM_interface.sv

vlog -sv -work my_work +define+DISABLE_DEFAULT_NET +define+SIMULATION $rtl/project.sv
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $rtl/milestone1.sv

vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/tb_project.v
vlog -sv -work my_work +define+DISABLE_DEFAULT_NET $tb/tb_SRAM_Emulator.sv



vsim -t 100ps -L altera_mf_ver -lib my_work tb_project

restart -f

do waves.do

configure wave -signalnamewidth 1

run -all

# print simulation statistics
# simstats