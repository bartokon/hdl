# UVM Verification Environments

This directory contains UVM (Universal Verification Methodology) testbenches for comprehensive functional verification.

## Directory Structure

```
verification/
├── tutorial/          # Learning UVM (start here!)
│   └── 01_simple_adder/
├── axi4_lite/        # AXI4-Lite protocol verification
├── axi4_dma/         # DMA controller verification
├── axi4_stream_fifo/ # AXI4-Stream FIFO verification
└── skid_buffer/      # Skid buffer verification
```

## Standard Testbench Structure

Each verification project follows this organization:

```
testbench_name/
├── dut/              # Design Under Test
│   ├── *.sv          # DUT modules
│   └── interfaces.sv # DUT interfaces
│
├── tb/               # UVM Testbench Components
│   ├── *_transaction.sv   # Transaction class
│   ├── *_sequence.sv      # Sequences
│   ├── *_sequencer.sv     # Sequencer
│   ├── *_driver.sv        # Driver
│   ├── *_monitor.sv       # Monitor
│   ├── *_agent.sv         # Agent
│   ├── *_scoreboard.sv    # Scoreboard
│   ├── *_environment.sv   # Environment
│   ├── *_tests.sv         # Test cases
│   ├── *_package.sv       # Package wrapper
│   └── *_tb.sv            # Top-level testbench
│
└── project/          # Build Configuration
    ├── project.tcl   # Vivado TCL script
    └── build.sh      # Build script
```

## Getting Started with UVM

If you're new to UVM, **start with the tutorial**:

```bash
cd verification/tutorial/01_simple_adder
cat README.md  # Read the tutorial documentation
cd project
./build.sh     # Run the verification
```

The tutorial provides a simple 4-bit adder example demonstrating all UVM components.

## Running Verification

### Using Vivado (with Xilinx AXI VIP)

```bash
cd verification/axi4_lite/project
vivado -mode batch -source project.tcl
```

### Using QuestaSim/VCS/Other Simulators

1. Compile UVM library
2. Add all files from `dut/` and `tb/` to compilation
3. Set top module to `*_tb`
4. Run with `-uvm` flag

Example (QuestaSim):
```bash
vlog -sv -mfcu +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv
vlog -sv -mfcu dut/*.sv tb/*.sv
vsim -voptargs=+acc work.*_tb -do "run -all"
```

## UVM Component Overview

### Transaction
Defines the data items exchanged in the testbench (e.g., AXI transactions).

### Sequence
Generates streams of transactions to stimulate the DUT.

### Sequencer
Arbitrates and routes sequences to the driver.

### Driver
Converts transactions into pin-level activity on the DUT interface.

### Monitor
Observes DUT interfaces and converts pin-level activity to transactions.

### Agent
Encapsulates driver, sequencer, and monitor for a specific interface.

### Scoreboard
Checks DUT behavior by comparing actual vs. expected results.

### Environment
Top-level container for all verification components.

### Test
Configures the environment and runs specific test scenarios.

## Verification Projects

### Tutorial: Simple Adder
**Purpose**: Learn UVM basics
- 4-bit adder DUT
- Basic UVM structure
- Randomized input generation
- Scoreboard checking

### AXI4-Lite Verification
**Purpose**: Protocol compliance and functional verification
- Full AXI4-Lite protocol checking
- Read/write transactions
- Error injection
- Xilinx AXI VIP integration
- Sequence library with common patterns

### AXI4 DMA Verification
**Purpose**: DMA controller verification
- AXI4-Lite control interface
- Full AXI4 data interface
- Custom datatypes for DMA operations
- Memory model
- Performance checking

### AXI4-Stream FIFO Verification
**Purpose**: FIFO functional verification
- Backpressure handling
- Full/empty conditions
- Data integrity
- Performance metrics

### Skid Buffer Verification
**Purpose**: Pipeline register verification
- Ready/valid handshaking
- Zero bubble operation
- Throughput verification

## Configuration

### Test Parameters

Most testbenches support configuration parameters:

```systemverilog
// In test class
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::set(this, "*", "num_transactions", 1000);
    uvm_config_db#(int)::set(this, "*", "addr_width", 32);
endfunction
```

### Number of Transactions

Defined in TCL scripts:
```tcl
set_property -name {xsim.compile.xvlog.more_options} \
    -value {-L uvm -define "NO_OF_TRANSACTIONS=2000"} \
    -objects [get_filesets sim_1]
```

## Debugging

### Waveform Viewing

Add to TCL script:
```tcl
launch_simulation
open_vcd
log_vcd [get_objects -r *]
run -all
```

### UVM Verbosity

Set verbosity level in test:
```systemverilog
function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
endfunction
```

Or via plusarg:
```bash
xsim -R +UVM_VERBOSITY=UVM_HIGH
```

## Best Practices

1. **Reuse**: Leverage sequence libraries for common test scenarios
2. **Randomization**: Use constrained randomization for comprehensive coverage
3. **Functional Coverage**: Add covergroups to track verification progress
4. **Assertions**: Use SVA for protocol checking
5. **Documentation**: Document test intent and expected behavior

## Common Issues

### "UVM library not found"
Ensure UVM is compiled and accessible. Vivado includes UVM by default.
Add `-L uvm` flag for compilation and elaboration.

### "Interface not connected"
Check that interfaces are properly instantiated and connected in the top-level testbench.

### "Simulation hangs"
Verify all phase objections are properly raised and dropped.

## Resources

- [UVM 1.2 Class Reference](https://www.accellera.org/downloads/standards/uvm)
- [Xilinx AXI VIP Documentation](https://www.xilinx.com/products/intellectual-property/axi-verification-ip.html)
- Tutorial: verification/tutorial/01_simple_adder/README.md
