
add wave sim:/tb_pe/instantiate_pe/PE1/clk
add wave -divider "Inputs"
add wave -radix hex -label "A" sim:/tb_pe/instantiate_pe/PE1/inputa
add wave -radix hex -label "B" sim:/tb_pe/instantiate_pe/PE1/inputb
add wave -radix hex sim:/tb_pe/instantiate_pe/PE1/signeda
add wave -radix hex sim:/tb_pe/instantiate_pe/PE1/signedb
add wave -divider "Operation"
add wave sim:/tb_pe/instantiate_pe/PE1/op
add wave sim:/tb_pe/instantiate_pe/PE1/sat
add wave sim:/tb_pe/instantiate_pe/PE1/shift_val
add wave -divider "Outputs"
#add wave -out sim:/tb_pe/instantiate_pe/PE1/*

config wave -signalnamewidth 1
