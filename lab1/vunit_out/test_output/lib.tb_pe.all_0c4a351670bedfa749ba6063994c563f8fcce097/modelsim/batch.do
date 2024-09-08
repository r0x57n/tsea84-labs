onerror {quit -code 1}
source "/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
