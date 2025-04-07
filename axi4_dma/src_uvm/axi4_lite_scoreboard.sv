`ifndef UVM_AXI4_LITE_SCOREBOARD
`define UVM_AXI4_LITE_SCOREBOARD

class uvm_axi4_lite_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(uvm_axi4_lite_transaction, uvm_axi4_lite_scoreboard) scoreboard_port;

    uvm_axi4_lite_transaction item_q[$];
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
    endfunction

endclass

`endif
