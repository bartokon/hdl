class m_monitor extends uvm_monitor;

    `uvm_component_utils(m_monitor)
    function new(string name="m_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(m_reg_item) mon_analysis_port;
    virtual axi4_stream_master vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_stream_master)::get(this, "", "axi4_stream_master", vif)) begin 
            `uvm_fatal("MON", "Could not get vif")
        end
            mon_analysis_port = new ("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge vif.clk);
            if (vif.valid && vif.ready) begin
                virtual axi4_stream_master item = new;
                item.data = vif.data;
                `uvm_info(get_type_name(), $sformatf("m_monitor found packet %s", item.convert2str()), UVM_LOW);
                mon_analysis_port.write(item);
            end
        end
    endtask
    
endclass

class s_monitor extends uvm_monitor;

    `uvm_component_utils(s_monitor)
    function new(string name="s_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(s_reg_item) mon_analysis_port;
    virtual axi4_stream_slave vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_stream_slave)::get(this, "", "axi4_stream_slave", vif)) begin 
            `uvm_fatal("MON", "Could not get vif")
        end
            mon_analysis_port = new ("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge vif.clk);
            if (vif.valid && vif.ready) begin
                virtual axi4_stream_slave item = new;
                item.data = vif.data;
                `uvm_info(get_type_name(), $sformatf("s_monitor found packet %s", item.convert2str()), UVM_LOW);
                mon_analysis_port.write(item);
            end
        end
    endtask
    
endclass