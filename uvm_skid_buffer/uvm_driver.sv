`ifndef UVM_DRIVER
`define UVM_DRIVER

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_sequence_item.sv"
`include "interface.sv"

class axi4_stream_driver #(string interface_name = "") extends uvm_driver #(sequence_item);

    virtual axi4_stream vif;
    sequence_item item;

    `uvm_component_utils(axi4_stream_driver#(.interface_name(interface_name)))
    function new(input string name = "axi4_stream_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
            if (!uvm_config_db#(virtual axi4_stream)::get(this, "", interface_name, vif)) begin
                `uvm_fatal("DRV", "Could not get axi4_stream vif");
            end
            item = sequence_item::type_id::create("sequence_item");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
            forever begin
                `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW);
                seq_item_port.get_next_item(item);
                 `uvm_info("DRV", $sformatf("Got item from sequencer"), UVM_LOW);
                drive_item(item);
                 `uvm_info("DRV", $sformatf("Wait for next item from sequencer"), UVM_LOW);
                seq_item_port.item_done();
            end
    endtask

    virtual task drive_item(sequence_item item);
    endtask
    
endclass

class axi4_stream_master_driver #(string interface_name = "") extends axi4_stream_driver #(.interface_name(interface_name));

    `uvm_component_utils(axi4_stream_master_driver #(.interface_name(interface_name)))
    function new(input string name = "axi4_stream_master_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    virtual task drive_item(sequence_item item);
        vif.data <= item.data;
        vif.rstn <= item.resetn;
        vif.valid <= 1;
        @(posedge vif.clk)
        wait (vif.ready && vif.valid);
//            while (!vif.ready) begin
//                `uvm_info("axi4_stream_master driver", "Wait until ready is high", UVM_LOW);
//                @(posedge vif.clk);
//            end
        @(negedge vif.clk);
        vif.valid <= 0;
        vif.data <= 0;
    endtask

endclass

class axi4_stream_slave_driver #(string interface_name = "") extends axi4_stream_driver #(.interface_name(interface_name));

    `uvm_component_utils(axi4_stream_slave_driver #(.interface_name(interface_name)))
    function new(input string name = "axi4_stream_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        vif.ready <= 0;
    endfunction
    
    virtual task drive_item(sequence_item item);
        vif.ready <= 1;
        @(posedge vif.clk);
        wait (vif.ready && vif.valid);
//        while (!vif.valid) begin
//            `uvm_info("axi4_stream_slave_driver", "Wait until valid is high", UVM_LOW);
//        end     
        @(negedge vif.clk);
        vif.ready <= 0;
    endtask

endclass
`endif