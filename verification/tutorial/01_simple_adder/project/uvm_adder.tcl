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
set dut_paths "[file normalize "$origin_dir/../dut"]"
set tb_paths "[file normalize "$origin_dir/../tb"]"

add_files -fileset sources_1 "\
   ${dut_paths}/adder.v \
   " \
-norecurse

add_files -fileset sim_1 "\
   ${tb_paths}/tb.sv \
   ${tb_paths}/base_test.sv \
   ${tb_paths}/base_seq.sv \
   ${tb_paths}/env.sv \
   ${tb_paths}/sequencer.sv \
   ${tb_paths}/agent.sv \
   ${tb_paths}/driver.sv \
   ${tb_paths}/seq_item.sv \
   ${tb_paths}/interface.sv \
   ${tb_paths}/package.sv \
   ${tb_paths}/monitor.sv \
   ${tb_paths}/scoreboard.sv \
   " \
-norecurse

set_property top tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1