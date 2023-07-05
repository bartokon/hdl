`uvm_analysis_imp_decl(_m)
`uvm_analysis_imp_decl(_s)

class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)
    function new(string name="scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    
    uvm_analysis_imp_m #(m_reg_item, scoreboard) m_analysis_imp;
    uvm_analysis_imp_s #(s_reg_item, scoreboard) s_analysis_imp;
    m_reg_item m_item_q[$];
    s_reg_item s_item_q[$];

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
        s_analysis_imp = new("s_analysis_imp", this);
    endfunction

    //Write to m port
    virtual function write_m(m_reg_item item);
        `uvm_info(get_type_name(), $sformatf("M_REG: Scoreboard got: 0x%h", item.data), UVM_LOW)
        m_item_q.push_back(item);
    endfunction

    //Write to s port
    virtual function write_s(s_reg_item item);
        `uvm_info(get_type_name(), $sformatf("S_REG: Scoreboard got: 0x%h", item.data), UVM_LOW)
        s_item_q.push_back(item);
    endfunction

    //Check realtime for errors
    task run_phase(uvm_phase phase);
        if (m_item_q.size() != 0 && s_item_q.size() != 0) begin
            m_reg_item master_d = m_item_q.pop_front();
            s_reg_item slave_d = s_item_q.pop_front();
            if (master_d.data != slave_d.data) begin 
                $display("Test failed. Data doesn't match! \n");
                $stop();
            end
        end
    endtask
endclass