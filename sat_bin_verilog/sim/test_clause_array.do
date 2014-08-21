quit -sim
vlib work
vmap work work

# vlog -quiet ../src/sat_engine/lit1.v -sv
# vlog -quiet ../src/sat_engine/lits.v
# vlog -quiet ../src/sat_engine/terminal_cell.v
# vlog -quiet ../src/sat_engine/clause1.v
# vlog -quiet ../src/sat_engine/clauses.v
# vlog -quiet ../src/sat_engine/clause_array.v
# vlog -quiet ../src/sat_engine/max_in_datas.v
# vlog -quiet ../tb/class_clause_data.sv
# vlog -quiet ../tb/class_clause_array.sv
# vlog -quiet ../tb/test_clause_array.sv


# vsim -quiet test_clause_array_top -pli D:/Novas/Debussy/share/PLI/modelsim_fli53/WINNT/novas_fli.dll

vsim -quiet -novopt test_clause_array_top

# add wave -noupdate -divider {TEST}
# add wave -noupdate sim:/test_clause_array_top/test_clause_array/*
# add wave -noupdate -divider {DUT}
# add wave -noupdate sim:/test_clause_array_top/test_clause_array/clause_array/*

do ../tools/wave_test_clause_array_top.do
# do wave.do

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

run -all
