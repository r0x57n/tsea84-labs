force -freeze rstn 0 0, 1 1
force -freeze clk 1 0, 0 5 -r 10
add wave clk
add wave -format analog-step -height 100 -max 512 -min -512 -radix decimal y
run 1000
wave zoom full

