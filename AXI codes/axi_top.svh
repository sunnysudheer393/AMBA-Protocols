module axi_top #(parameter Width=32) (
    input ACLK,ARESETN,
    input [Width-1:0] awaddr,wdata,araddr,
    input [(Width/8)-1:0] wstrb,
    output [7:0] data_out
);
//Write address channel
logic AWREADY;
logic AWVALID;
logic [Width-1:0] AWADDR;

//Write data channel
logic WVALID;
logic WREADY;
logic [Width-1:0] WDATA;
logic [(Width/8)-1:0] WSTRB;

//Write response channel
logic BVALID;
logic BREADY;
logic [1:0] BRESP;

//Read address channel
logic ARVALID;
logic ARREADY;
logic [Width-1:0] ARADDR;

//Read data channel
logic RVALID;
logic RREADY;
logic [Width-1:0] RDATA;
logic [1:0] RRESP;

//Instantiate the master module and connect the ports
axi_master m_dut(
                .awaddr(awaddr),
                .araddr(araddr),
                .wstrb(wstrb),
                .wdata(wdata),
                .data_out(data_out),
                .ACLK(ACLK),
                .ARESETN(ARESETN),

                //Write address channel
                .AWREADY(AWREADY),
                .AWADDR(ARADDR),
                .AWVALID(AWVALID),

                //Write data channel
                .WREADY(WREADY),
                .WVALID(WVALID),
                .WDATA(WDATA),
                .WSTRB(WSTRB),

                //Write response channel
                .BREADY(BREADY),
                .BVALID(BVALID),
                //.BRESP(BRESP),

                //Read address channel
                .ARREADY(ARREADY),
                .ARVALID(ARVALID),
                .ARADDR(ARADDR),

                //Read data channel
                .RVALID(RVALID),
                .RREADY(RREADY),
                .RDATA(RDATA)
               // .RRESP(RRESP)
);

//Instantiate the Slave DUT and connect to signals here
axi_slave s_dut(
                .ACLK(ACLK),
                .ARESETN(ARESETN),

                //Write address channel
                .AWREADY(AWREADY),
                .AWADDR(ARADDR),
                .AWVALID(AWVALID),

                //Write data channel
                .WREADY(WREADY),
                .WVALID(WVALID),
                .WDATA(WDATA),
                .WSTRB(WSTRB),

                //Write response channel
                .BREADY(BREADY),
                .BVALID(BVALID),
                //.BRESP(BRESP),

                //Read address channel
                .ARREADY(ARREADY),
                .ARVALID(ARVALID),
                .ARADDR(ARADDR),

                //Read data channel
                .RVALID(RVALID),
                .RREADY(RREADY),
                .RDATA(RDATA)
                //.RRESP(RRESP)

);

assign data_out = RDATA;
//assign WSTRB = WSTRB;

endmodule