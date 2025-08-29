module apb_tob_tb #(parameter int NUM_TESTS = 20)();
logic pclk = 1'b1, presetn;
logic transfer,pwrite,pready, psel;
logic [31:0] wdata, addr, prdata,rdata;

//Instantiate the top module

apb_top apb(.pclk(pclk), .presetn(presetn), .transfer(transfer), .pwrite(pwrite),
            .wdata(wdata), .addr(addr), .data_out(prdata), .pready(pready)
            );

// covergroup apb_coverage @(posedge pclk);
//     pt: coverpoint transfer;
//     pw: coverpoint pwrite;
//     ps: coverpoint psel;
//     wd: coverpoint wdata;
//     address: coverpoint addr;

// endgroup


initial begin : generate_clock
    forever #5 pclk <= ~pclk;
end

//assign rdata = prdata;

//apb_coverage cg; 
initial begin
    presetn <= 1'b0;
    wdata <= '0;
    transfer <= 1'b0;
    addr <= '0;
    //psel <= 1'b0;
    pwrite <= 1'b0;
    repeat(3) @(posedge pclk);
    @(negedge pclk);
    presetn <= 1'b1;
    @(posedge pclk);

    for(int i = 0; i <NUM_TESTS; i++) begin
        transfer <= $urandom;
        pwrite <= $urandom;
        //psel <= $urandom;
        //psel <= 1'b1;
        wdata <= $urandom;
        addr <= $urandom_range(16);
        //raddr <= $urandom;
        //cg.sample();
        if(transfer == 1'b1 && pwrite == 1'b0)
            $monitor("Time: %t | transfer: %b | pwrite: %b | pready: %b | addr: %h | prdata: %h | pwdata: %h", $time,  transfer, pwrite, pready, addr, apb.apb_m.rdata, apb.apb_m.pwdata);
        else if( transfer == 1'b1 && pwrite == 1'b1)
            $monitor("Time: %t | transfer: %b | pwrite: %b | pready: %b | addr: %h | pwdata: %h ", $time,  transfer, pwrite, pready, addr, apb.apb_m.pwdata);
        // else if (!transfer) begin
        //     $monitor("Time: %t | transfer: %b Not transfering data ", $time, transfer);
        // end
        @(posedge pclk);

    end

    $display("Tests completed");
    disable generate_clock;
end

endmodule

