import cpu_pkg::*;

module InstructionCache_wrapper (
    input logic                           clk,
    input logic                           rst,

    input  logic                          cpu_addr_req,
    input  logic [ADDR_WIDTH - 1:0]       address,
    output logic [INSTR_WIDTH - 1:0]      instruction,
    output logic                          stall,

    // Global signals
    input  logic                          ACLK,
    input  logic                          ARESETn,

    // WRITE ADDRESS CHANNEL
    output logic                          axi_awvalid,
    input  logic                          axi_awready,
    output logic [ID_WIDTH - 1:0]         axi_awid,
    output logic [ADDR_WIDTH - 1:0]       axi_awaddr,
    output logic [7:0]                    axi_awlen,
    output logic [2:0]                    axi_awsize,
    output logic [1:0]                    axi_awburst,
    output logic                          axi_awlock,
    output logic [3:0]                    axi_awqos,

    // WRITE DATA CHANNEL
    output logic                          axi_wvalid,
    input  logic                          axi_wready,
    output logic [DATA_WIDTH - 1:0]       axi_wdata,
    output logic [(DATA_WIDTH / 8) - 1:0] axi_wstrb,
    output logic                          axi_wlast,

    // WRITE RESPONSE CHANNEL
    input  logic                          axi_bvalid,
    input  logic [ID_WIDTH - 1:0]         axi_bid,
    input  logic [1:0]                    axi_bresp,
    output logic                          axi_bready,

    // READ ADDRESS CHANNEL
    output logic                          axi_arvalid,
    input  logic                          axi_arready,
    output logic [ID_WIDTH - 1:0]         axi_arid,
    output logic [ADDR_WIDTH - 1:0]       axi_araddr,
    output logic [7:0]                    axi_arlen,
    output logic [2:0]                    axi_arsize,
    output logic [1:0]                    axi_arburst,
    output logic                          axi_arlock,
    output logic [3:0]                    axi_arqos,

    // READ DATA CHANNEL
    input  logic                          axi_rvalid,
    output logic                          axi_rready,
    input  logic [ID_WIDTH - 1:0]         axi_rid,
    input  logic [DATA_WIDTH - 1:0]       axi_rdata,
    input  logic [1:0]                    axi_rresp,
    input  logic                          axi_rlast
);

    AXI_if axi();

    // Global Signals
    assign axi.ACLK    = clk;
    assign axi.ARESETn = ~rst;

    // WRITE ADDRESS CHANNEL
    assign axi_awvalid = axi.AWVALID;
    assign axi.AWREADY = axi_awready;
    assign axi_awaddr  = axi.AWADDR;
    assign axi_awlen   = axi.AWLEN;
    assign axi_awsize  = axi.AWSIZE;
    assign axi_awburst = axi.AWBURST;

    // WRITE DATA CHANNEL
    assign axi_wvalid  = axi.WVALID;
    assign axi.WREADY  = axi_wready;
    assign axi_wdata   = axi.WDATA;
    assign axi_wstrb   = axi.WSTRB;
    assign axi_wlast   = axi.WLAST;

    // WRITE RESPONSE CHANNEL
    assign axi.BVALID  = axi_bvalid;
    assign axi.BRESP   = axi_bresp;
    assign axi_bready  = axi.BREADY;

    // READ ADDRESS CHANNEL
    assign axi_arvalid = axi.ARVALID;
    assign axi.ARREADY = axi_arready;
    assign axi_araddr  = axi.ARADDR;
    assign axi_arlen   = axi.ARLEN;
    assign axi_arsize  = axi.ARSIZE;
    assign axi_arburst = axi.ARBURST;

    // READ DATA CHANNEL
    assign axi.RVALID  = axi_rvalid;
    assign axi.RDATA   = axi_rdata;
    assign axi.RRESP   = axi_rresp;
    assign axi.RLAST   = axi_rlast;
    assign axi_rready  = axi.RREADY;

    InstructionCache icache_inst (
        .clk          (clk),
        .rst          (rst),

        .cpu_addr_req (cpu_addr_req),
        .address      (address),
        .instruction  (instruction),
        .stall        (stall),

        .axi          (axi)
    );

endmodule
