`ifndef UVM_SEQUENCE_ITEM
`define UVM_SEQUENCE_ITEM

import uvm_pkg::*;
`include "uvm_macros.svh"

class sequence_item extends uvm_sequence_item;

    rand logic [8 - 1 : 0] data = 'x;
    logic resetn = 1;
    
    `uvm_object_utils(sequence_item)
    function new(input string name = "sequence_item");
        super.new(name);
    endfunction
    
endclass

class delay_sequence_item extends uvm_sequence_item;

    rand integer delay = 0;
    
    `uvm_object_utils(delay_sequence_item)
    function new(input string name = "delay_sequence_item");
        super.new(name);
    endfunction
    
    constraint delay_high { delay < 1; }; 
    constraint delay_low { delay >= 0; };
    
endclass

`endif