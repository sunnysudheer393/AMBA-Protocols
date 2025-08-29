module apb_slave(
    input pclk,presetn, psel, penable, pwrite,
    input [7:0] paddr, pwdata,
    output [7:0] prdata,
    output logic pready
);

    logic [7:0] addr;
    logic [7:0] mem[63:0];
    assign prdata = mem[addr;]
    always_comb begin
        if(!presetn) begin
            pready = 1'b0;
        end else if (psel && !penable && !pwrite) begin
            pready = 1'b0;
        end else if (psel && penable && !pwrite) begin
            pready = 1'b1;
            addr = paddr;
        end else if (psel && !penabe && pwrite) begin
            pready = 1'b0;
        end else if (psel && penabe && pwrite) begin
            pready = 1'b1;
            mem[addr] = pwdata;
        end else pready = 1'b0;
    end
endmodule