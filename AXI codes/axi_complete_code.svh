// // interface axi4lite_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (input logic ACLK, ARESETN);

// //     // Write address channel
// //     logic AWVALID, AWREADY;
// //     logic [ADDR_WIDTH-1:0] AWADDR;

// //     // Write data channel
// //     logic WVALID, WREADY;
// //     logic [DATA_WIDTH-1:0] WDATA;
// //     logic [DATA_WIDTH/8-1:0] WSTRB;

// //     // Write response channel
// //     logic BVALID, BREADY;
// //     logic [1:0] BRESP;

// //     // Read address channel
// //     logic ARVALID, ARREADY;
// //     logic [ADDR_WIDTH-1:0] ARADDR;

// //     // Read data channel
// //     logic RVALID, RREADY;
// //     logic [DATA_WIDTH-1:0] RDATA;
// //     logic [1:0] RRESP;

// // endinterface

// // module axi4lite_slave (
// //     input logic ACLK,
// //     input logic ARESETN,
// //     axi4lite_if axi
// // );
// //     parameter ADDR_WIDTH = 32;
// //     parameter DATA_WIDTH = 32;

// //     logic [DATA_WIDTH-1:0] mem [0:255];  // Simple 256 x 32-bit memory
// //     logic [ADDR_WIDTH-1:0] awaddr_reg, araddr_reg;
// //     logic write_en, read_en;

// //     // Write address handshake
// //     always_ff @(posedge ACLK) begin
// //         if (!ARESETN) begin
// //             axi.AWREADY <= 0;
// //         end else begin
// //             axi.AWREADY <= ~axi.AWREADY & axi.AWVALID;
// //             if (axi.AWVALID & ~axi.AWREADY)
// //                 awaddr_reg <= axi.AWADDR;
// //         end
// //     end

// //     // Write data handshake
// //     always_ff @(posedge ACLK) begin
// //         if (!ARESETN) begin
// //             axi.WREADY <= 0;
// //         end else begin
// //             axi.WREADY <= ~axi.WREADY & axi.WVALID;
// //         end
// //     end

// //     assign write_en = axi.AWREADY & axi.AWVALID & axi.WREADY & axi.WVALID;

// //     // Memory write
// //     always_ff @(posedge ACLK) begin
// //         if (write_en) begin
// //             for (int i = 0; i < DATA_WIDTH/8; i++) begin
// //                 if (axi.WSTRB[i]) begin
// //                     mem[awaddr_reg[9:2]][8*i +: 8] <= axi.WDATA[8*i +: 8];
// //                 end
// //             end
// //         end
// //     end

// //     // Write response
// //     always_ff @(posedge ACLK) begin
// //         if (!ARESETN) begin
// //             axi.BVALID <= 0;
// //             axi.BRESP <= 2'b00;  // OKAY
// //         end else if (write_en) begin
// //             axi.BVALID <= 1;
// //         end else if (axi.BVALID && axi.BREADY) begin
// //             axi.BVALID <= 0;
// //         end
// //     end

// //     // Read address handshake
// //     always_ff @(posedge ACLK) begin
// //         if (!ARESETN) begin
// //             axi.ARREADY <= 0;
// //         end else begin
// //             axi.ARREADY <= ~axi.ARREADY & axi.ARVALID;
// //             if (axi.ARVALID & ~axi.ARREADY)
// //                 araddr_reg <= axi.ARADDR;
// //         end
// //     end

// //     assign read_en = axi.ARREADY & axi.ARVALID;

// //     // Read data
// //     always_ff @(posedge ACLK) begin
// //         if (!ARESETN) begin
// //             axi.RVALID <= 0;
// //             axi.RRESP <= 2'b00;
// //             axi.RDATA <= 0;
// //         end else if (read_en) begin
// //             axi.RDATA <= mem[araddr_reg[9:2]];
// //             axi.RVALID <= 1;
// //             axi.RRESP <= 2'b00;
// //         end else if (axi.RVALID && axi.RREADY) begin
// //             axi.RVALID <= 0;
// //         end
// //     end
// // endmodule

// interface axi4lite_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)(input logic ACLK, ARESETN);

//     // Write Address
//     logic AWVALID, AWREADY;
//     logic [ADDR_WIDTH-1:0] AWADDR;

//     // Write Data
//     logic WVALID, WREADY;
//     logic [DATA_WIDTH-1:0] WDATA;
//     logic [DATA_WIDTH/8-1:0] WSTRB;

//     // Write Response
//     logic BVALID, BREADY;
//     logic [1:0] BRESP;

//     // Read Address
//     logic ARVALID, ARREADY;
//     logic [ADDR_WIDTH-1:0] ARADDR;

//     // Read Data
//     logic RVALID, RREADY;
//     logic [DATA_WIDTH-1:0] RDATA;
//     logic [1:0] RRESP;

//     modport MASTER (
//         output AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY,
//         output ARVALID, ARADDR, RREADY,
//         input  AWREADY, WREADY, BVALID, BRESP,
//         input  ARREADY, RVALID, RDATA, RRESP
//     );

//     modport SLAVE (
//         input  AWVALID, AWADDR, WVALID, WDATA, WSTRB, BREADY,
//         input  ARVALID, ARADDR, RREADY,
//         output AWREADY, WREADY, BVALID, BRESP,
//         output ARREADY, RVALID, RDATA, RRESP
//     );
// endinterface

// module axi4lite_slave #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)(
//     input logic ACLK,
//     input logic ARESETN,
//     axi4lite_if.SLAVE axi
// );

//     logic [DATA_WIDTH-1:0] mem [0:255];
//     logic [ADDR_WIDTH-1:0] awaddr, araddr;

//     // Write address
//     always_ff @(posedge ACLK) begin
//         if (!ARESETN) axi.AWREADY <= 0;
//         else axi.AWREADY <= !axi.AWREADY && axi.AWVALID;
//         if (axi.AWVALID && axi.AWREADY)
//             awaddr <= axi.AWADDR;
//     end

//     // Write data
//     always_ff @(posedge ACLK) begin
//         if (!ARESETN) axi.WREADY <= 0;
//         else axi.WREADY <= !axi.WREADY && axi.WVALID;
//         if (axi.WVALID && axi.WREADY)
//             mem[awaddr[9:2]] <= axi.WDATA;
//     end

//     // Write response
//     always_ff @(posedge ACLK) begin
//         if (!ARESETN) axi.BVALID <= 0;
//         else if (axi.WVALID && axi.WREADY) axi.BVALID <= 1;
//         else if (axi.BVALID && axi.BREADY) axi.BVALID <= 0;
//         axi.BRESP <= 2'b00;
//     end

//     // Read address
//     always_ff @(posedge ACLK) begin
//         if (!ARESETN) axi.ARREADY <= 0;
//         else axi.ARREADY <= !axi.ARREADY && axi.ARVALID;
//         if (axi.ARVALID && axi.ARREADY)
//             araddr <= axi.ARADDR;
//     end

//     // Read data
//     always_ff @(posedge ACLK) begin
//         if (!ARESETN) axi.RVALID <= 0;
//         else if (axi.ARVALID && axi.ARREADY) begin
//             axi.RDATA <= mem[araddr[9:2]];
//             axi.RVALID <= 1;
//             axi.RRESP <= 2'b00;
//         end else if (axi.RVALID && axi.RREADY) axi.RVALID <= 0;
//     end

// endmodule

// module axi4lite_master #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)(
//     input logic ACLK,
//     input logic ARESETN,
//     axi4lite_if.MASTER axi
// );

//     initial begin
//         axi.AWVALID = 0;
//         axi.WVALID  = 0;
//         axi.BREADY  = 0;
//         axi.ARVALID = 0;
//         axi.RREADY  = 0;
//         axi.WSTRB   = {DATA_WIDTH/8{1'b1}};
//     end

//     task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
//         begin
//             @(posedge ACLK);
//             axi.AWADDR  <= addr;
//             axi.AWVALID <= 1;
//             wait (axi.AWREADY);
//             @(posedge ACLK);
//             axi.AWVALID <= 0;

//             axi.WDATA  <= data;
//             axi.WVALID <= 1;
//             wait (axi.WREADY);
//             @(posedge ACLK);
//             axi.WVALID <= 0;

//             axi.BREADY <= 1;
//             wait (axi.BVALID);
//             @(posedge ACLK);
//             axi.BREADY <= 0;
//         end
//     endtask

//     task automatic axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
//         begin
//             @(posedge ACLK);
//             axi.ARADDR  <= addr;
//             axi.ARVALID <= 1;
//             wait (axi.ARREADY);
//             @(posedge ACLK);
//             axi.ARVALID <= 0;

//             axi.RREADY <= 1;
//             wait (axi.RVALID);
//             @(posedge ACLK);
//             data <= axi.RDATA;
//             axi.RREADY <= 0;
//         end
//     endtask

// endmodule

// module tb_axi4lite_top;
//     logic ACLK = 0;
//     logic ARESETN = 0;
//     always #5 ACLK = ~ACLK;

//     axi4lite_if axi(.*);
//     axi4lite_master master(.*);
//     axi4lite_slave  slave(.*);

//     initial begin
//         ARESETN = 0;
//         repeat (3) @(posedge ACLK);
//         ARESETN = 1;
//         repeat (3) @(posedge ACLK);

//         logic [31:0] rdata;

//         $display("---- AXI Write Transaction ----");
//         master.axi_write(32'h10, 32'hCAFEBABE);

//         $display("---- AXI Read Transaction ----");
//         master.axi_read(32'h10, rdata);
//         $display("Read Data = %h", rdata);

//         #20 $finish;
//     end
// endmodule
