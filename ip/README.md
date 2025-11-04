# IP Library Catalog

This directory contains reusable RTL IP cores organized by functional category.

## Directory Structure

- **axi/** - AXI protocol implementations (AXI4, AXI4-Lite, AXI4-Stream)
- **buffers/** - Buffer and FIFO components
- **arithmetic/** - Mathematical operations
- **logic/** - Basic logic components
- **networking/** - Network/packet processing
- **vhdl/** - VHDL-based IP cores

## Using IP Components

Each IP component is self-contained with the following structure:

```
component_name/
├── src/          # RTL source files (*.sv, *.v, *.vhd)
├── sim/          # Testbenches (tb_*.sv, tb_*.vhd)
├── include/      # Header files (if applicable)
└── README.md     # Component documentation
```

### In Vivado Projects

Reference IP components using relative paths from your project TCL script:

```tcl
set ip_path "[file normalize "$origin_dir/../../../ip/category/component"]"
add_files -fileset sources_1 "${ip_path}/src/component.sv"
```

### In Simulation

Add both source and testbench files to your simulator filelist.

## IP Component Index

### AXI Components

| Component | Type | Description |
|-----------|------|-------------|
| axi4_lite_master | SystemVerilog | AXI4-Lite master with LUT support |
| axi4_lite_channels | SystemVerilog | Read/write channel managers (v2) |
| axi4_lite_core | SystemVerilog | Complete AXI4-Lite implementation |
| axi4_master | SystemVerilog | Full AXI4 master |
| axi4_stream_fifo | SystemVerilog | AXI4-Stream FIFO |

### Buffer Components

| Component | Type | Description |
|-----------|------|-------------|
| skid_buffer | SystemVerilog | Pipeline register with handshaking |
| dual_port_ram_fifo | SystemVerilog | RAM-based FIFO |

### Arithmetic Components

| Component | Type | Description |
|-----------|------|-------------|
| float_add | SystemVerilog | Floating-point adder |

### Logic Components

| Component | Type | Description |
|-----------|------|-------------|
| decoder | SystemVerilog | Simple decoder |

### Networking Components

| Component | Type | Description |
|-----------|------|-------------|
| simple_switch | SystemVerilog | 1-cycle latency router |

### VHDL Components

| Component | Type | Description |
|-----------|------|-------------|
| basic/counter | VHDL | Counter (v1 and v2) |
| basic/fsm | VHDL | Finite state machine |
| basic/mux | VHDL | Multiplexers (1D and 2D) |
| pmod_vga | VHDL | VGA display controller |

## Version Naming Convention

- **v1** or no suffix: Initial Verilog implementation (now in legacy/)
- **v2** suffix: Enhanced SystemVerilog version
- Files without version suffix: Latest stable version

## IP Quality Levels

Based on verification status:

- ✅ **Verified**: Has testbench and UVM verification environment
- ⚠️ **Tested**: Has basic testbench only
- ⬜ **Unverified**: No testbench available

| IP | Status |
|----|--------|
| axi4_lite_master | ✅ Verified |
| axi4_stream_fifo | ✅ Verified |
| skid_buffer | ✅ Verified |
| axi4_lite_channels | ⚠️ Tested |
| decoder | ⚠️ Tested |
| float_add | ⬜ Unverified |
| dual_port_ram_fifo | ⬜ Unverified |

## Dependencies

Some IP components depend on others:

- **axi4_lite_core** requires **axi4_lite_channels** and **skid_buffer**
- **axi4_stream_fifo** requires **skid_buffer** and **dual_port_ram_fifo**

See individual component documentation for detailed dependency information.
