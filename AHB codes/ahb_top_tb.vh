module ahb_top_tb();
logic  hclk;
logic hresetn;
logic enable;
logic [31:0] data_in_a;
logic [31:0] data_in_b;
logic write;
logic [1:0] slave_sel;

logic [31:0] data_out;

initial 
begin
    hclk = 0;
    hresetn = 1;
    enable = 1'b1;
    data_in_a = 32'd0;
    data_in_b = 32'd0;
    write = 1'b0;
    slave_sel = 1'b0;
    
    #10 hresetn = 0;
    #10 hresetn = 1;
end

initial begin
    forever #5 hclk = ~hclk;
end

task reset_dut();
    begin
        @(negedge hclk)
            hresetn = 0;
        @(negedge hclk)
            hresetn = 1;
    end
endtask

task write_dut(input [1:0] sel, input [31:0] address_input, input [31:0]a, input [31:0] b );
begin
    @(negedge hclk)
        slave_sel = sel;
        enable = 1'b1;
        addr = address;
    
    @(negedge hclk)
        data_in_a = a;
        data_in_b = b;
        write = 1'b1;

    @(negedge hclk)
        enable = 1'b0;
end
endtask

task read_dut(input [1:0] sel, input [31:0] address);
begin
    @(negedge hclk)
        enable = 1'b1;
        slave_sel = sel;
        addr = address;
    @(negedge hclk)
        wr = 1'b0;
    @(negedge hclk)
        wr = 1'b0;
    @(negedge hclk)
        wr = 1'b0;
    @(negedge hclk)
        enable = 1'b0;
end
endtask

//initial begin
    //slave_1
    write_dut(2'b00, 32'd1, 32'd5, 32'd10);
    read_dut(2'b00, 32'd1);

    //slave2
    write_dut(2'b01, 32'd2, 32'd11, 32'd13);
    read_dut(2'b01, 32'd2);


    //slave3
    write_dut(2'b10, 32'd3, 32'd17, 32'd13);
    read_dut(2'b10, 32'd3);

    //slave4
    write_dut(2'b11, 32'd4, 32'd11, 32'd13);
    read_dut(2'b11, 32'd4);
//end

ahb_top dut(.hclk(hclk), .hresetn(hresetn), .enable(enable), .data_in_a(data_in_a), .data_in_b(data_in_b)
.addr(addr), .write(write), .slave_sel(slave_sel), .data_out(data_out)
);

endmodule