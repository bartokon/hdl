`ifndef UVM_AGENT
`define UVM_AGENT

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_driver.sv"
`include "uvm_monitor.sv"
`include "uvm_sequencer.sv"

class axi4_stream_master_agent #(string interface_name = "") extends uvm_agent;

    axi4_stream_master_driver #(.interface_name(interface_name)) d0;
    axi4_stream_monitor #(.interface_name(interface_name)) m0;
    sequencer s0;

    `uvm_component_utils(axi4_stream_master_agent #(.interface_name(interface_name)))
    function new(input string name="axi4_stream_master_agent", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d0 = axi4_stream_master_driver #(.interface_name(interface_name))::type_id::create("d0", this);
        m0 = axi4_stream_monitor #(.interface_name(interface_name))::type_id::create("m0", this);
        s0 = sequencer::type_id::create("s0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction

endclass

class axi4_stream_slave_agent #(string interface_name = "") extends uvm_agent;

    axi4_stream_slave_driver #(.interface_name(interface_name)) d0;
    axi4_stream_monitor #(.interface_name(interface_name)) m0;
    delay_sequencer s0;

    `uvm_component_utils(axi4_stream_slave_agent #(.interface_name(interface_name)))
    function new(input string name="axi4_stream_slave_agent", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s0 = delay_sequencer::type_id::create("s0", this);
        d0 = axi4_stream_slave_driver #(.interface_name(interface_name))::type_id::create("d0", this);
        m0 = axi4_stream_monitor #(.interface_name(interface_name))::type_id::create("m0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction

endclass

`endif