module ahb_top(
    input logic hclk, hresetn, hwrite,hreadyout,
    input logic [31:0] addr, data,
    input logic [2:0] hburst, hsize,
    
    output logic [31:0] read_data

);

logic hready;
logic [1:0] hresp;
logic [1:0] hsel=2'b00,htrans=2'b00;
//logic [2:0] hburst;
logic [31:0] haddr;
logic [31:0] hrdata, hwdata;


ahb_master m(.hclk(hclk), .hresetn(hresetn), .hwrite(hwrite), .addr(addr), .data_in(data), .hburst(hburst), .hsize(hsize), .hready(hready),
            .hreadyout(hreadyout), .hresp(hresp), .hsel(hsel), .haddr(haddr), .hrdata(hrdata), .hwdata(hwdata), .data_out(read_data)
);

ahb_slave s( .hclk(hclk), .hresetn(hresetn), .hwrite(hwrite), .haddr(haddr), .hwdata(hwdata), .hsize(hsize), .htrans(htrans), 
            .hreadyin(hready), .hrdata(hrdata), .hreadyout(hreadyout), .hresp(hresp)

);

endmodule
