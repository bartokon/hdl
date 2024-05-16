`ifndef UVM_ENVIRONMENT
`define UVM_ENVIRONMENT

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_scoreboard.sv"
`include "uvm_agent.sv"

class env #(
    string axi4_stream_master_port = "",
    string axi4_stream_slave_port = ""
) extends uvm_env;

    axi4_stream_master_agent #(.interface_name(axi4_stream_master_port)) a0;
    axi4_stream_slave_agent #(.interface_name(axi4_stream_slave_port)) b0;
    scoreboard sb0;

    `uvm_component_utils(env#(.axi4_stream_master_port(axi4_stream_master_port), .axi4_stream_slave_port(axi4_stream_slave_port)))
    function new(
        input string name = "env",
        input uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a0 = axi4_stream_master_agent #(.interface_name(axi4_stream_master_port))::type_id::create("a0", this);
        b0 = axi4_stream_slave_agent #(.interface_name(axi4_stream_slave_port))::type_id::create("b0", this);
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
        a0.m0.monitor_port.connect(sb0.scoreboard_master_port);
        b0.m0.monitor_port.connect(sb0.scoreboard_slave_port);
    endfunction

endclass

`endif