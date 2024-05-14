`ifndef UVM_MONITOR
`define UVM_MONITOR

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "interface.sv"
`include "uvm_sequence_item.sv"

class axi4_stream_monitor #(string interface_name = "") extends uvm_monitor;

    uvm_analysis_port #(sequence_item) monitor_port;
    virtual axi4_stream vif;
    sequence_item item;

    `uvm_component_utils(axi4_stream_monitor#(.interface_name(interface_name)))
    function new(input string name = "axi4_stream_monitor", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_stream)::get(this, "", interface_name, vif)) begin
            `uvm_fatal("MON", "Could not get vif")
        end
        monitor_port = new ("monitor_port", this);
        item = sequence_item::type_id::create("sequence_item");
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge vif.clk);
            if (vif.valid && vif.ready) begin
                `uvm_info(get_type_name(), $sformatf("master monitor found packet: %x", vif.data), UVM_LOW);
                item.data <= vif.data;
                monitor_port.write(item);
            end
        end
    endtask
endclass

`endif