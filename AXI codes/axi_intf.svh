interface axi_intf #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32) (
    input logic aclk, areset_n
);

//Write Address channel
logic AWREADY;
logic AWVALID;
logic [ADDR_WIDTH-1:0] AWADDR;

//Write Data Channel
logic WREADY;
logic WVALID;
logic [DATA_WIDTH-1:0] WDATA;
logic [(DATA_WIDTH/8)-1:0] WSTRB; 

//Write Response Channel
logic BREADY;
logic BVALID;
logic BRESP;

//Read Address Channel
logic ARREADY;
logic ARVALID;
logic [ADDR_WIDTH-1:0] ARADDR;

//Read Data Channel
logic RREADY;
logic RVALID;
logic [DATA_WIDTH-1:0] RDATA;
logic [1:0] RRESP;

//defines direction for the signals in interface
modport MASTER (
    output AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY,
    output RREADY, ARVALID, ARADDR,
    input AWREADY, WREADY, BVALID, BRESP,
    input ARREADY, RVALID, RDATA, RRESP
);

modport SLAVE (
    input AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY,
    input RREADY, ARVALID, ARADDR,
    output AWREADY, WREADY, BVALID, BRESP,
    output ARREADY, RVALID, RDATA, RRESP
);




endinterface