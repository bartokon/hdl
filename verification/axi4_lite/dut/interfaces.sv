`ifndef INTERFACES_SV
`define INTERFACES_SV

interface axi4_stream_if #(
    parameter DATA_WIDTH = 8
) (
    input logic aclk,
    input logic arstn
);

    // Data signals
    logic [DATA_WIDTH - 1 : 0] tdata;
    logic                      tvalid;
    logic                      tready;

    // Modport for AXI4-Stream Master
    modport master (
        output tdata, tvalid,
        input  tready,
        input  aclk, arstn
    );

    // Modport for AXI4-Stream Slave
    modport slave (
        input  tdata, tvalid,
        output tready,
        input  aclk, arstn
    );

endinterface

interface axi4_lite_if #(
    parameter C_AXI_ADDR_WIDTH = 8,
    parameter C_AXI_DATA_WIDTH = 32
) (
    input logic aclk,
    input logic arstn
);

    // Write Address Channel
    logic [C_AXI_ADDR_WIDTH - 1 : 0] awaddr;
    logic                            awvalid;
    logic                            awready;

    // Write Data Channel
    logic [C_AXI_DATA_WIDTH - 1 : 0]     wdata;
    logic [C_AXI_DATA_WIDTH / 8 - 1 : 0] wstrb;
    logic                                wvalid;
    logic                                wready;

    // Write Response Channel
    logic [1 : 0]                    bresp;
    logic                            bvalid;
    logic                            bready;

    // Read Address Channel
    logic [C_AXI_ADDR_WIDTH - 1 : 0] araddr;
    logic                            arvalid;
    logic                            arready;

    // Read Data Channel
    logic [C_AXI_DATA_WIDTH - 1 : 0] rdata;
    logic [1:0]                      rresp;
    logic                            rvalid;
    logic                            rready;

    // Modport for AXI4-Lite Master
    modport master (
        output awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready,
        input  awready, wready, bvalid, bresp, arready, rvalid, rdata, rresp,
        input  aclk, arstn
    );

    // Modport for AXI4-Lite Slave
    modport slave (
        input  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready,
        output awready, wready, bvalid, bresp, arready, rvalid, rdata, rresp,
        input  aclk, arstn
    );

endinterface

interface axi4_master_if #(
    parameter C_AXI_ID_WIDTH    = 1,
    parameter C_AXI_ADDR_WIDTH  = 32,
    parameter C_AXI_DATA_WIDTH  = 32,
    parameter C_AXI_BURST_LEN   = 16 // Assuming a maximum burst length for len
) (
    input  logic aclk, arstn
);

    // Write Address Channel Signals (AW)
    logic [C_AXI_ID_WIDTH - 1 : 0]   awid;
    logic [C_AXI_ADDR_WIDTH - 1 : 0] awaddr;
    logic [7:0]                      awlen;
    logic [2:0]                      awsize;
    logic [1:0]                      awburst;
    logic                            awvalid;
    logic                            awready;

    // Write Data Channel Signals (W)
    logic [C_AXI_DATA_WIDTH - 1 : 0]     wdata;
    logic [C_AXI_DATA_WIDTH / 8 - 1 : 0] wstrb;
    logic                                wlast;
    logic                                wvalid;
    logic                                wready;

    // Write Response Channel Signals (B)
    logic [C_AXI_ID_WIDTH - 1 : 0]       bid;
    logic [1:0]                          bresp;
    logic                                bvalid;
    logic                                bready;

    // Read Address Channel Signals (AR)
    logic [C_AXI_ID_WIDTH - 1 : 0]   arid;
    logic [C_AXI_ADDR_WIDTH - 1 : 0] araddr;
    logic [7:0]                      arlen;
    logic [2:0]                      arsize;
    logic [1:0]                      arburst;
    logic                            arvalid;
    logic                            arready;

    // Read Data Channel Signals (R)
    logic [C_AXI_ID_WIDTH - 1 : 0]   rid;
    logic [C_AXI_DATA_WIDTH - 1 : 0] rdata;
    logic [1:0]                      rresp;
    logic                            rlast;
    logic                            rvalid;
    logic                            rready;

    // Modport for AXI4 Master
    modport master (
        output awid, awaddr, awlen, awsize, awburst, awvalid, wdata, wstrb, wlast, wvalid, bready, arid, araddr, arlen, arsize, arburst, arvalid, rready,
        input  awready, wready, bvalid, bid, bresp, arready, rvalid, rid, rdata, rresp, rlast,
        input  aclk, arstn
    );

    // Modport for AXI4 Slave
    modport slave (
        input  awid, awaddr, awlen, awsize, awburst, awvalid, wdata, wstrb, wlast, wvalid, bready, arid, araddr, arlen, arsize, arburst, arvalid, rready,
        output awready, wready, bvalid, bid, bresp, arready, rvalid, rid, rdata, rresp, rlast,
        input  aclk, arstn
    );

endinterface


`endif