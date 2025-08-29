/*
`timescale 1ns/100ps

module axi_tb #(parameter int Width = 32,
                parameter int NUM_TESTS = 1000) ();
logic ACLK = 1'b1, ARESETN;
logic [Width-1:0] awaddr,wdata,araddr;
logic [(Width/8)-1:0] wstrb;
logic [7:0] data_out;

axi_top dut(.ACLK(ACLK), .ARESETN(ARESETN), .awaddr(awaddr),.wdata(wdata), .araddr(araddr),.wstrb(wstrb), .data_out(data_out));

initial begin : clock_generation
    forever #5 ACLK <= ~ACLK;
end

initial begin : write_stimulus_and_reset
    $timeformat(-9,0,"ns");

    ARESETN <= 1'b0;
    awaddr <= '0;
    wdata <= '0;
    araddr <= '0;
    wstrb <= '0;

    repeat(3) @(posedge ACLK);
    @(negedge ACLK);
    ARESETN <= 1'b1;

    for(int i = 0; i<NUM_TESTS;i++) begin
        awaddr <= $urandom;
        wdata <= $urandom;
        wstrb <= $urandom;
        @(posedge ACLK);
    end

    disable clock_generation;
    $display("Tests completed.");

end

endmodule

*/

// `timescale 1ns/100ps

// module axi_tb #(parameter int Width = 32,
//                 parameter int NUM_TESTS = 1000,
//                 parameter ADDR_WIDTH = 32,
//                 parameter DATA_WIDTH = 32) ();

//   logic clk = 1'b1,rst_n;
//   logic                  start_write=1'b0;
//   logic                  start_read;
//   logic [ADDR_WIDTH-1:0] addr_in;
//   logic [DATA_WIDTH-1:0] data_in;
//   logic [DATA_WIDTH-1:0] data_out;
//   logic                  done_write;
//   logic                  done_read;
// //   randc bit start_write = !start_read;
// //   randc bit start_read = !start_write

//   //Instantiate the test module
//   axi_test axi (.clk(clk), .rst_n(rst_n), 
//                 .start_write(start_write), .start_read(start_read),
//                 .addr_in(addr_in), .data_in(data_in), .data_out(data_out),
//                 .done_write(done_write), .done_read(done_read)
//     );

// initial begin : generate_clock
//     forever #5 clk <= ~clk;
// end

// initial begin : generate_stimulus_and_check_output
//     $timeformat(-9,0,"ns");

//     rst_n <= 1'b0;
//     // start_write <= 1'b0;
//     // start_read <= 1'b0;
//     addr_in <= '0;
//     data_in <= '0;

//     repeat(3) @(posedge clk);
//     @(negedge clk);
//     rst_n <= 1'b1;

//     // for(int i=0; i<10; i++) begin
//     //     //generate random sequence of inputs here
//     //     start_write <= $urandom;
//     //     //start_read <= $urandom;
//     //     addr_in <= $urandom;
//     //     data_in <= $urandom;
//     //     @(posedge clk);
//     // end

//     for(int i=0; i<20; i++) begin
//         //generate random sequence of inputs here
//         start_write <= ~start_write;
//         //start_read <= ~start_read;
//         addr_in <= $urandom;
//         data_in <= $urandom;
//         @(posedge clk);
//     end

//     disable generate_clock;

//     $display("Tests completed");


// end

// endmodule

`timescale 1ns/100ps
//`include "axi_intf.sv"

module axi_tb #(parameter int NUM_TESTS = 1000,
                parameter ADDR_WIDTH = 32,
                parameter DATA_WIDTH = 32) ();

  logic aclk = 1'b1,areset_n;
  logic [ADDR_WIDTH-1:0] awaddr,araddr;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;

  //Instantiate the test module
  axi_intf axi(.aclk(aclk), .areset_n(areset_n));
  axi_encap axi_uut (.aclk(axi.aclk), .areset_n(axi.areset_n), .awaddr(awaddr), .araddr(araddr), .data_in(data_in), .data_out(data_out), .axi(axi) );
  
initial begin : generate_clock
    forever #5 aclk <= ~aclk;
end

initial begin : generate_stimulus_and_check_output
    $timeformat(-9,0,"ns");

    areset_n <= 1'b0;
    awaddr <= '0;
    araddr <= '0;
    data_in <= '0;

   repeat(3) @(posedge aclk);
   @(negedge aclk);
    areset_n <= 1'b1;
    @(posedge aclk);

    for(int i=0; i<5; i++) begin
        //generate random sequence of inputs here
        awaddr <= $urandom;
        data_in <= $urandom;
        @(posedge aclk);
        #30;
        araddr <= awaddr;
    end

    disable generate_clock;

    $display("Tests completed");


end
  
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,axi_tb);
end

endmodule
