`ifndef UVM_SCOREBOARD
`define UVM_SCOREBOARD

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uvm_sequence_item.sv"

//Where?
`uvm_analysis_imp_decl(_master_port)
`uvm_analysis_imp_decl(_slave_port)

class scoreboard extends uvm_scoreboard;

    uvm_analysis_imp_master_port #(sequence_item, scoreboard) scoreboard_master_port;
    uvm_analysis_imp_slave_port #(sequence_item, scoreboard) scoreboard_slave_port;
    
    sequence_item m_item_q[$];
    sequence_item s_item_q[$];
    sequence_item i_m;
    sequence_item i_s;
    
    `uvm_component_utils(scoreboard)
    function new(input string name="scoreboard", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        scoreboard_master_port = new("scoreboard_master_port", this);
        scoreboard_slave_port = new("scoreboard_slave_port", this);
    endfunction

    virtual function void write_master_port(input sequence_item item);
        `uvm_info(get_type_name(), $sformatf("Scoreboard master port got: %x", item.data), UVM_LOW)
        m_item_q.push_back(item);
    endfunction

    virtual function void write_slave_port(input sequence_item item);
        `uvm_info(get_type_name(), $sformatf("Scoreboard slave port got: %x", item.data), UVM_LOW)
        s_item_q.push_back(item);
    endfunction

    virtual task run_phase(input uvm_phase phase);
        forever begin
            wait(m_item_q.size() != 0);
            i_m = m_item_q.pop_front();
            `uvm_info( \
                get_type_name(), \
                $sformatf("Scoreboard master poped item: %x", i_m.data), \
                UVM_LOW \
            )
            wait(s_item_q.size() != 0);
            i_s = s_item_q.pop_front(); 
            `uvm_info( \
                get_type_name(), \
                $sformatf("Scoreboard slave poped item: %x", i_s.data), \
                UVM_LOW \
            )
            if (i_m.data != i_s.data) begin 
            `uvm_error( \
                get_type_name(), \
                $sformatf("Scoreboard mismatch %x vs %x", i_m.data, i_s.data) \
            )
            $stop;
            end
        end
     endtask
//    virtual function void check_phase(input uvm_phase phase);
//        super.check_phase(phase);
//        if (m_item_q.size() != s_item_q.size()) begin 
//            `uvm_error( \
//                get_type_name(), \
//                $sformatf("Scoreboard size mismatch %x vs %x", m_item_q.size(), s_item_q.size()) \
//            )
//        end
//        `uvm_info( \
//            get_type_name(), \
//            $sformatf("Scoreboard sizes are equal."), \
//            UVM_LOW \
//        )
//        for (int i = 0; i < m_item_q.size(); ++i) begin 
//            i_m = m_item_q.pop_front();
//            `uvm_info( \
//                get_type_name(), \
//                $sformatf("i_m: %x", i_m.data), \
//                UVM_LOW \
//            )
//        end
//        for (int i = 0; i < s_item_q.size(); ++i) begin 
//            i_s = s_item_q.pop_front();
//            `uvm_info( \
//                get_type_name(), \
//                $sformatf("i_m: %x", i_s.data), \
//                UVM_LOW \
//            )
//        end
//    endfunction

endclass

`endif
