module ahb_top_tb #(parameter int NUM_TESTS = 1000)();
logic hclk = 1'b0, hresetn, hwrite,hreadyout=1'b0;
logic [31:0] addr, data;
logic [2:0] hburst, hsize;

logic [31:0] read_data;

ahb_top ahb(.hclk(hclk), .hresetn(hresetn), .hwrite(hwrite),  .addr(addr), .hreadyout(hreadyout),
            .data(data), .hburst(hburst), .hsize(hsize), .read_data(read_data)
);

initial begin : generate_clock
    forever #5 hclk <= ~hclk;
end

//assign rdata = prdata;

initial begin
    hresetn <= 1'b0;
    data <= '0;
    //transfer <= 1'b0;
    addr <= '0;
    hreadyout <= 1'b0;
    //psel <= 1'b0;
    hwrite <= 1'b0;
    repeat(3) @(posedge hclk);
    @(negedge hclk);
    hresetn <= 1'b1;
    @(posedge hclk);

    for(int i = 0; i <100; i++) begin
        //transfer <= $urandom;
        hwrite <= $urandom;
        //psel <= $urandom;
        //psel <= 1'b1;
        hreadyout <= 1'b1;;
        //hburst <= 3'b000;
        //hsize <= 3'b000;
        data <= $urandom;
        addr <= $urandom_range(16);
        //raddr <= $urandom;
        $monitor("Time: %t  | hwrite: %b | addr: %h | data: %h | read_data: %h", $time, hwrite, addr, data, read_data);
        @(posedge hclk);

    end

    $display("Tests completed");
    disable generate_clock;
end

endmodule
