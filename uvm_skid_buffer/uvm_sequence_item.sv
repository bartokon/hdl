`ifndef UVM_SEQUENCE_ITEM
`define UVM_SEQUENCE_ITEM

import uvm_pkg::*;
`include "uvm_macros.svh"

class sequence_item extends uvm_sequence_item;

    rand bit [8 - 1 : 0] data;
    rand bit resetn;
    
    `uvm_object_utils(sequence_item)
    function new(input string name = "sequence_item");
        super.new(name);
    endfunction

    virtual function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field_int("data from item: ", data, $bits(data), UVM_HEX);
    endfunction
    
endclass

`endif