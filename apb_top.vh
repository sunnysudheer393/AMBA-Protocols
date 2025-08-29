module apb_top(
    input pclk,presetn,transfer,read,write,
    input [8:0] apb_write_paddr,
    input [8:0] apb_read_paddr,
    input [7:0] apb_write_data,
    output pslverr,
    output [7:0] apb_read_data_out

    );

    logic [7:0] pwdata, prdata, prdata1, prdata2;
    logic [8:0] paddr;
    logic pready, pready1, pready2, penable, psel1, psel2, pwrite;
    
    //Instantiate apb_master
    //use .* or naming of the ports in it
    apb_master dut(.*);
    apb_slave slave1(.*);
    apb_slave slave2(.*);

endmodule 