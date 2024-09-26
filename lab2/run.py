#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Test bench for TSEA84
# Cheloyong Bae, Oscar Gustafsson

from os.path import join, dirname, abspath
from vunit import VUnit

root = dirname(__file__)

vu = VUnit.from_argv()
vu.add_vhdl_builtins()

lib = vu.add_library("lib")

# Add VHDL files for the standard design
lib.add_source_files(join(root, "pe_types.vhdl"))
lib.add_source_files(join(root, "PE_bin.vhdl"))

# Add files required for the synthesized version
lib.add_source_files(join(root, "altera_primitives.v"))
lib.add_source_files(join(root, "cycloneive_atoms.v"))
lib.add_source_files([join(root, "PE_7_1200mv_85c_slow.vo"), join(root, "tb_pe.vhdl")])

# Complains about not finding tb_pe.vhdl in lib
tb = lib.get_source_file("tb_pe.vhdl")
dut = lib.get_source_file("PE_7_1200mv_85c_slow.vo")
tb.add_dependency_on(dut)

# Complains about not finding signals
sdffile = abspath("PE_7_1200mv_85c_v_slow.sdo")
dut = "/tb_pe/instantiate_pe/PE1"
lib.set_sim_option("modelsim.vsim_flags", [f"-sdftyp {dut}={sdffile}"])

## Set flags for coverage
#lib.set_compile_option("modelsim.vcom_flags", ["+cover=bs"])
#lib.set_compile_option("modelsim.vlog_flags", ["+cover=bs"])
#lib.set_sim_option("enable_coverage", True)

# Load do-file that set up waveforms
lib.set_sim_option("modelsim.init_file.gui", "pe_waves_sim.do")

# Set generics
lib.set_generic("wordlength", 12)
lib.set_generic("clk_gen", "20ns")
lib.set_generic("shift_wordlength", 3)
lib.set_generic("pipeline", 3)
lib.set_generic("file_name", abspath("tests.txt"))
# lib.set_generic("file_name", abspath("testing.txt"))
# Set if logic_op is an enum or binary
# False: use enum
# True: use binary (for Verilog and synthesized)
lib.set_generic("logic_op", True)

## Coverage callback
#def post_run(results):
#    results.merge_coverage(file_name="coverage_data")
#
#
#vu.main(post_run=post_run)

vu.main()
