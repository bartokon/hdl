`ifndef UVM_AXI4_LITE_DRIVER
`define UVM_AXI4_LITE_DRIVER

class uvm_axi4_lite_driver extends uvm_driver #(uvm_axi4_lite_transaction);
    protected virtual axi4_lite_if vif;
    uvm_axi4_lite_transaction transaction;
    int unsigned i = 0;

    `uvm_component_utils(uvm_axi4_lite_driver)
    uvm_analysis_port#(uvm_axi4_lite_transaction) driver_analysis_port;
    function new (
        string name,
        uvm_component parent
    );
        super.new(
            name,
            parent
        );
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4_lite_if)::get(
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
         driver_analysis_port = new("driver_analysis_port", this);
         transaction = uvm_axi4_lite_transaction::type_id::create("transaction");
    endfunction

    virtual task run_phase (uvm_phase phase);
        reset();
        forever begin
            seq_item_port.get_next_item(transaction);
            `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER %d", ++i), UVM_LOW);
            `uvm_info(get_full_name(), transaction.convert2string(), UVM_LOW);
            drive();
            seq_item_port.item_done();
        end
    endtask

    virtual protected task reset();
        vif.awaddr <= 0;
        vif.awvalid <= 0;
        vif.wdata <= 0;
        vif.wstrb <= 0;
        vif.wvalid <= 0;
        vif.bready <= 0;
        vif.araddr <= 0;
        vif.arvalid <= 0;
        vif.rready <= 0;
    endtask

    virtual protected task drive();
        wait(vif.arstn);
        fork
            drive_write_address_channel();
            drive_write_data_channel();
            drive_response_channel();
        join
        fork
            drive_read_address_channel();
            drive_read_data_channel();
        join
    endtask

    virtual protected task drive_write_address_channel();
        @(posedge vif.aclk);
        vif.awaddr <= transaction.addr;
        vif.awvalid <= 1'b1;
        wait(vif.awvalid && vif.awready);
        @(posedge vif.aclk);
        vif.awvalid <= 1'b0;
    endtask

    virtual protected task drive_write_data_channel();
        @(posedge vif.aclk);
        vif.wdata <= transaction.data_write;
        vif.wstrb <= 4'b1111;
        vif.wvalid <= 1'b1;
        wait(vif.wvalid && vif.wready);
        @(posedge vif.aclk);
        vif.wstrb <= 4'b0000;
        vif.wvalid <= 1'b0;
    endtask

    virtual protected task drive_response_channel();
        @(posedge vif.aclk);
        vif.bready <= 1'b1;
        wait(vif.bvalid && vif.bready);
        @(posedge vif.aclk);
        vif.bready <= 1'b0;
    endtask

    virtual protected task drive_read_address_channel();
        @(posedge vif.aclk);
        vif.araddr <= transaction.addr;
        vif.arvalid <= 1'b1;
        wait(vif.arvalid && vif.arready);
        @(posedge vif.aclk);
        vif.arvalid <= 1'b0;
    endtask

    virtual protected task drive_read_data_channel();
        @(posedge vif.aclk);
        vif.rready <= 1'b1;
        wait(vif.rvalid && vif.rready);
        transaction.data_read <= vif.rdata;
        @(posedge vif.aclk);
        vif.rready <= 1'b0;
    endtask

endclass

`endif
