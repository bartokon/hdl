//`ifndef UVM_CONFIG_SVH
//`define UVM_CONFIG_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`define DATA_SIZE 8
`define DEPTH 2

`include "interface.sv"
`include "uvm_sequence_item.sv"
`include "uvm_agent.sv"
`include "uvm_driver.sv"
`include "uvm_sequence.sv"
`include "uvm_environment.sv"
`include "uvm_monitor.sv"
`include "uvm_scoreboard.sv"

//`endif