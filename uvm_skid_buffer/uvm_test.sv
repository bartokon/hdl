`include "package.sv"

class test extends uvm_test;

    `uvm_component_utils(test)
    function new(string name = "test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    env e0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env::type_id::create("e0", this);       
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #10;
        `uvm_warning("", "Hello World!")
        phase.drop_objection(this);
    endtask
    
endclass