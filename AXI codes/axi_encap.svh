module axi_encap #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32)(
    input logic aclk, areset_n,
    input logic [ADDR_WIDTH-1:0] awaddr,araddr,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,

    axi_intf axi
);

//Instantiate Master
master_axi m_dut (.aclk(aclk), .areset_n(areset_n), .awaddr(awaddr), .araddr(araddr), .data_in(data_in), .data_out(data_out), .axi(axi));

//Instantiate Slave
slave_axi s_dut (.aclk(aclk), .areset_n(areset_n), .axi(axi));

endmodule
