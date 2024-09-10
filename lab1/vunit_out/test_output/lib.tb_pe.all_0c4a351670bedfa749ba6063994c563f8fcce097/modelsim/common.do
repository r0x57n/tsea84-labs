
proc vunit_help {} {
    puts {List of VUnit commands:}
    puts {vunit_help}
    puts {  - Prints this help}
    puts {vunit_load [vsim_extra_args]}
    puts {  - Load design with correct generics for the test}
    puts {  - Optional first argument are passed as extra flags to vsim}
    puts {vunit_user_init}
    puts {  - Re-runs the user defined init file}
    puts {vunit_run}
    puts {  - Run test, must do vunit_load first}
    puts {vunit_compile}
    puts {  - Recompiles the source files}
    puts {vunit_restart}
    puts {  - Recompiles the source files}
    puts {  - and re-runs the simulation if the compile was successful}
}

proc vunit_run {} {
    if {[catch {_vunit_run} failed_or_err]} {
        echo $failed_or_err
        return true;
    }

    if {![is_test_suite_done]} {
        echo
        echo "Test Run Failed!"
        echo
        _vunit_run_failure;
        return true;
    }

    return false;
}

proc _vunit_source_init_files_after_load {} {
    return 0
}
proc _vunit_source_init_files_before_run {} {
    return 0
}

proc vunit_load {{vsim_extra_args ""}} {
    set vsim_failed [catch {
        eval vsim ${vsim_extra_args} {-modelsimini /home/raswa151/courses/tsea84-labs/lab1/vunit_out/modelsim/modelsim.ini -wlf {/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/modelsim/vsim.wlf} -quiet -t ps -onfinish stop  -g/tb_pe/wordlength=12 -g/tb_pe/shift_wordlength=3 -g/tb_pe/pipeline=0 -g/tb_pe/file_name=/home/raswa151/courses/tsea84-labs/lab1/testing.txt -g/tb_pe/logic_op=False -g/tb_pe/runner_cfg={"active python runner : true,enabled_test_cases : ,output path : /home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/,tb path : /home/raswa151/courses/tsea84-labs/lab1/,use_color : false"} lib.tb_pe(tb) -coverage  -L vunit_lib -L lib}
    }]

    if {${vsim_failed}} {
       echo Command 'vsim ${vsim_extra_args} -modelsimini /home/raswa151/courses/tsea84-labs/lab1/vunit_out/modelsim/modelsim.ini -wlf {/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/modelsim/vsim.wlf} -quiet -t ps -onfinish stop  -g/tb_pe/wordlength=12 -g/tb_pe/shift_wordlength=3 -g/tb_pe/pipeline=0 -g/tb_pe/file_name=/home/raswa151/courses/tsea84-labs/lab1/testing.txt -g/tb_pe/logic_op=False -g/tb_pe/runner_cfg={"active python runner : true,enabled_test_cases : ,output path : /home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/,tb path : /home/raswa151/courses/tsea84-labs/lab1/,use_color : false"} lib.tb_pe(tb) -coverage  -L vunit_lib -L lib' failed
       echo Bad flag from vsim_extra_args?
       return true
    }

    if {[_vunit_source_init_files_after_load]} {
        return true
    }

    global BreakOnAssertion
    set BreakOnAssertion 2

    global NumericStdNoWarnings
    set NumericStdNoWarnings 0

    global StdArithNoWarnings
    set StdArithNoWarnings 0

    coverage save -onexit -testname {lib.tb_pe.all} -assert -directive -cvg -codeAll {/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/modelsim/coverage.ucdb}
    return false
}

proc is_test_suite_done {} {
    set fd [open "/home/raswa151/courses/tsea84-labs/lab1/vunit_out/test_output/lib.tb_pe.all_0c4a351670bedfa749ba6063994c563f8fcce097/vunit_results" "r"]
    set contents [read $fd]
    close $fd
    set lines [split $contents "
"]
    foreach line $lines {
        if {$line=="test_suite_done"} {
           return true;
        }
    }

    return false;
}


proc _vunit_run_failure {} {
    catch {
        # tb command can fail when error comes from pli
        echo "Stack trace result from 'tb' command"
        echo [tb]
        echo
        echo "Surrounding code from 'see' command"
        echo [see]
    }
}

proc _vunit_run {} {
    if {[_vunit_source_init_files_before_run]} {
        return true
    }

    proc on_break {} {
        resume
    }
    onbreak {on_break}

    run -all
}

proc _vunit_sim_restart {} {
    restart -f
}

proc vunit_compile {} {
    set cmd_show {/opt/liu/anaconda3/2024.02.1/bin/python3 -u ./run.py --compile --gui}
    puts "Re-compiling using command ${cmd_show}"

    set chan [open |[list {/opt/liu/anaconda3/2024.02.1/bin/python3} {-u} {-c} {import sys;import subprocess;exit(subprocess.call(['/opt/liu/anaconda3/2024.02.1/bin/python3', '-u', './run.py', '--compile', '--gui'], cwd='/home/raswa151/courses/tsea84-labs/lab1', bufsize=0, universal_newlines=True, stdout=sys.stdout, stderr=sys.stdout))}] r]

    while {[gets $chan line] >= 0} {
        puts $line
    }

    if {[catch {close $chan} error_msg]} {
        puts "Re-compile failed"
        puts ${error_msg}
        return true
    } else {
        puts "Re-compile finished"
        return false
    }
}

proc vunit_restart {} {
    if {![vunit_compile]} {
        _vunit_sim_restart
        vunit_run
    }
}
