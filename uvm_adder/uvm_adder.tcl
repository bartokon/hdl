# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "uvm_adder"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "uvm_adder.tcl"
puts "$argv0"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/."]"

add_files -fileset sources_1 "\
   ${hdl_sources_paths}/adder.v \
   " \
-norecurse

add_files -fileset sim_1 "\
   ${hdl_sources_paths}/tb.sv \
   ${hdl_sources_paths}/base_test.sv \
   ${hdl_sources_paths}/base_seq.sv \
   ${hdl_sources_paths}/env.sv \
   ${hdl_sources_paths}/sequencer.sv \
   ${hdl_sources_paths}/agent.sv \
   ${hdl_sources_paths}/driver.sv \
   ${hdl_sources_paths}/seq_item.sv \
   ${hdl_sources_paths}/interface.sv \
   ${hdl_sources_paths}/package.sv \
   ${hdl_sources_paths}/monitor.sv \
   ${hdl_sources_paths}/scoreboard.sv \
   " \
-norecurse

set_property top tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1