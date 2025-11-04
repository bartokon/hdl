`ifndef UVM_AXI4_LITE_SEQUENCER
`define UVM_AXI4_LITE_SEQUENCER

class uvm_axi4_lite_sequencer extends uvm_sequencer #(uvm_axi4_lite_transaction);
    `uvm_component_utils(uvm_axi4_lite_sequencer)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass

`endif
