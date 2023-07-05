# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "uvm_skid_buffer_project"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "uvm_skid_buffer_project.tcl"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/../sources/."]"
set bd_tcl_paths "[file normalize "$origin_dir/../sources/."]"

add_files -fileset sources_1 "\
    ${hdl_sources_paths}/skid_buffer.sv \
    " \
-norecurse

add_files -fileset sim_1 "\
    uvm_config.svh \
    package.sv \
    interface.sv \
    uvm_sequence_item.sv \
    uvm_driver.sv \
    uvm_monitor.sv \
    uvm_agent.sv \
    uvm_scoreboard.sv \
    uvm_environment.sv \
    uvm_test.sv \
    uvm_sequence.sv \
    tb.sv \
    " \
-norecurse

set_property top tb [get_filesets sim_1]

start_gui