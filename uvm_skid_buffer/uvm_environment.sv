class env extends uvm_env;

    `uvm_component_utils(env)
    function new(string name="env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    m_agent a0;
    s_agent b0;
    scoreboard sb0;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a0 = m_agent::type_id::create("a0", this);
        b0 = s_agent::type_id::create("b0", this);
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
        b0.m0.mon_analysis_port.connect(sb0.s_analysis_imp);
    endfunction
    
endclass