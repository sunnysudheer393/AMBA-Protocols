`include "axi_intf.svh"

`timescale 1ns/100ps

module a_tb #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32, parameter NUM_TESTS = 1000) ();
logic aclk = 1'b0;
logic areset_n;

logic [ADDR_WIDTH-1:0] awaddr;
logic [ADDR_WIDTH-1:0] araddr;
logic [DATA_WIDTH-1:0] data_in;

initial begin : clock_generation
    forever #5 aclk <= ~aclk;
end


axi_intf axi(.*);
master_axi m(.*);
slave_axi s(.*);

initial begin : input_generate
    areset_n <= 1'b0;
    awaddr <= '0;
    araddr <= '0;
    data_in <= '0;
    repeat(3) @(posedge aclk);
    @(negedge aclk);
    areset_n <= 1'b1;

    //generate random inputs
    for(int i = 0 ; i<10; i++) begin
        awaddr <= $urandom;
        // araddr <= $urandom;
        data_in <= $urandom;
        @(posedge aclk);
    end
    $display("Test completed");
    disable clock_generation;


end
 
endmodule
