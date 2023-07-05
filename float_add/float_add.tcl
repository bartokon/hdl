# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "float_add"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "float_add.tcl"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/../sources/."]"
set bd_tcl_paths "[file normalize "$origin_dir/../sources/."]"

add_files -fileset sources_1 "\
    ${hdl_sources_paths}/float_add.sv \
    ${hdl_sources_paths}/float_add.v \
    " \
-norecurse

add_files -fileset sim_1 "\
    ${hdl_sources_paths}/tb_float_add.sv \
    " \
-norecurse

set_property top tb_skid_buffer [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

create_bd_design ${bd_name}
open_bd_design ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd

#Create IP's
assign_bd_address
validate_bd_design
save_bd_design

# make_wrapper -files [get_files ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
# add_files -norecurse ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/hdl/design_1_wrapper.v
# set_property top skid_buffer [current_fileset]
