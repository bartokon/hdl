# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the project name
set proj_name "skid_buffer_project"

# Set the block design name
set bd_name "design_1"

variable script_file
set script_file "skid_buffer_project.tcl"

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
    ${hdl_sources_paths}/skid_buffer_wrapper.v \
    " \
-norecurse

add_files -fileset sim_1 "\
    ${hdl_sources_paths}/tb_skid_buffer.sv \
    " \
-norecurse

set_property top tb_skid_buffer [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

create_bd_design ${bd_name}
open_bd_design ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd

#Create IP's
create_bd_cell -type ip -vlnv xilinx.com:ip:axi4stream_vip:1.1 axi4stream_vip_0
set_property name axi4stream_vip_master_0 [get_bd_cells axi4stream_vip_0]
set_property CONFIG.INTERFACE_MODE {MASTER} [get_bd_cells axi4stream_vip_master_0]
set_property -dict [list \
    CONFIG.HAS_TKEEP {0} \
    CONFIG.HAS_TLAST {0} \
    CONFIG.HAS_TREADY {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.TDEST_WIDTH {0} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.HAS_TUSER_BITS_PER_BYTE {0} \
] [get_bd_cells axi4stream_vip_master_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi4stream_vip:1.1 axi4stream_vip_0
set_property name axi4stream_vip_slave_0 [get_bd_cells axi4stream_vip_0]
set_property CONFIG.INTERFACE_MODE {SLAVE} [get_bd_cells axi4stream_vip_slave_0]
set_property -dict [list \
    CONFIG.HAS_TKEEP {0} \
    CONFIG.HAS_TLAST {0} \
    CONFIG.HAS_TREADY {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.TDEST_WIDTH {0} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.HAS_TUSER_BITS_PER_BYTE {0} \
] [get_bd_cells axi4stream_vip_slave_0]

#Create ports
create_bd_port -dir I -type clk -freq_hz 100000000 clk_i
create_bd_port -dir I -type rst rst_clk_ni
set_property CONFIG.ASSOCIATED_RESET {rst_clk_ni} [get_bd_ports /clk_i]

#Connect ports
connect_bd_net [get_bd_ports clk_i] [get_bd_pins axi4stream_vip_master_0/aclk]
connect_bd_net [get_bd_ports clk_i] [get_bd_pins axi4stream_vip_slave_0/aclk]
connect_bd_net [get_bd_ports rst_clk_ni] [get_bd_pins axi4stream_vip_master_0/aresetn]
connect_bd_net [get_bd_ports rst_clk_ni] [get_bd_pins axi4stream_vip_slave_0/aresetn]

#Make intf external
make_bd_intf_pins_external  [get_bd_intf_pins axi4stream_vip_master_0/M_AXIS]
make_bd_intf_pins_external  [get_bd_intf_pins axi4stream_vip_slave_0/S_AXIS]

assign_bd_address
validate_bd_design
save_bd_design

# make_wrapper -files [get_files ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
# add_files -norecurse ${proj_name}/${proj_name}.srcs/sources_1/bd/${bd_name}/hdl/design_1_wrapper.v
# set_property top skid_buffer [current_fileset]
