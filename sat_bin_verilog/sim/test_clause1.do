quit -sim
# rm wlf*
vlib work
vmap work work

# vlog -sv ../src/sat_engine/clause_array/lit1.v
# vlog -sv ../src/sat_engine/clause_array/lits.v
# vlog -sv ../src/sat_engine/clause_array/terminal_cell.v
# vlog -sv ../src/sat_engine/clause_array/clause1.v
# vlog -sv ../tb/class_clause_data.sv
# vlog -sv ../tb/class_lvl_data.sv
# vlog -sv ../tb/test_clause1.sv

vsim -quiet -novopt test_clause1_top -wlf test_clause1_top.wlf

do ../tools/wave_test_clause1_top.do

# add wave -noupdate -divider {TEST}
# add wave -noupdate sim:/test_clause1_top/test_clause1/*
# add wave -noupdate -divider {DUT}
# add wave -noupdate sim:/test_clause1_top/test_clause1/clause1/*
# add wave -noupdate -expand -group {lit0} sim:/test_clause1_top/test_clause1/clause1/lit8/lit4_0/lit2_0/lit1_0/*
# add wave -noupdate -expand -group {lit1} sim:/test_clause1_top/test_clause1/clause1/lit8/lit4_0/lit2_0/lit1_1/*
# add wave -noupdate -expand -group {lit2} sim:/test_clause1_top/test_clause1/clause1/lit8/lit4_0/lit2_1/lit1_0/*
# add wave -noupdate -expand -group {lit3} sim:/test_clause1_top/test_clause1/clause1/lit8/lit4_0/lit2_1/lit1_1/*

# add wave -noupdate -expand -group {terminal_cell} sim:/test_clause1_top/test_clause1/clause1/terminal_cell/*

# add wave -r sim:/test_clause1_top/*


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

run 200 ns