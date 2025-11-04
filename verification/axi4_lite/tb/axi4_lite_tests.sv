`ifndef UVM_AXI4_LITE_TESTS
`define UVM_AXI4_LITE_TESTS

class no_activity_test extends uvm_test;

    uvm_axi4_lite_environment env;
    uvm_axi4_lite_no_activity_sequence run;

    
    `uvm_component_utils(no_activity_test)
    function new(
        input string name = "no_activity_test",
        input uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uvm_axi4_lite_environment::type_id::create("env", this);
        run = uvm_axi4_lite_no_activity_sequence::type_id::create("run");
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("", "Hello UVM World!", UVM_LOW)
        run.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass

class random_write_test extends uvm_test;

    uvm_axi4_lite_environment env;
    uvm_axi4_lite_random_write_sequence run;
    
    `uvm_component_utils(random_write_test)
    function new(
        input string name = "random_write_test",
        input uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uvm_axi4_lite_environment::type_id::create("env", this);
        run = uvm_axi4_lite_random_write_sequence::type_id::create("run");
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("", "Hello UVM World!", UVM_LOW)
        run.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass
`endif
