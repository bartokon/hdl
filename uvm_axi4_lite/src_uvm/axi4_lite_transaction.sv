`ifndef UVM_AXI4_LITE_TRANSACTION
`define UVM_AXI4_LITE_TRANSACTION

class uvm_axi4_lite_transaction extends uvm_sequence_item;
    rand bit [31:0]   addr;
    rand bit [31:0]   data_write;
    bit [31:0]        data_read;

    `uvm_object_utils_begin(uvm_axi4_lite_transaction)
        `uvm_field_int  (addr,              UVM_DEFAULT)
        `uvm_field_int  (data_write,        UVM_DEFAULT)
        `uvm_field_int  (data_read,         UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "uvm_axi4_lite_transaction");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "addr='h%h, data_write='h%0h, data_read='h%0h",
                addr, data_write, data_read
            );
    endfunction

endclass

`endif
