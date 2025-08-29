module apb_top(
    input logic pclk, presetn,
    input logic transfer, pwrite,
    input logic [31:0] wdata, addr,

    // //input to APB/output from bridge
    // output logic [2:0] psel,
    // output logic penable, pwrite,
    // output logic [31:0] paddr, pwdata

    // // output from APB/input to bridge
    //logic [31:0] prdata
    output logic pready,
    output logic [31:0] data_out

);

logic penable, pslverr, psel;
logic [31:0] paddr,pwdata, rdata, prdata;
//logic pready;

apb_master apb_m (.pclk(pclk), .presetn(presetn), .wdata(wdata), .prdata(prdata), .pwrite(pwrite), .addr(addr),
                    .transfer(transfer), .pready(pready), .psel(psel), .penable(penable), .paddr(paddr), .pwdata(pwdata), .rdata(rdata),
                    .pslverr(pslverr)
                    );

apb_slave apb_s1 (.pclk(pclk), .presetn(presetn), .pwrite(pwrite), .psel(psel), .penable(penable), .addr(paddr),
                .pwdata(pwdata), .prdata(prdata), .pready(pready), .transfer(transfer)
                );
assign data_out = rdata;
endmodule
