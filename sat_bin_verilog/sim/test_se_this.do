quit -sim
vlib work
vmap work work

vsim -quiet -novopt test_sat_engine_top

# add wave -noupdate -divider {TEST}
# add wave -noupdate sim:/test_clause_array_top/test_clause_array/*
# add wave -noupdate -divider {DUT}
# add wave -noupdate sim:/test_clause_array_top/test_clause_array/clause_array/*

# todo：添加if/else的判断，进行输入的选择
# do ../tools/wave_test_sat_engine_top.do
do wave.do

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
run 4us

# quit -f
