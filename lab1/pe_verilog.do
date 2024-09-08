vsim work.PE_bin(fast) 
add dataflow sim:/PE_bin/*
do pe_waves_verilog.do
force -freeze sim:/PE_bin/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/PE_bin/inputa 12'h333 0
force -freeze sim:/PE_bin/inputb 12'h111 0
force -freeze sim:/PE_bin/shift_val 0000 0
force -freeze sim:/PE_bin/op 4'b0001 0
force -freeze sim:/PE_bin/sat 0 0
run 100 
force -freeze sim:/PE_bin/op 4'b0010 0
run 100