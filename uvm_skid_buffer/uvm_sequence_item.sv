//Reg item same for M and S port
//Reg item should have handshake ports?
//TODO: make one class from this packets
class m_reg_item extends uvm_sequence_item;
    rand bit [8 - 1 : 0] data;
    `uvm_object_utils_begin(m_reg_item)
        `uvm_field_int (data, UVM_DEFAULT);
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformat("data = 0x%0h", data);
    endfunction

    function new(string name = "m_reg_item");
        super.new(name);
    endfunction
endclass

class s_reg_item extends uvm_sequence_item;
    rand bit [8 - 1 : 0] data;
    `uvm_object_utils_begin(s_reg_item)
        `uvm_field_int (data, UVM_DEFAULT);
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformat("data = 0x%0h", data);
    endfunction

    function new(string name = "s_reg_item");
        super.new(name);
    endfunction
endclass
