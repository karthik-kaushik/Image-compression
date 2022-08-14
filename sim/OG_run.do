
# set up paths, top-level module, ...
do setenv.do

# compile the source files
do compile.do

# specify library for simulation
vsim -t 100ps -L altera_mf_ver -lib my_work t$tb/b_project

#vsim -t 100ps -L altera_mf_ver -lib rtl_work $tb/tb_project_v2
# Clear previous simulation
restart -f

# add signals to waveform
do waves.do

# run simulation
run -all

do save.do

# print simulation statistics
# simstats

