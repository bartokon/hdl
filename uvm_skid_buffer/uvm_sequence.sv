//Generate seqeunce of packets
`include "interface.sv"

class gen_item_seq extends uvm_sequence #(m_reg_item);
    `uvm_component_utils(gen_item_seq)
    function new(string name="gen_item_seq");
        super.new(name);
    endfunction

    virtual task body();
        for (int i = 0; i < 8; ++i) begin 
            virtual axi4_stream_master m_item = m_reg_item::type_id::create("m_item");
            start_item(m_item);
            if (!m_item.randomize()) begin
                `uvm_error("MY_SEQUENCE", "Randomize failed.");
            end
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            m_item.print();
            finish_item(m_item);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", 8), UVM_LOW)
    endtask
    
endclass