# UVM Tutorial: Simple 4-Bit Adder

**Welcome to UVM!** This is a beginner-friendly introduction to the Universal Verification Methodology using a simple 4-bit adder as the Design Under Test (DUT).

## Learning Objectives

After completing this tutorial, you will understand:
- ✅ Basic UVM testbench architecture
- ✅ How to create transactions, sequences, and drivers
- ✅ How to build monitors and scoreboards
- ✅ How to configure and run UVM tests

## Design Under Test

The DUT is a simple 4-bit adder:

```verilog
module adder (
    input  [3:0] a,
    input  [3:0] b,
    input        clk,
    output reg [4:0] sum
);
```

**Functionality**: Adds two 4-bit inputs and produces a 5-bit sum (including carry).

## Testbench Architecture

```
┌─────────────────────────────────────────────────────┐
│                    UVM Test                         │
│  (Configures environment, runs sequences)           │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│               Environment                           │
│  ┌──────────────┐  ┌───────────────┐               │
│  │    Agent     │  │  Scoreboard   │               │
│  │ ┌──────────┐ │  │ (Checks sum)  │               │
│  │ │Driver    │ │  └───────────────┘               │
│  │ │Sequencer │ │                                   │
│  │ │Monitor   │ │                                   │
│  │ └──────────┘ │                                   │
│  └──────────────┘                                   │
└──────────────────┬──────────────────────────────────┘
                   │
         ┌─────────▼──────────┐
         │   DUT Interface    │
         └─────────┬──────────┘
                   │
              ┌────▼────┐
              │  Adder  │
              │   DUT   │
              └─────────┘
```

## File Guide

### DUT Files (`dut/`)
- **adder.v** - The 4-bit adder implementation

### Testbench Files (`tb/`)
- **interface.sv** - SystemVerilog interface connecting to DUT
- **seq_item.sv** - Transaction class (input values a, b, and output sum)
- **base_seq.sv** - Base sequence generating random transactions
- **sequencer.sv** - Routes sequences to driver
- **driver.sv** - Drives a and b values to DUT
- **monitor.sv** - Observes DUT inputs and outputs
- **scoreboard.sv** - Checks if sum = a + b
- **agent.sv** - Container for driver, sequencer, monitor
- **env.sv** - Environment containing agent and scoreboard
- **base_test.sv** - Test that configures and runs the environment
- **package.sv** - UVM package including all components
- **tb.sv** - Top-level testbench module

## Key UVM Concepts Demonstrated

### 1. Transaction (seq_item.sv)

Represents the data being transferred:

```systemverilog
class seq_item extends uvm_sequence_item;
    rand bit [3:0] a;
    rand bit [3:0] b;
    bit [4:0] sum;  // Output from DUT

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(sum, UVM_DEFAULT)
    `uvm_object_utils_end
endclass
```

### 2. Sequence (base_seq.sv)

Generates transactions:

```systemverilog
class base_seq extends uvm_sequence#(seq_item);
    task body();
        for(int i = 0; i < 10; i++) begin
            req = seq_item::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask
endclass
```

### 3. Driver (driver.sv)

Applies transactions to DUT:

```systemverilog
task run_phase(uvm_phase phase);
    forever begin
        seq_item_port.get_next_item(req);
        @(posedge vif.clk);
        vif.a <= req.a;
        vif.b <= req.b;
        seq_item_port.item_done();
    end
endtask
```

### 4. Monitor (monitor.sv)

Observes DUT behavior:

```systemverilog
task run_phase(uvm_phase phase);
    forever begin
        @(posedge vif.clk);
        item.a = vif.a;
        item.b = vif.b;
        item.sum = vif.sum;
        analysis_port.write(item);
    end
endtask
```

### 5. Scoreboard (scoreboard.sv)

Verifies correctness:

```systemverilog
function void write(seq_item item);
    expected_sum = item.a + item.b;
    if (item.sum != expected_sum) begin
        `uvm_error("SCOREBOARD", $sformatf(
            "MISMATCH: a=%0d, b=%0d, expected=%0d, got=%0d",
            item.a, item.b, expected_sum, item.sum))
    end else begin
        `uvm_info("SCOREBOARD", $sformatf(
            "PASS: %0d + %0d = %0d",
            item.a, item.b, item.sum), UVM_MEDIUM)
    end
endfunction
```

## Running the Tutorial

### Step 1: Build and Run

```bash
cd project
./build.sh
```

Or manually:
```bash
vivado -mode batch -source uvm_adder.tcl
```

### Step 2: Observe Output

You should see UVM report output:
```
UVM_INFO @ 0: reporter [RNTST] Running test base_test...
UVM_INFO scoreboard.sv (45) @ 10ns: uvm_test_top.env.scoreboard [SCOREBOARD] PASS: 5 + 3 = 8
UVM_INFO scoreboard.sv (45) @ 20ns: uvm_test_top.env.scoreboard [SCOREBOARD] PASS: 12 + 7 = 19
...
UVM_INFO ... [TEST_DONE] All checks passed!
```

### Step 3: Experiment

Try modifying:
1. **Number of transactions**: Edit `base_seq.sv` loop count
2. **Constraints**: Add constraints to `seq_item` (e.g., `a < 8`)
3. **Errors**: Intentionally break the adder to see scoreboard errors

## Exercise: Add Functional Coverage

Add a covergroup to `monitor.sv`:

```systemverilog
covergroup adder_cov;
    a_cp: coverpoint item.a;
    b_cp: coverpoint item.b;
    sum_cp: coverpoint item.sum;

    cross_ab: cross a_cp, b_cp;
endgroup
```

## Next Steps

Once comfortable with this tutorial:
1. Explore **verification/axi4_lite/** for a more complex example
2. Read UVM User Guide for advanced topics
3. Add assertions to check timing properties
4. Create multiple test scenarios (corner cases, constrained random)

## Troubleshooting

**Problem**: Compilation errors
- **Solution**: Ensure all files are included in project.tcl

**Problem**: UVM library not found
- **Solution**: Add `-L uvm` flag to compilation options

**Problem**: Simulation hangs
- **Solution**: Check that objections are raised/dropped in test

## Resources

- [UVM Tutorial (Verification Academy)](https://verificationacademy.com/topics/verification-methodology/uvm)
- [UVM Cookbook](https://verificationacademy.com/cookbook/uvm)
