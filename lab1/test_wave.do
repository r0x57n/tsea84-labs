onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_pe/instantiate_pe/PE1/wordlength
add wave -noupdate /tb_pe/instantiate_pe/PE1/shift_wordlength
add wave -noupdate -divider inputs
add wave -noupdate /tb_pe/instantiate_pe/PE1/inputa
add wave -noupdate /tb_pe/instantiate_pe/PE1/inputb
add wave -noupdate /tb_pe/instantiate_pe/PE1/signeda
add wave -noupdate /tb_pe/instantiate_pe/PE1/signedb
add wave -noupdate -divider operations
add wave -noupdate /tb_pe/logic_op
add wave -noupdate /tb_pe/instantiate_pe/PE1/shift_val
add wave -noupdate /tb_pe/instantiate_pe/PE1/unsigned_shift
add wave -noupdate -divider intermediate
add wave -noupdate /tb_pe/instantiate_pe/PE1/overflow_add
add wave -noupdate /tb_pe/instantiate_pe/PE1/overflow_sub
add wave -noupdate /tb_pe/instantiate_pe/PE1/overflow_mul
add wave -noupdate /tb_pe/instantiate_pe/PE1/before_shift
add wave -noupdate /tb_pe/instantiate_pe/PE1/before_saturation
add wave -noupdate /tb_pe/instantiate_pe/PE1/signedoutput
add wave -noupdate -divider out
add wave -noupdate /tb_pe/instantiate_pe/PE1/result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {76 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {15 ps}
