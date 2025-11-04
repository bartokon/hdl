`ifndef UVM_SEQUENCER
`define UVM_SEQUENCER

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_sequence_item.sv"

class sequencer extends uvm_sequencer #(sequence_item);

    `uvm_component_utils(sequencer)
    function new(input string name="sequencer", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

endclass

class delay_sequencer extends uvm_sequencer #(delay_sequence_item);

    `uvm_component_utils(delay_sequencer)
    function new(input string name="delay_sequencer", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

endclass

`endif