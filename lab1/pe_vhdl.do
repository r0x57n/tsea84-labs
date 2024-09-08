vsim work.pe(start) 
add dataflow sim:/pe/*
do pe_waves.do
force -freeze sim:/pe/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/pe/inputa 12'h333 0
force -freeze sim:/pe/inputb 12'h111 0
force -freeze sim:/pe/shift_val 0000 0
force -freeze sim:/pe/op add 0
force -freeze sim:/pe/sat 0 0
run 100 
force -freeze sim:/pe/op sub 0
run 100