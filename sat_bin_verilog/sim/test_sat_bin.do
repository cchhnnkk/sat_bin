quit -sim
vlib work
vmap work work

vsim -L D:/Xilinx/14.5_modelsim_10.1/xilinxcorelib_ver -quiet -novopt test_sat_bin_top

do ../tools/wave_test_sat_bin_top.do

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 79
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {200 ns}

# run -all
# run 4us
run 32us

# quit -f
