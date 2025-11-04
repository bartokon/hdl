`ifndef UVM_AXI4_LITE_AGENT
`define UVM_AXI4_LITE_AGENT

class uvm_axi4_lite_agent extends uvm_agent;

    uvm_axi4_lite_sequencer sqr;
    uvm_axi4_lite_driver drv;
    uvm_axi4_lite_monitor mon;

    `uvm_component_utils(uvm_axi4_lite_agent)

    function new (string name, uvm_component parent);
       super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = uvm_axi4_lite_monitor::type_id::create("mon", this);
        sqr = uvm_axi4_lite_sequencer::type_id::create("sqr", this);
        drv = uvm_axi4_lite_driver::type_id::create("drv", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction 

endclass

`endif



