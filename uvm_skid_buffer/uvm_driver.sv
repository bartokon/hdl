class m_driver extends uvm_driver#(m_reg_item);
    `uvm_component_utils(m_driver)
    function new(string name = "m_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual axi4_stream_master vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
            if (!uvm_config_db#(virtual axi4_stream_master)::get(this, "", "axi4_stream_master", vif)) begin 
                `uvm_fatal("DRV", "Could not get vif");
            end    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
            forever begin 
                m_reg_item m_item;
                `uvm_info("DRV", $sformatf("Wait fori tem from sequencer"), UVM_LOW);
                //Is seq_item_port standard connection?
                seq_item_port.get_next_item(m_item);
                drive_item(m_item);
                seq_item_port_item_done();
            end
    endtask

    virtual task drive_item(m_reg_item m_item);
        vif.data <= m_item.data;
        vif.valid <= 1;
        @(posedge vif.clk) begin 
            while (!vif.ready) begin 
                `uvm_info("M_DRV", "Wait until ready is high", UVM_LOW);
                @(posedge vif.clk);
            end
        end
        @(negedge vif.clk) begin 
            vif.valid <= 0;
        end
    endtask
    
endclass

class s_driver extends uvm_driver#(s_reg_item);
    `uvm_component_utils(s_driver)
    function new(string name = "s_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual axi4_stream_slave vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
            if (!uvm_config_db#(virtual axi4_stream_slave)::get(this, "", "axi4_stream_slave", vif)) begin 
                `uvm_fatal("S_DRV", "Could not get vif");
            end    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
            forever begin
                @(posedge vif.clk) begin
                    vif.ready <= $random % 1; //Should be 0 or 1
                end
            end
    endtask
    
endclass