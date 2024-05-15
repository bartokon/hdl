`ifndef UVM_DRIVER
`define UVM_DRIVER

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_sequence_item.sv"
`include "interface.sv"

class axi4_stream_driver #(string interface_name = "") extends uvm_driver #(sequence_item);

    virtual axi4_stream vif;
    sequence_item item;
    integer count;
    
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
            count = 0;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
            forever begin
                seq_item_port.get_next_item(item);
                drive_item(item, count++);
                seq_item_port.item_done();
            end
    endtask

    virtual task drive_item(sequence_item item, integer count);
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
    
    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        phase.raise_objection(this);
        `uvm_info("", "Reset From driver...!", UVM_LOW)
        vif.data <= 0;
        vif.rstn <= 0;
        vif.valid <= 0;
        #100 vif.rstn <= 1;
        phase.drop_objection(this);
    endtask
    
    virtual task drive_item(sequence_item item, integer count);
        `uvm_info("MASTER DRIVER", $sformatf("Started driving item. %d", count), UVM_LOW);
        @(posedge vif.clk) begin 
            vif.data <= item.data;
            vif.rstn <= item.resetn;
            vif.valid <= 1;
        end
        forever begin 
            @(posedge vif.clk) begin 
                if (vif.ready && vif.valid) break;
            end 
        end
        @(negedge vif.clk) begin 
            vif.valid <= 0;
            vif.data <= 'x;
        end
        `uvm_info("MASTER DRIVER", $sformatf("Done driving item. %d", count), UVM_LOW);
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
    
    virtual task drive_item(sequence_item item, integer count);
        `uvm_info("SLAVE DRIVER", $sformatf("Started driving item. %d", count), UVM_LOW);
        @(posedge vif.clk) begin 
            vif.ready <= 1;
        end
        forever begin 
            @(posedge vif.clk) begin 
                if (vif.ready && vif.valid) break;
            end 
        end
        @(negedge vif.clk) begin
            vif.ready <= 0;
        end
        `uvm_info("SLAVE DRIVER", $sformatf("Done driving item. %d", count), UVM_LOW);
    endtask

endclass
`endif