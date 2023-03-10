`timescale 1ns / 1ns

import axi4stream_vip_pkg::*;
import design_1_axi4stream_vip_0_0_pkg::*;
import design_1_axi4stream_vip_0_1_pkg::*;

module tb_skid_buffer;

localparam int unsigned DATA_SIZE = 8;
localparam int unsigned CLOCK_PERIOD = 5;
localparam int unsigned NB_OF_ITERATIONS = 2**12;

// Input ports
logic [DATA_SIZE-1:0] data_i;
logic data_valid_i;
logic data_ready_o;
// Output ports
logic [DATA_SIZE-1:0] data_o;
logic data_valid_o;
logic data_ready_i;
// Misc
logic clk_i = 0;
logic rst_clk_ni = 0;

logic [DATA_SIZE-1:0] q_output[$];
logic [DATA_SIZE-1:0] q_input[$];

design_1 u0_axi4_stream_wips (
    .clk_i,
    .rst_clk_ni,
    .M_AXIS_0_tvalid(data_valid_i),
    .M_AXIS_0_tready(data_ready_o),
    .M_AXIS_0_tdata(data_i),
    .S_AXIS_0_tvalid(data_valid_o),
    .S_AXIS_0_tready(data_ready_i),
    .S_AXIS_0_tdata(data_o)
);

skid_buffer_wrapper #(
    .DATA_SIZE(DATA_SIZE)
) u0_skid_buffer (
    // Input ports
    .data_i,
    .data_valid_i,
    .data_ready_o,
    // Output ports
    .data_o,
    .data_valid_o,
    .data_ready_i,
    // Misc
    .clk_i,
    .rst_clk_ni
);

task mst_gen_transaction();
    axi4stream_transaction wr_transaction;
    wr_transaction = mst_agent.driver.create_transaction("Master VIP write transaction");
    wr_transaction.set_xfer_alignment(XIL_AXI4STREAM_XFER_RANDOM);
    WR_TRANSACTION_FAIL: assert(wr_transaction.randomize());
    mst_agent.driver.send(wr_transaction);
endtask

task slv_gen_tready();
    axi4stream_ready_gen ready_gen;
    ready_gen = slv_agent.driver.create_ready("ready_gen");
    ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_RANDOM);
    slv_agent.driver.send_tready(ready_gen);
endtask :slv_gen_tready

task save_output;
    input logic [DATA_SIZE-1:0] data_o;
    input logic data_valid_o;
    input logic data_ready_i;
    begin
        if (data_valid_o && data_ready_i) begin
            q_output.push_front(data_o);
        end
    end
endtask

task save_input;
    input logic [DATA_SIZE-1:0] data_i;
    input logic data_valid_i;
    input logic data_ready_o;
    begin
        if (data_valid_i && data_ready_o) begin
            q_input.push_front(data_i);
        end
    end
endtask

task compare_result;
    begin
        if (q_input.size() != 0 && q_output.size() != 0) begin
            automatic logic [DATA_SIZE-1:0] in_data = q_input.pop_back();
            automatic logic [DATA_SIZE-1:0] out_data = q_output.pop_back();
            if (in_data == out_data) begin
                //$display("0x%h vs 0x%h \n", in_data, out_data);
            end else begin
                $error("Data is not the same! \n");
                $display("M: 0x%h vs S: 0x%h \n", in_data, out_data);
                #10 $stop();
            end
        end
    end
endtask

always clk_i = #(CLOCK_PERIOD/2) ~clk_i;

always @(posedge clk_i) begin
    save_input(data_i, data_valid_i, data_ready_o);
end

always @(posedge clk_i) begin
    save_output(data_o, data_valid_o, data_ready_i);
end

always @(posedge clk_i) begin
    compare_result();
end

initial begin
    #100 rst_clk_ni = 1;
end

    xil_axi4stream_uint            mst_agent_verbosity = 0;
    xil_axi4stream_uint            slv_agent_verbosity = 0;
    design_1_axi4stream_vip_0_0_mst_t mst_agent;
    design_1_axi4stream_vip_0_1_slv_t slv_agent;

initial begin
    mst_agent = new("master vip agent", u0_axi4_stream_wips.axi4stream_vip_master_0.inst.IF);
    slv_agent = new("slave vip agent",  u0_axi4_stream_wips.axi4stream_vip_slave_0.inst.IF);

    mst_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
    slv_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
    mst_agent.set_verbosity(mst_agent_verbosity);
    slv_agent.set_verbosity(slv_agent_verbosity);
    mst_agent.set_agent_tag("Master VIP");
    slv_agent.set_agent_tag("Slave VIP");

    mst_agent.start_master();
    slv_agent.start_slave();

    mst_gen_transaction();
    slv_gen_tready();

    for(int i = 0; i < NB_OF_ITERATIONS; ++i) begin
        mst_gen_transaction();
    end

    #100
    $finish("Simulation finished. \n");
end

endmodule