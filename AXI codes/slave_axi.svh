module slave_axi #( parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32) (
    input logic aclk, areset_n,
    axi_intf.SLAVE axi
);

logic [DATA_WIDTH-1:0] mem[ADDR_WIDTH-1:0];
logic [ADDR_WIDTH-1:0] awaddr;
logic [ADDR_WIDTH-1:0] araddr;

//Write Address and data and response channel
always_ff @(posedge aclk) begin : reset_logic
    if(!areset_n) begin
        axi.AWREADY <= 1'b0;
        axi.WREADY <= 1'b0;
        axi.ARREADY <= 1'b0;
        //axi.BVALID <= 1'b0;
    end
    else begin
        axi.AWREADY <= 1'b1;
        axi.WREADY <= 1'b1;
        axi.ARREADY <= 1'b1;
        //axi.BVALID <= 1'b1;
    end
end

always_ff @(posedge aclk) begin : write_address
    if(axi.AWVALID) awaddr <= axi.AWADDR;

end

always_ff @(posedge aclk) begin : write_data
    if(!areset_n) begin
        //mem <= '0;
        axi.BVALID <= 1'b0;
    end
    else if(axi.AWVALID && axi.WVALID && axi.AWREADY && axi.WREADY) begin
        mem[awaddr[DATA_WIDTH-1:0]] <= axi.WDATA;
        axi.BVALID <= 1'b1;
    end else if (axi.BREADY) begin
        axi.BREADY <= 1'b0;
    end
end

always_ff @(posedge aclk) begin : write_response
    if(axi.BREADY) axi.BRESP <= 2'b00;
end

always_ff @(posedge aclk) begin : read_address
    if(axi.ARVALID) begin
        araddr <= axi.ARADDR;
        //axi.RVALID <= 1'b1;
    end
end

always_ff @(posedge aclk) begin : read_data_and_response
    if(!areset_n) axi.RVALID <= 1'b0;
    else if(axi.ARVALID && axi.ARREADY) begin
        axi.RDATA <= mem[araddr[DATA_WIDTH-1:0]];
        axi.RVALID <= 1'b1;
        axi.RRESP <= 2'b00;
    end else if (axi.RVALID && axi.RREADY) begin
        axi.RVALID <= 1'b0;
    end
end

// //write address
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.AWREADY <= 1'b0;
//     else axi.AWREADY <= 1'b1; //axi.AWREADY <= !axi.AWREADY && axi.AWVALID;
//     if(axi.AWVALID && axi.AWREADY)
//         awaddr <= axi.AWADDR;
// end

// //write data
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.WREADY <= 1'b0;
//     else axi.WREADY <= 1'b1; //axi.WREADY <= !axi.WREADY;
//     if(axi.AWVALID && axi.AWREADY) begin
//         if(axi.WVALID && axi.WREADY) begin
//             mem[awaddr[DATA_WIDTH-1:0]] <= axi.WDATA;
//         end
//     end
// end

// //write response
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.BVALID <= 1'b0;
//     else if(axi.WVALID && axi.WREADY) axi.BVALID <= 1'b1;
//     else if(axi.BVALID && axi.BREADY) begin
//         axi.BRESP <= 2'b00;
//         axi.BVALID <= 1'b0;
//     end
// end

// //read address
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.ARREADY <= 1'b0;
//     else axi.ARREADY <= 1'b1; //axi.ARREADY <= !axi.ARREADY;
//     if(axi.ARVALID && axi.ARREADY) araddr <= axi.ARADDR;

// end

// //read data
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.RVALID <= 1'b0;
//     if(axi.RVALID && axi.RREADY) axi.RVALID <= 1'b0;
//     else if(axi.ARVALID && axi.ARREADY) begin
//         axi.RVALID <= 1'b1;
//         axi.RDATA <= mem[araddr[DATA_WIDTH-1:0]];
//     end
//     // else if(axi.ARVALID && axi.ARREADY) begin
//     //     axi.RVALID <= 1'b1;
//     //     axi.RDATA <= mem[araddr[DATA_WIDTH-1:0]];
//     //     if (axi.RVALID && axi.RREADY) begin
//     //         axi.RRESP <= 2'b00;
//     //         axi.RVALID <= 1'b0;
//     //     end
//     // end
// end

always_ff @(posedge aclk) begin
  if (axi.AWVALID && axi.WVALID && axi.AWREADY && axi.WREADY) begin
    $display("WRITE to 0x%0h: 0x%0h", axi.AWADDR, axi.WDATA);
  end
  if (axi.ARVALID && axi.ARREADY) begin
    $display("READ from 0x%0h -> returns 0x%0h", axi.ARADDR, axi.RDATA);
  end
end

endmodule
