module axi_test #(parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32)(
  input logic clk,rst_n,
  input  logic                  start_write,
  input  logic                  start_read,
  input  logic [ADDR_WIDTH-1:0] addr_in,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic                  done_write,
  output logic                  done_read
);

// Write Address Channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic                  awvalid;
  logic                  awready;

  // Write Data Channel
  logic [DATA_WIDTH-1:0] wdata;
  logic                  wvalid;
  logic                  wready;

  // Write Response Channel
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // Read Address Channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic                  arvalid;
  logic                  arready;

  // Read Data Channel
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rvalid;
  logic                  rready;

  //Instantiate Master and slave dut
axi_lite_master m_uut (.clk(clk), .rst_n(rst_n), .start_write(start_write), .start_read(start_read),
                .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .done_write(done_write), .done_read(done_read),

                //Write address channel
                .awaddr(awaddr),
                .awvalid(awvalid),
                .awready(awready),

                //Write data channel
                .wdata(wdata),
                .wvalid(wvalid),
                .wready(wready),

                //Write Response channel
                .bresp(bresp),
                .bvalid(bvalid),
                .bready(bready),

                //Read address channel
                .araddr(araddr),
                .arvalid(arvalid),
                .arready(arready),

                //Read data channel
                .rdata(rdata),
                .rresp(rresp),
                .rvalid(rvalid),
                .rready(rready)

                );


axi_lite_slave s_uut (.clk(clk), .rst_n(rst_n),
                //Write address channel
                .awaddr(awaddr),
                .awvalid(awvalid),
                .awready(awready),

                //Write data channel
                .wdata(wdata),
                .wvalid(wvalid),
                .wready(wready),

                //Write Response channel
                .bresp(bresp),
                .bvalid(bvalid),
                .bready(bready),

                //Read address channel
                .araddr(araddr),
                .arvalid(arvalid),
                .arready(arready),

                //Read data channel
                .rdata(rdata),
                .rresp(rresp),
                .rvalid(rvalid),
                .rready(rready)

);


endmodule
