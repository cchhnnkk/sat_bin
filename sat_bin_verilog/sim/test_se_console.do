quit -sim
vlib work
vmap work work

vsim -L D:/Xilinx/14.5_modelsim_10.1/xilinxcorelib_ver -quiet -novopt test_sat_engine_top

# run -all
run 4us

quit -f
