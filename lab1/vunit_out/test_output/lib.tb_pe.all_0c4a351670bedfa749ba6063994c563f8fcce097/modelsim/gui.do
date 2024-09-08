source "/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/modelsim/common.do"
proc vunit_user_init {} {

    set vunit_tb_path "/home/raswa151/courses/tsea84-labs/lab1"
    set file_name "/home/raswa151/courses/tsea84-labs/lab1/pe_waves_sim.do"
    puts "Sourcing file ${file_name} from modelsim.init_file.gui"
    if {[catch {source ${file_name}} error_msg]} {
        puts "Sourcing ${file_name} failed"
        puts ${error_msg}
        return true
    }
    return 0
}
if {![vunit_load]} {
  vunit_user_init
  vunit_help
}
