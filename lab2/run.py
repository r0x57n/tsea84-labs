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
lib.add_source_files(join(root, "PE.vhdl"))
lib.add_source_files(join(root, "tb_pe.vhdl"))

# Verilog file
# lib.add_source_files(join(root, "PE_bin.v"))

# Add files required for the synthesized version
# lib.add_source_files(join(root, "PE.vo"))
# lib.add_source_files("/courses/TSEA84/src/verilog/src/altera_primitives.v")
# lib.add_source_files("/courses/TSEA84/src/verilog/src/cycloneive_atoms.v")


# Set flags for coverage
#lib.set_compile_option("modelsim.vcom_flags", ["+cover=bs"])
#lib.set_compile_option("modelsim.vlog_flags", ["+cover=bs"])
#lib.set_sim_option("enable_coverage", True)

# Load do-file that set up waveforms
lib.set_sim_option("modelsim.init_file.gui", "pe_waves_sim.do")

# Set generics
lib.set_generic("wordlength", 12)
lib.set_generic("shift_wordlength", 3)
lib.set_generic("pipeline", 2)
lib.set_generic("file_name", abspath("tests.txt"))
# lib.set_generic("file_name", abspath("testing.txt"))
# Set if logic_op is an enum or binary
# False: use enum
# True: use binary (for Verilog and synthesized)
lib.set_generic("logic_op", False)


# Coverage callback
#def post_run(results):
#    results.merge_coverage(file_name="coverage_data")
#
#
#vu.main(post_run=post_run)

vu.main()
