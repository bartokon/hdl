# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the block design name
set bd_name "gpio_bd"

# Set the project name
set proj_name "axi4_lite_master_project"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/../sources/."]"
set bd_tcl_paths "[file normalize "$origin_dir/../sources/."]"

add_files -fileset sources_1 "\
    ${hdl_sources_paths}/axi4_lite_master.sv \
    ${hdl_sources_paths}/axi4_lite_master_lut.sv \
    ${hdl_sources_paths}/axi4_lite_master_with_lut.v \
    " \
-norecurse

add_files -fileset sim_1 "\
    ${hdl_sources_paths}/tb_axi4_lite_master.sv \
    " \
-norecurse

set_property top tb_axi4_lite_master [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

#Create_bd
create_bd_design ${bd_name}
open_bd_design ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property CONFIG.C_ALL_OUTPUTS {1} [get_bd_cells axi_gpio_0]
make_bd_pins_external  [get_bd_cells axi_gpio_0]
make_bd_intf_pins_external  [get_bd_cells axi_gpio_0]
save_bd_design

start_gui