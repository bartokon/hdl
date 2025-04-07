`ifndef UVM_AXI4_LITE_MONITOR
`define UVM_AXI4_LITE_MONITOR

class uvm_axi4_lite_monitor extends uvm_monitor;
    protected virtual axi4_lite_if vif;

    uvm_analysis_port #(uvm_axi4_lite_transaction) monitor_to_scoreboard_port;
    uvm_axi4_lite_transaction transaction;
    `uvm_component_utils(uvm_axi4_lite_monitor)

    function new (string name, uvm_component parent);
        super.new(name, parent);
        monitor_to_scoreboard_port = new("monitor_to_scoreboard_port", this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi4_lite_if)::get(
                this, "", "dut_vif", vif
            )
        )
        `uvm_fatal(
            "NOVIF",
            {
                "virtual interface must be set for: ",
                get_full_name(),
                ".vif"
            }
        );
    endfunction

    virtual task run_phase (uvm_phase phase);
        forever begin
            transaction = uvm_axi4_lite_transaction::type_id::create($sformatf("tr_%0t", $time), this);;
            collect_transactions();
            monitor_to_scoreboard_port.write(transaction);
        end
    endtask

    virtual protected task collect_transactions();
        wait(vif.arstn);
        fork
            address_write_transaction();
            write_data_transaction();
            write_response_transaction();
            address_read_transaction();
            read_data_transaction();
        join
        `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"),UVM_LOW);
        `uvm_info(get_full_name(),transaction.convert2string(),UVM_LOW);
    endtask

    virtual protected task address_write_transaction();
        forever begin
            @(posedge vif.aclk) begin
                if (vif.awvalid && vif.awready) begin
                    transaction.addr = vif.awaddr;
                    break;
                end
            end
        end
    endtask

    virtual protected task write_data_transaction();
        forever begin
            @(posedge vif.aclk) begin
                if (vif.wvalid && vif.wready) begin
                    transaction.data_write = vif.wdata;
                    break;
                end
            end
        end
    endtask

    virtual protected task write_response_transaction();
        forever begin
            @(posedge vif.aclk) begin
                if (vif.bvalid && vif.bready) begin
                    break;
                end
            end
        end
    endtask

    virtual protected task address_read_transaction();
        forever begin
            @(posedge vif.aclk) begin
                if (vif.arvalid && vif.arready) begin
                    break;
                end
            end
        end
    endtask

    virtual protected task read_data_transaction();
        forever begin
            @(posedge vif.aclk) begin
                if (vif.rvalid && vif.rready) begin
                    transaction.data_read = vif.rdata;
                    break;
                end
            end
        end
    endtask

endclass

`endif
