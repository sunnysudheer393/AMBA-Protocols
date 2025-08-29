module ahb_apb_brdige_top(
    input logic hclk,
);

ahb_top(
    input logic hclk, hresetn, hwrite,hreadyout,
    input logic [31:0] addr, data,
    input logic [2:0] hburst, hsize,
    
    output logic [31:0] read_data

);

ahb_apb_bridge(
    //output to AHB/input to bridge
    input logic hclk, hresetn,
    input logic [2:0] hsize,
    input logic [31:0] haddr, hwdata,
    input logic [2:0] htrans,
    input logic hwrite, Hreadyin,

    //output from APB/input to bridge
    input logic [31:0] prdata,

    //Input to AHB/output from bridge
    output logic [31:0] hrdata,
    output logic Hreadyout,
    output logic [1:0] hresp,

    //input to APB/output from bridge
    output logic [2:0] psel,
    output logic penable, pwrite,
    output logic [31:0] paddr, pwdata
);

apb_top(
    input logic pclk, presetn,
    input logic transfer, pwrite, psel,
    input logic [31:0] wdata, addr,

    output logic [31:0] data_out

);

//since its is writing from high freq clock domain to low freq clock domin, it needs asynchronous FIFO to make smooth transition


endmodule
