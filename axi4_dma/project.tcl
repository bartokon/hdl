# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "project"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "project.tcl"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/src_modules/."]"
set uvm_sources_paths "[file normalize "$origin_dir/src_uvm/."]"

# UVM
set UVM_FILES "\
    ${uvm_sources_paths}/axi4_lite_package.sv \
    ${uvm_sources_paths}/axi4_lite_transaction.sv \
    ${uvm_sources_paths}/axi4_lite_monitor.sv \
    ${uvm_sources_paths}/axi4_lite_sequencer.sv \
    ${uvm_sources_paths}/axi4_lite_sequencer_library.sv \
    ${uvm_sources_paths}/axi4_lite_driver.sv \
    ${uvm_sources_paths}/axi4_lite_agent.sv \
    ${uvm_sources_paths}/axi4_lite_scoreboard.sv \
    ${uvm_sources_paths}/axi4_lite_environment.sv \
    ${uvm_sources_paths}/axi4_lite_tests.sv \
    ${uvm_sources_paths}/axi4_lite_tb.sv \
    "

set HDL_FILES "\
    ${hdl_sources_paths}/axi4_lite.sv \
    ${hdl_sources_paths}/axi4_lite_read.sv \
    ${hdl_sources_paths}/axi4_lite_write.sv \
    ${hdl_sources_paths}/memory.sv \
    ${hdl_sources_paths}/interfaces.sv \
    "

add_files ${UVM_FILES} -norecurse
add_files ${HDL_FILES} -norecurse

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property source_mgmt_mode DisplayOnly [current_project]
set_property top axi4_lite_tb.sv [current_fileset]
foreach file [lreverse $UVM_FILES] {
  reorder_files -after [lindex $UVM_FILES 0] $file
}

set_property USED_IN_SIMULATION 1 [get_files -all ${UVM_FILES}]
set_property USED_IN_SYNTHESIS  0 [get_files -all ${UVM_FILES}]
set_property USED_IN_IMPLEMENTATION 0 [get_files -all ${UVM_FILES}]
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm -define "NO_OF_TRANSACTIONS=2000"} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm -timescale 1ns/1ps} -objects [get_filesets sim_1]

start_gui
launch_simulation