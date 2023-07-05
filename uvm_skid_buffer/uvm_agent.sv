class m_agent extends uvm_agent;
    `uvm_component_utils(m_agent)
    function new(string name="m_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    m_driver d0;
    m_monitor m0;
    uvm_sequencer #(m_reg_item) s0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s0 = uvm_sequencer#(m_reg_item)::type_id::create("s0", this);
        d0 = m_driver::type_id::create("d0", this);
        m0 = m_monitor::type_id::create("m0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        begin
            gen_item_seq seq;
            seq = gen_item_seq::type_id::create("seq", this);
            s0.start(seq);
        end
        phase.drop_objection(this);
    endtask
endclass

class s_agent extends uvm_agent;
    `uvm_component_utils(s_agent)
    function new(string name="s_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    s_monitor m0;
    s_driver d0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m0 = s_monitor::type_id::create("m0", this);
        d0 = s_driver::type_id::create("d0", this);
    endfunction
endclass