interface AXI_interface #( 
    parameter ADDR_WIDTH = 32, // Address bus width
    parameter DATA_WIDTH = 32, // Data bus width
    parameter ID_WIDTH = 4     // ID bus width
);

    //Global signals
    logic ACLK;
    logic ARESETn;
    
    //WRITE REQUEST CHANNEL
    logic                          AWVALID; // Master address valid signal
    logic                          AWREADY; // Slave ready signal
    logic [ID_WIDTH - 1:0]         AWID;    // Transaction identifier
    logic [ADDR_WIDTH - 1:0]       AWADDR;  // Address write bus
    logic [7:0]                    AWLEN;   // Number of transactions - 1
    logic [2:0]                    AWSIZE;  // Size of each transaction in bytes
    logic [1:0]                    AWBURST; // Burst type (FIXED, INCR, WRAP)
    // logic                       AWLOCK;     // Exclusive access indicator
    // logic [3:0]                 AWQOS;      // Quality of Service
    
    //WRITE DATA CHANNEL
    logic                          WVALID; // Master write valid signal
    logic                          WREADY; // Slave ready signal
    logic [DATA_WIDTH - 1:0]       WDATA;  // Data write bus
    logic [(DATA_WIDTH / 8) - 1:0] WSTRB;  // Write strobe signal (Bytes valid)
    logic                          WLAST;  // Last transaction
    
    //WRITE RESPONSE CHANNEL
    logic                          BVALID; // Master response valid signal
    logic                          BREADY; // Slave ready signal
    logic [ID_WIDTH - 1:0]         BID;    // Transaction identifier
    logic [1:0]                    BRESP;  // Write response channel
    
    //READ REQUEST CHANNEL
    logic                          ARVALID; // Master address valid signal
    logic                          ARREADY; // Slave ready signal
    logic [ID_WIDTH - 1:0]         ARID;    // Transaction identifier
    logic [ADDR_WIDTH - 1:0]       ARADDR;  // Address read bus
    logic [7:0]                    ARLEN;   // Number of transactions - 1
    logic [2:0]                    ARSIZE;  // Size of each transaction in bytes
    logic [1:0]                    ARBURST; // Burst type (FIXED, INCR, WRAP)
    // logic                       ARLOCK;     // Exclusive access indicator
    // logic [3:0]                 ARQOS;      // Quality of Service
    
    //READ DATA CHANNEL
    logic                          RVALID; // Master read valid signal
    logic                          RREADY; // Slave ready signal
    logic [ID_WIDTH - 1:0]         RID;    // Transaction identifier
    logic [DATA_WIDTH - 1:0]       RDATA;  // Data read bus
    logic [1:0]                    RRESP;  // Read response channel
    logic                          RLAST;  // Last transaction
    
    //-------------------------------------------------------------------------------------------//
    
    modport master (
        input  ACLK,
        input  ARESETn,
        
        input  AWREADY,
        output AWVALID,
        output AWID,
        output AWADDR,
        output AWLEN,
        output AWSIZE,
        output AWBURST,
        
        input  WREADY,
        output WVALID,
        output WDATA,
        output WSTRB,
        output WLAST,
        
        input  BVALID,
        input  BID,
        input  BRESP,
        output BREADY,
        
        input  ARREADY,
        output ARVALID,
        output ARID,
        output ARADDR,
        output ARLEN,
        output ARSIZE,
        output ARBURST,
        
        input  RVALID,
        input  RID,
        input  RDATA,
        input  RRESP,
        input  RLAST,
        output RREADY
    );
    
    modport slave (
        input  ACLK,
        input  ARESETn,
        
        input  AWVALID,
        input  AWID,
        input  AWADDR,
        input  AWLEN,
        input  AWSIZE,
        input  AWBURST,
        output AWREADY,
        
        input  WVALID,
        input  WDATA,
        input  WSTRB,
        input  WLAST,
        output WREADY,
        
        input  BREADY,
        output BVALID,
        output BID,
        output BRESP,
        
        input  ARVALID,
        input  ARID,
        input  ARADDR,
        input  ARLEN,
        input  ARSIZE,
        input  ARBURST,
        output ARREADY,
        
        input  RREADY,
        output RVALID,
        output RID,
        output RDATA,
        output RRESP,
        output RLAST
    );

endinterface
