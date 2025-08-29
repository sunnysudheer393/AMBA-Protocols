module ahb_slave(
    input logic hclk,hresetn,
    input logic [31:0] haddr, hwdata,
    input logic [2:0] hsize,
    input logic [1:0] htrans,
    input logic hwrite, hreadyin = 1'b1,

    output logic [31:0] hrdata,
    output logic hreadyout=1'b1,
    output logic [1:0] hresp
);

logic [31:0] mem [31:0];
typedef enum logic [1:0] { Idle = 2'b00, Read = 2'b01, Write = 2'b10 } state_r;
state_r current_state, next_state;

always_ff @(posedge hclk)
begin
    if(!hresetn) begin
        current_state <= Idle;
    end else current_state <= next_state;
end

always_comb begin
    if(!hresetn) begin 
        for (int i = 0; i < 32; i++) begin
            mem[i] = 32'h0;
        end
    //mem = '{default:0};
        next_state = Idle;
    end
    else begin
        case(current_state)
            Idle: begin
                if(hwrite) begin
                    next_state = Write;
                end else if (!hwrite) begin
                    next_state = Read;
                end
            end
            Read: begin
                if(hreadyin) begin
                    hreadyout = 1'b1;
                    hresp = 2'b00;
                    hrdata = mem[haddr];
                    next_state = Idle;
                end
            end
            Write: begin
                if(hreadyin) begin
                    hreadyout = 1'b1;
                    hresp = 2'b00;
                    mem[haddr] = hwdata;
                    next_state = Idle;
                end
            end
            default: next_state = Idle;
        endcase
    end
end
assign hready = hreadyout;

endmodule
