 module apb_slave(
    input logic pclk, presetn, pwrite,psel, penable,transfer,
    input logic [31:0] addr, pwdata,

    output logic [31:0] prdata,
    output logic pready
);

//logic [31:0] addr;
logic [31:0] mem[15:0];

always_comb begin
    if(!presetn) begin
        pready = 1'b0;
        mem = '{default:0};
        prdata = '0;
    end else if (psel && penable && !pwrite) begin
        pready = 1'b1;
        //addr = paddr;
        prdata = mem[addr];
    end else if (psel && penable && pwrite) begin
        pready = 1'b1;
        mem[addr] = pwdata;
    end else pready = 1'b0;
end

endmodule
