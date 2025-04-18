`ifndef UVM_AXI4_LITE_SEQUENCER_LIBRARY
`define UVM_AXI4_LITE_SEQUENCER_LIBRARY

virtual class uvm_axi4_lite_base_sequence extends uvm_sequence #(uvm_axi4_lite_transaction);

    function new (string name="uvm_axi4_lite_base_sequence");
        super.new(name);
    endfunction

endclass

class uvm_axi4_lite_no_activity_sequence extends uvm_axi4_lite_base_sequence;
    `uvm_object_utils(uvm_axi4_lite_no_activity_sequence)

    function new(string name="uvm_axi4_lite_no_activity_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "executing", UVM_LOW)
    endtask

endclass

class uvm_axi4_lite_random_write_sequence extends uvm_axi4_lite_base_sequence;
    `uvm_object_utils(uvm_axi4_lite_random_write_sequence)

    function new(string name="uvm_axi4_lite_random_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uvm_axi4_lite_transaction item;
        int unsigned num_txn = 100;
        `uvm_info("SEQ", "executing...", UVM_LOW)
        for (int unsigned i = 0; i < num_txn; ++i) begin
            `uvm_create(item)
            item.randomize();
            item.addr = i * 4;
            `uvm_send(item);
        end
    endtask

endclass

`endif
