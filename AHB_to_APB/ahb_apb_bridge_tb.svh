`timescale 1ns/100ps

module ahb_apb_bridge_tb();
     logic hclk = 1'b1, hresetn;
     logic [2:0] hsize;
     logic [31:0] haddr, hwdata;
     logic [2:0] htrans;
     logic hwrite, Hreadyin;

    //from APB/ to bridge
     logic [31:0] prdata;

    // to AHB/from bridge
    logic [31:0] hrdata;
    logic Hreadyout;
    logic [1:0] hresp;

    // to APB/from bridge
    logic [2:0] psel;
    logic penable, pwrite;
    logic [31:0] paddr, pwdata;

    logic hsel;
    initial begin : generate_clock
        forever #5 hclk = ~hclk;
    end

    ahb_apb_bridge inst1(hclk, hresetn, hsel, haddr, hwdata, htrans, hwrite, Hreadyin, prdata, hrdata, Hreadyout, hresp, psel,
                        penable, pwrite, paddr, pwdata );


    initial begin : generate_stimulus
        @(posedge hclk);
        hresetn <= 1'b0;
        hsize <= '0;
        haddr <= '0;
        hwdata <= '0;
        htrans <= '0;
        hwrite <= 1'b0;
        Hreadyin <= 1'b0;
        prdata <= '0;
        repeat(3) @(posedge hclk);
        @(negedge hclk);
        hresetn <= 1'b1;
        @(posedge hclk);

        //write data from AHB to APB
        hwrite <= 1'b0;
        hsel <= 1'b1;
        htrans <= 2'b10;
        haddr <= 32;
        #10;
        hwrite <= 1'bx;
        hsel <= 1'b0;
        htrans <= 2'bxx;
        haddr <= 32'hxxxx_xxxx;
        #5;
        prdata <= 40;

        #50;

        //Read Data from APB to AHB
        hwrite <= 1'b0;
        hsel <= 1'b1;
        htrans <= 2'b10;
        haddr <= 32;
        #10;
        hwrite <= 1'bx;
        hsel <= 1'b0;
        htrans <= 2'bxx;
        haddr <= 32'hxxxx_xxxx;
        #5;
        prdata <= 40;

        #50;
        $display("Tests completed");
        disable generate_clock;
    end 

endmodule
