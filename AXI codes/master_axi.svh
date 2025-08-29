module master_axi #( parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32)(
    input logic aclk, areset_n,
    input logic [ADDR_WIDTH-1:0] awaddr,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [ADDR_WIDTH-1:0] araddr,
    output logic [DATA_WIDTH-1:0] data_out,
    axi_intf.MASTER axi
);

// logic write_active;

always_ff @(posedge aclk) begin : write_address
    if(!areset_n) axi.AWVALID <= 1'b0;
    else if(awaddr > 32'h0) begin
        axi.AWVALID <= 1'b1;
        axi.AWADDR <= awaddr;
    end
end

always_ff @(posedge aclk) begin : write_data_valid
    if(!areset_n) axi.WVALID <= 1'b0;
    else if (axi.AWVALID && axi.AWREADY) begin
        axi.WVALID <= 1'b1;
    end
end

always_ff @(posedge  aclk) begin : write_data_response
    if(axi.WVALID) begin
        axi.WDATA <= data_in;
        axi.BREADY <= 1'b1;
    end
end

always_ff @(posedge aclk) begin : read_address
    if(!areset_n) axi.ARVALID <= 1'b0;
    else if(!axi.ARVALID && araddr > 32'h0) begin
        axi.ARVALID <= 1'b1;
        axi.ARADDR <= araddr;
    end else if (axi.ARVALID && axi.ARREADY) begin
        axi.ARVALID <= 1'b0;
    end
end

always_ff @(posedge aclk) begin : read_data_and_response
    if(!areset_n) axi.RREADY <= 1'b0;
    else if(axi.ARVALID) begin
        data_out <= axi.RDATA;
        axi.RREADY <= 1'b1;
    end
end
endmodule

// always_ff @(posedge aclk) begin
//     if(!areset_n) begin
//         axi.AWVALID <= 1'b0;
//         axi.WVALID <= 1'b0;
//         axi.BREADY <= 1'b0;
//         axi.WSTRB <= 4'b1111;
//         write_active <= 1'b0;
//     end
//     if(awaddr > 32'b0) begin
//         axi.AWVALID <= 1'b1;
//         axi.AWADDR <= awaddr;
//         if(axi.AWREADY) begin
//             axi.AWVALID <= 1'b0;
//         end
//     end
//     if(axi.AWVALID && axi.AWREADY) begin
//         write_active <= 1'b1;
//     end
//     if(write_active) begin
//         axi.WVALID <= 1'b1;
//         axi.WDATA <= data_in;
//         if(axi.WREADY) begin
//             axi.WVALID <= 1'b0;
//             write_active <= 1'b0;
//         end
//     end

//     //Write Response Logic
//     axi.BREADY <= 1'b1;
//     if(axi.BVALID) begin
//         axi.BRESP <= 2'b00;
//         axi.BREADY <= 1'b0;
//     end
// end

// //Read Address logic
// always_ff @(posedge aclk) begin
//     if(araddr > 32'h0) begin
//         axi.ARVALID <= 1'b1;
//         axi.ARADDR <= araddr;
//         if(axi.ARREADY)
//             //@(posedge aclk);
//             axi.ARVALID <= 1'b0;
//     end
//     //Read Data logic
//     //axi.RREADY <= 1'b1;
//     if(axi.ARVALID && axi.ARREADY) begin
//         axi.RREADY <= 1'b1;
//     end
//     if(axi.RVALID) begin
//         data_out <= axi.RDATA;
//         axi.RREADY <= 1'b0;
//     end
// end

// endmodule


// //Write address logic
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.AWVALID <= 1'b0;
//     else if(awaddr > 32'b0) begin
//         axi.AWVALID <= 1'b1;
//         axi.AWADDR <= awaddr;
//         if(axi.AWREADY) begin
//             axi.AWVALID <= 1'b0;
//         end
//     end
// end

// //Write Data logic
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.WVALID <= 1'b0;
//     else if(axi.AWVALID && axi.AWREADY) begin
//         axi.WVALID <= 1'b1;
//         axi.WDATA <= data_in;
//         if(axi.WVALID && axi.WREADY) axi.WVALID <= 1'b0;
//     end
// end

// //Write Response
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.BREADY <= 1'b0;
//     else begin
//         axi.BREADY <= 1'b1;
//         if(axi.BVALID) begin
//             axi.BREADY <= 1'b0;
//         end
//     end
// end

// //Read Address logic
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.ARVALID <= 1'b0;
//     else if(araddr > 32'h0) begin
//         axi.ARVALID <= 1'b1;
//         axi.ARADDR <= araddr;
//         if(axi.ARREADY)
//             //@(posedge aclk);
//             axi.ARVALID <= 1'b0;
//     end
// end

// //Read Data Logic
// always_ff @(posedge aclk) begin
//     if(!areset_n) axi.RREADY <= 1'b0;
//     else begin
//         if(axi.ARVALID && axi.ARREADY) begin
//             axi.RREADY <= 1'b1;
//             if(axi.RVALID && axi.RREADY) begin
//                 data_out <= axi.RDATA;
//                 axi.RREADY <= 1'b0;
//             end
//         end
//     end
// end

// endmodule
