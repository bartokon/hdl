`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_item extends uvm_sequence_item;
  rand bit [7:0] ip1, ip2;
  bit [8:0] out;
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
  `uvm_object_utils_begin(seq_item)
    `uvm_field_int(ip1,UVM_ALL_ON)
    `uvm_field_int(ip2,UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint ip_c {ip1 < 100; ip2 < 100;}
endclass

class base_seq extends uvm_sequence#(seq_item);
  seq_item req;
  `uvm_object_utils(base_seq)
  
  function new (string name = "base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Base seq: Inside Body", UVM_LOW);
    `uvm_do(req);
  endtask
endclass

class seqcr extends uvm_sequencer#(seq_item);
  `uvm_component_utils(seqcr)
  
  function new(string name = "seqcr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

class driver extends uvm_driver#(seq_item);
  virtual add_if vif;
  `uvm_component_utils(driver)
  
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if) :: get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      // Driver to the DUT
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name, $sformatf("ip1 = %0d, ip2 = %0d", req.ip1, req.ip2), UVM_LOW);
      vif.ip1 <= req.ip1;
      vif.ip2 <= req.ip2;
      seq_item_port.item_done();
    end
  endtask
endclass

class monitor extends uvm_monitor;
  virtual add_if vif;
  uvm_analysis_port #(seq_item) item_collect_port;
  seq_item mon_item;
  `uvm_component_utils(monitor)
  
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
    mon_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if) :: get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      wait(!vif.reset);
      @(posedge vif.clk);
      mon_item.ip1 = vif.ip1;
      mon_item.ip2 = vif.ip2;
      `uvm_info(get_type_name, $sformatf("ip1 = %0d, ip2 = %0d", mon_item.ip1, mon_item.ip2), UVM_HIGH);
      @(posedge vif.clk);
      mon_item.out = vif.out;
      item_collect_port.write(mon_item);
    end
  endtask
endclass

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  driver drv;
  seqcr seqr;
  monitor mon;
  
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(get_is_active == UVM_ACTIVE) begin 
      drv = driver::type_id::create("drv", this);
      seqr = seqcr::type_id::create("seqr", this);
    end
    
    mon = monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    if(get_is_active == UVM_ACTIVE) begin 
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

class scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(seq_item, scoreboard) item_collect_export;
  seq_item item_q[$];
  `uvm_component_utils(scoreboard)
  
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collect_export = new("item_collect_export", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write(seq_item req);
    item_q.push_back(req);
  endfunction
  
  task run_phase (uvm_phase phase);
    seq_item sb_item;
    forever begin
      wait(item_q.size > 0);
      
      if(item_q.size > 0) begin
        sb_item = item_q.pop_front();
        $display("----------------------------------------------------------------------------------------------------------");
        if(sb_item.ip1 + sb_item.ip2 == sb_item.out) begin
          `uvm_info(get_type_name, $sformatf("Matched: ip1 = %0d, ip2 = %0d, out = %0d", sb_item.ip1, sb_item.ip2, sb_item.out),UVM_LOW);
        end
        else begin
          `uvm_error(get_name, $sformatf("NOT matched: ip1 = %0d, ip2 = %0d, out = %0d", sb_item.ip1, sb_item.ip2, sb_item.out));
        end
        $display("----------------------------------------------------------------------------------------------------------");
      end
    end
  endtask
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  agent agt;
  scoreboard sb;
 
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt", this);
    sb = scoreboard::type_id::create("sb", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agt.mon.item_collect_port.connect(sb.item_collect_export);
  endfunction
endclass

class base_test extends uvm_test;
  env env_o;
  base_seq bseq;
  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_o = env::type_id::create("env_o", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    bseq = base_seq::type_id::create("bseq");
        
    repeat(10) begin 
      #5; bseq.start(env_o.agt.seqr);
    end
    
    phase.drop_objection(this);
    `uvm_info(get_type_name, "End of testcase", UVM_LOW);
  endtask
endclass