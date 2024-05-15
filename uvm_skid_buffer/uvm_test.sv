`ifndef UVM_TEST
`define UVM_TEST

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uvm_environment.sv"
`include "uvm_sequence.sv"

class test extends uvm_test;

    localparam string axi4_stream_master_port = "axi4_stream_input";
    localparam string axi4_stream_slave_port = "axi4_stream_output";
    env #(
        .axi4_stream_master_port(this.axi4_stream_master_port),
        .axi4_stream_slave_port(this.axi4_stream_slave_port)
    ) e0;
    reset_sequence reset;
    run_sequence run;
    empty_sequence empty;
    
    `uvm_component_utils(test)
    function new(
        input string name = "test",
        input uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env #(
            .axi4_stream_master_port(this.axi4_stream_master_port),
            .axi4_stream_slave_port(this.axi4_stream_slave_port)
        )::type_id::create("e0", this);
        reset = reset_sequence::type_id::create("reset");
        run = run_sequence::type_id::create("run");
        empty = empty_sequence::type_id::create("empty");
    endfunction
        
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        `uvm_info("", "Hello UVM World!", UVM_LOW)
    endtask

    virtual task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("", "Run Sequence!", UVM_LOW)
        fork
            run.start(e0.a0.s0);
            #50 empty.start(e0.b0.s0);
        join
        phase.drop_objection(this);
    endtask
    
endclass

`endif