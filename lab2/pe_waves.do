# https://ww1.microchip.com/downloads/aemdocuments/documents/fpga/ProductDocuments/ReleaseNotes/modelsim_me_v105c_ref.pdf

add wave sim:/pe/clk
add wave -divider "Inputs"
add wave -radix hex -label "A" sim:/pe/inputa
add wave -radix hex -label "B" sim:/pe/inputb
add wave -divider "Operation"
add wave sim:/pe/op
add wave sim:/pe/sat
add wave sim:/pe/shift_val
add wave -divider "Outputs"
add wave -out sim:/pe/*

config wave -signalnamewidth 1
