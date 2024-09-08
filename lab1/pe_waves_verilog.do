# https://ww1.microchip.com/downloads/aemdocuments/documents/fpga/ProductDocuments/ReleaseNotes/modelsim_me_v105c_ref.pdf

add wave sim:/PE_bin/clk
add wave -divid "Inputs"
add wave -radix hex -label "A" sim:/PE_bin/inputa
add wave -radix hex -label "B" sim:/PE_bin/inputb
add wave -divider "Operation"
add wave sim:/PE_bin/op
add wave sim:/PE_bin/sat
add wave sim:/PE_bin/shift_val
add wave -divider "Outputs"
add wave -out sim:/PE_bin/*
config wave -signalnamewidth 1
