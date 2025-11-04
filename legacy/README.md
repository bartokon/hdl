# Legacy Code

This directory contains deprecated Verilog implementations that have been superseded by SystemVerilog versions.

## Contents

All files in `legacy/verilog/` are **v1 implementations** now replaced by improved versions in the `ip/` directory.

### Migration Guide

| Legacy File | Current Location | Notes |
|-------------|------------------|-------|
| axi4_lite.v | ip/axi/axi4_lite_core/src/axi4_lite_v2.sv | Enhanced SystemVerilog |
| axi4_lite_read_manager.v | ip/axi/axi4_lite_channels/src/*_v2.sv | Split into separate modules |
| axi4_lite_write_manager.v | ip/axi/axi4_lite_channels/src/*_v2.sv | Split into separate modules |
| axi4_lite_master_with_lut.v | ip/axi/axi4_lite_master/src/*.sv | Modular SystemVerilog |
| axi4_lite_v2_wrapper.v | - | Deprecated wrapper |
| axi4_m.v | ip/axi/axi4_master/src/*.sv | SystemVerilog version |
| skid_buffer_wrapper.v | ip/buffers/skid_buffer/src/skid_buffer.sv | Native SystemVerilog |

## Why Keep Legacy Code?

- **Reference**: Historical implementations for comparison
- **Compatibility**: Some projects may still reference v1 files
- **Learning**: Shows evolution from Verilog to SystemVerilog

## Should I Use This Code?

**No.** Use the SystemVerilog versions in the `ip/` directory instead.

Legacy code is:
- ❌ Not actively maintained
- ❌ Missing modern features
- ❌ Less verified

## Removal Plan

Legacy files may be removed in future releases once all projects are migrated to v2 implementations.

---

**Last Updated**: From repository reorganization (Approach #3: Hybrid Modular)
