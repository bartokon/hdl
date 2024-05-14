`ifndef UVM_SEQUENCE
`define UVM_SEQUENCE

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_sequence_item.sv"
`include "interface.sv"

class reset_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(reset_sequence)
    function new(input string name="reset_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        for (int i = 0; i < 8; ++i) begin 
            sequence_item item = sequence_item::type_id::create("reset_sequence");
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error("MY_SEQUENCE", "Randomize failed.");
            end
            item.resetn = 0;
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            item.print();
            finish_item(item);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", 8), UVM_LOW)
    endtask
    
endclass

class run_sequence extends reset_sequence;

    `uvm_object_utils(run_sequence)
    function new(input string name="run_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        for (int i = 0; i < 8; ++i) begin 
            sequence_item item = sequence_item::type_id::create("run_sequence");
            start_item(item);
            if (!item.randomize()) begin
                `uvm_error("MY_SEQUENCE", "Randomize failed.");
            end
            item.resetn = 1;
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            item.print();
            finish_item(item);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", 8), UVM_LOW)
    endtask
    
endclass

class empty_sequence extends reset_sequence;

    `uvm_object_utils(empty_sequence)
    function new(input string name="empty_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        for (int i = 0; i < 8; ++i) begin 
            sequence_item item = sequence_item::type_id::create("empty_sequence");
            start_item(item);
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            item.print();
            finish_item(item);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", 8), UVM_LOW)
    endtask
    
endclass

`endif