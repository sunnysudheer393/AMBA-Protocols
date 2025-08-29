module ahb_top(
    input hclk,
    input hresetn,
    input enable,
    input [31:0] data_in_a,
    input [31:0] data_in_b,
    input [31:0] addr,
    input wr,
    input [1:0] slave_sel,

    output [31:0] data_out

);
    logic [1:0] sel;
    logic [31:0] haddr;
    logic hwrite;
    logic [3:0] hprot;
    logic [2:0] hsize;
    logic [2:0] hburst;
    logic [1:0] htrans;
    logic hmastlock;

    logic hready;
    logic [31:0] hwdata;

    ahb_master(.hclk(hclk), .hresetn(hresetn), .enable(enable), .data_in_a(data_in_a), .data_in_b(data_in_b), .addr(addr), .write(write), .hreadyout(hreadyout), .hresp(hresp), .hrdata(hrdata), .slave_sel(slave_sel), .sel(sel), .haddr(haddr), .hsize(hsize),
    .hwrite(hwrite), .htrans(htrans), .hmastlock(hmastlock), .hready(hready), 
    );
       


endmodule