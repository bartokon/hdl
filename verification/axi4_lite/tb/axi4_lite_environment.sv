`ifndef UVM_AXI4_LITE_ENVIRONMENT
`define UVM_AXI4_LITE_ENVIRONMENT

class uvm_axi4_lite_environment extends uvm_env;

    uvm_axi4_lite_agent agt;
    uvm_axi4_lite_scoreboard scr;

    `uvm_component_utils(uvm_axi4_lite_environment)
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt = uvm_axi4_lite_agent::type_id::create("agt", this);
        scr = uvm_axi4_lite_scoreboard::type_id::create("scr", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.monitor_to_scoreboard_port.connect(scr.scoreboard_port);
    endfunction

endclass

`endif

