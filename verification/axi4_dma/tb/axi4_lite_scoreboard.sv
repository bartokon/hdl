`ifndef UVM_AXI4_LITE_SCOREBOARD
`define UVM_AXI4_LITE_SCOREBOARD

class uvm_axi4_lite_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(uvm_axi4_lite_transaction, uvm_axi4_lite_scoreboard) scoreboard_port;

    uvm_axi4_lite_transaction item_q[$];
    uvm_axi4_lite_transaction item_good_q[$];
    uvm_axi4_lite_transaction item_bad_q[$];
    uvm_axi4_lite_transaction item;

    `uvm_component_utils(uvm_axi4_lite_scoreboard)
    function new(input string name="uvm_axi4_lite_scoreboard", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        scoreboard_port = new("scoreboard_port", this);
    endfunction

    virtual function void write(uvm_axi4_lite_transaction transaction);
        `uvm_info(
            get_full_name(),
            $sformatf("Recieved: %s", transaction.convert2string()),
            UVM_MEDIUM
        );
        item_q.push_back(transaction);
        `uvm_info(
            get_full_name(),
            $sformatf("Pushed: %s", transaction.convert2string()),
            UVM_MEDIUM
        );
        `uvm_info(
            get_full_name(),
            $sformatf("Queue size: %0d", item_q.size()),
            UVM_MEDIUM
        );
    endfunction

    virtual function void check_phase(input uvm_phase phase);
        super.check_phase(phase);
        if (item_q.size() == 0) begin
            `uvm_fatal(get_full_name(), "No transactions received");
        end else begin
            `uvm_info(get_full_name(), $sformatf("Received %0d transactions", item_q.size()), UVM_MEDIUM);
        end
        foreach (item_q[i]) begin
            item = item_q[i];
            `uvm_info(get_full_name(), $sformatf("Transaction %0d: %s", i, item.convert2string()), UVM_MEDIUM);
            check_data(item);
        end
    endfunction

    function void check_data(uvm_axi4_lite_transaction transaction);
        if (transaction.data_write != transaction.data_read) begin
            `uvm_fatal(get_full_name(), $sformatf("Data mismatch: %s", transaction.convert2string()));
            item_bad_q.push_back(transaction);
        end else begin
            `uvm_info(get_full_name(), $sformatf("Data match: %s", transaction.convert2string()), UVM_MEDIUM);
            item_good_q.push_back(transaction);
        end
    endfunction

    virtual function void report_phase(input uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_full_name(), $sformatf("Good transactions: %0d", item_good_q.size()), UVM_MEDIUM);
        `uvm_info(get_full_name(), $sformatf("Bad transactions: %0d", item_bad_q.size()), UVM_MEDIUM);
        if (item_bad_q.size() > 0) begin
            `uvm_fatal(get_full_name(), "Some transactions failed");
        end else begin
            `uvm_info(get_full_name(), "All transactions passed", UVM_MEDIUM);
        end
        `uvm_info(get_full_name(), "Scoreboard finished", UVM_MEDIUM);
    endfunction

endclass

`endif
