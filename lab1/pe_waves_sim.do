onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_pe/instantiate_pe/PE1/wordlength
add wave -noupdate -radix unsigned /tb_pe/instantiate_pe/PE1/shift_wordlength
add wave -noupdate -divider inputs
add wave -noupdate -radix decimal /tb_pe/instantiate_pe/PE1/inputa
add wave -noupdate -radix decimal /tb_pe/instantiate_pe/PE1/inputb
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/signeda
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/signedb
add wave -noupdate -divider operations
add wave -noupdate -radix unsigned /tb_pe/logic_op
add wave -noupdate -radix unsigned /tb_pe/instantiate_pe/PE1/shift_val
add wave -noupdate -radix unsigned /tb_pe/instantiate_pe/PE1/unsigned_shift
add wave -noupdate -divider out
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/before_shift
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/before_saturation
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/signedoutput
add wave -noupdate -radix binary /tb_pe/instantiate_pe/PE1/result
add wave -noupdate /tb_pe/instantiate_pe/PE1/V
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {870 ps}

config wave -signalnamewidth 1
run 100 ps
wave zoom full
