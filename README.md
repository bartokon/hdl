# HDL IP Library and Verification Framework

A comprehensive collection of reusable HDL IP cores, UVM verification environments, and FPGA synthesis projects, primarily targeting Xilinx Zynq-7000 devices.

## Repository Structure

```
hdl/
├── ip/                    # Reusable IP cores (RTL library)
├── verification/          # UVM testbenches and verification environments
├── projects/             # FPGA synthesis projects (Vivado)
├── legacy/               # Deprecated Verilog implementations
├── tools/                # Build scripts and utilities
└── docs/                 # Documentation
```

## Quick Start

### Prerequisites
- **Xilinx Vivado** (tested with version supporting xc7z010clg400-1)
- **SystemVerilog** compiler (for RTL simulation)
- **UVM library** (for verification projects)

### Building a Project

Navigate to any project directory and run the build script:

```bash
cd projects/decoder/vivado
./build.sh
```

Or use Vivado TCL directly:

```bash
vivado -mode batch -source decoder_project.tcl
```

### Running UVM Simulations

```bash
cd verification/tutorial/01_simple_adder/project
vivado -mode batch -source uvm_adder.tcl
```

## IP Library (`ip/`)

Organized by functional category:

### AXI Protocol Implementations (`ip/axi/`)
- **axi4_lite_master/** - AXI4-Lite master with LUT support
- **axi4_lite_channels/** - Separate read/write channel managers (v2)
- **axi4_lite_core/** - Complete AXI4-Lite protocol implementation
- **axi4_master/** - Full AXI4 master with read/write managers
- **axi4_stream_fifo/** - AXI4-Stream FIFO with backpressure

### Infrastructure Components (`ip/buffers/`)
- **skid_buffer/** - Pipeline register with ready/valid handshaking
- **dual_port_ram_fifo/** - Dual-port RAM-based FIFO

### Arithmetic (`ip/arithmetic/`)
- **float_add/** - Floating-point adder

### Logic (`ip/logic/`)
- **decoder/** - Simple combinational decoder

### Networking (`ip/networking/`)
- **simple_switch/** - 1-cycle latency packet router

### VHDL IP (`ip/vhdl/`)
- **basic/** - Counters, FSMs, multiplexers, packages
- **pmod_vga/** - Complete VGA controller for Pmod VGA display

Each IP component follows the structure:
```
component_name/
├── src/          # RTL source files
├── sim/          # Testbenches
└── README.md     # Component documentation (if available)
```

## Verification (`verification/`)

UVM-based verification environments:

### Tutorial
- **tutorial/01_simple_adder/** - Introduction to UVM methodology

### Production Testbenches
- **axi4_lite/** - Complete AXI4-Lite protocol verification
- **axi4_dma/** - DMA controller verification with custom datatypes
- **axi4_stream_fifo/** - AXI4-Stream FIFO verification
- **skid_buffer/** - Skid buffer verification

Each verification project contains:
```
verification_name/
├── dut/          # Design Under Test
├── tb/           # UVM testbench components
└── project/      # Vivado/simulator configuration
```

## FPGA Projects (`projects/`)

Synthesis-ready Vivado projects:

- **decoder/** - Simple decoder implementation
- **simple_router/** - Packet router with FIFO (includes Xilinx IP)
- **axi4_lite/** - AXI4-Lite v1 (legacy Verilog)
- **axi4_lite_v2/** - AXI4-Lite v2 (SystemVerilog)
- **axi4_lite_master/** - AXI4-Lite master implementation
- **skid_buffer/** - Skid buffer with AXI4-Stream VIP integration
- **float_add/** - Floating-point adder
- **axi4_stream_fifo/** - AXI4-Stream FIFO

## Legacy Code (`legacy/`)

Deprecated Verilog implementations kept for reference:
- Original v1 AXI4-Lite components
- Wrapper modules (replaced by SystemVerilog versions)

## Documentation (`docs/`)

Additional documentation and guides (see individual files).

## Development Guidelines

### Adding New IP
1. Create directory structure: `ip/category/component_name/{src,sim}/`
2. Add RTL files to `src/`
3. Add testbenches to `sim/`
4. Document interfaces and usage in README.md

### Creating Vivado Projects
1. Place TCL script in `projects/component_name/vivado/`
2. Reference IP using relative paths: `../../../ip/category/component/src/`
3. Update build script if needed

### UVM Verification
1. Create directory: `verification/component_name/{dut,tb,project}/`
2. DUT files in `dut/`
3. UVM components in `tb/`
4. Vivado/simulation config in `project/`

## Target Platform

Primary target: **Xilinx Zynq-7000** (xc7z010clg400-1)
- Compatible with Zynq UltraScale+ with minor modifications
- Uses Xilinx IP cores (AXI VIP, FIFO Generator)

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

Contributions welcome! Please:
1. Follow existing directory structure
2. Use consistent naming (lowercase with underscores)
3. Update documentation
4. Test builds before committing

## Author

Bartosz Rycko

## Additional Resources

- [Vivado Design Suite User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_1/ug973-vivado-release-notes-install-license.pdf)
- [UVM 1.2 User Guide](https://www.accellera.org/downloads/standards/uvm)
- [AXI4 Protocol Specification](https://developer.arm.com/documentation/ihi0022/latest/)
