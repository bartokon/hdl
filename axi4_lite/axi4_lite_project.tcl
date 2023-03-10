# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "axi4_lite_project"

variable script_file
set script_file "axi4_lite_project.tcl"

# Create project
create_project -force ${proj_name} ./${proj_name} -part xc7z010clg400-1
set_property target_language VERILOG [current_project]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set HDL sources path
set hdl_sources_paths "[file normalize "$origin_dir/../sources/."]"
set bd_tcl_paths "[file normalize "$origin_dir/../sources/."]"

add_files -fileset sources_1 "\
    ${hdl_sources_paths}/axi_lite_read_manager.v \
    ${hdl_sources_paths}/axi_lite_write_manager.v \
    ${hdl_sources_paths}/axi4_lite.v \
    " \
-norecurse

add_files -fileset sim_1 "\
    ${hdl_sources_paths}/tb_axi4_lite_write.sv \
    " \
-norecurse

set_property top tb_axi4_lite_write [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

#Create_bd
create_bd_design "design_1"
create_bd_cell -type module -reference axi4_lite axi4_lite_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0
set_property -dict [list CONFIG.PROTOCOL.VALUE_SRC USER] [get_bd_cells axi_vip_0]
set_property CONFIG.INTERFACE_MODE {MASTER} [get_bd_cells axi_vip_0]
set_property CONFIG.PROTOCOL {AXI4LITE} [get_bd_cells axi_vip_0]
set_property CONFIG.HAS_PROT {0} [get_bd_cells axi_vip_0]

create_bd_port -dir I -type clk -freq_hz 100000000 aclk
create_bd_port -dir I -type rst aresetn

connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_vip_0/aclk]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_vip_0/aresetn]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi4_lite_0/aclk]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi4_lite_0/aresetn]

assign_bd_address
validate_bd_design
