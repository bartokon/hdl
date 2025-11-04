# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "uvm_axi4_stream_fifo_project"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "uvm_axi4_stream_fifo_project.tcl"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set dut_paths "[file normalize "$origin_dir/../dut"]"
set tb_paths "[file normalize "$origin_dir/../tb"]"
set bd_tcl_paths "[file normalize "$origin_dir/."]"

add_files -fileset sources_1 "\
    ${dut_paths}/axi4_stream_fifo.sv \
    " \
-norecurse

add_files -fileset sim_1 "\
    ${tb_paths}/interface.sv \
    ${tb_paths}/uvm_sequence_item.sv \
    ${tb_paths}/uvm_driver.sv \
    ${tb_paths}/uvm_monitor.sv \
    ${tb_paths}/uvm_agent.sv \
    ${tb_paths}/uvm_scoreboard.sv \
    ${tb_paths}/uvm_environment.sv \
    ${tb_paths}/uvm_test.sv \
    ${tb_paths}/uvm_sequence.sv \
    ${tb_paths}/uvm_sequencer.sv \
    ${tb_paths}/tb.sv \
    " \
-norecurse

set_property top tb [get_filesets sim_1]

start_gui