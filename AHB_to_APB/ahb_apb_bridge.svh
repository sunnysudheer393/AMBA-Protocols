module ahb_apb_bridge(
    //output to AHB/input to bridge
    input logic hclk, hresetn, hsel,
    input logic [2:0] hsize,
    input logic [31:0] haddr, hwdata,
    input logic [2:0] htrans,
    input logic hwrite, Hreadyin,

    //output from APB/input to bridge
    input logic [31:0] prdata,

    //Input to AHB/output from bridge
    output logic [31:0] hrdata,
    output logic Hreadyout,
    output logic [1:0] hresp,

    //input to APB/output from bridge
    output logic [2:0] psel,
    output logic penable, pwrite,
    output logic [31:0] paddr, pwdata
);

logic valid, hwrite_temp;
logic [31:0] haddr_temp;
typedef enum logic [2:0] {IDLE = 3'b000, W_WAIT = 3'b001, WRITE = 3'b010, W_ENABLE = 3'b011, WRITE_P = 3'b100, W_ENABLE_P = 3'b101, READ = 3'b110, R_ENABLE = 3'b111 } state_r;

state_r current_state, next_state;

assign valid = ((hsel) && (htrans == 2'b01 || htrans == 2'b10));

always_ff @(posedge hclk) begin
    if(!hresetn) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    if(!hresetn) next_state = IDLE;
    else begin
        case(current_state)
            IDLE: begin
                psel = 1'b1;
                penable = 1'b0;
                Hreadyout = 1'b1;

                if(valid) begin
                    if(hwrite) begin
                        next_state = W_WAIT;
                    end else if (!hwrite) begin
                        next_state = READ;
                    end
                end else next_state = IDLE;
            end
            W_WAIT: begin
                penable = 1'b0;
                haddr_temp = haddr;
                hwrite_temp = hwrite;

                if(valid) begin
                    next_state = WRITE_P;
                end else if(!valid) next_state = WRITE;
            end
            WRITE: begin
                psel = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata;
                pwrite = 1'b1;
                penable = 1'b0;
                Hreadyout = 1'b0;

                if(valid) begin
                    next_state = W_ENABLE_P;
                end else if (!valid) begin
                    next_state = W_ENABLE;
                end
            end
            W_ENABLE: begin
                penable = 1'b1;
                Hreadyout = 1'b1;

                if(valid && hwrite) begin
                    next_state = W_WAIT;
                end else if (valid && !hwrite) begin
                    next_state = READ;
                end else if (!valid) begin
                    next_state = IDLE;
                end
            end
            WRITE_P: begin
                psel = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata;
                pwrite = 1'b1;
                penable = 1'b0;
                Hreadyout = 1'b0;

                hwrite_temp = hwrite;

                next_state = W_ENABLE_P;
            end
            W_ENABLE_P: begin
                penable = 1'b1;
                Hreadyout = 1'b1;

                if(valid && hwrite) begin
                    next_state = WRITE_P;
                end else if (!valid && hwrite) begin
                    next_state = WRITE;
                end else if (!hwrite) begin
                    next_state = READ;
                end
            end
            READ: begin
                psel = 1'b1;
                paddr = haddr;
                pwrite = 1'b0;
                penable = 1'b0;
                Hreadyout = 1'b0;

                next_state = R_ENABLE;
            end
            R_ENABLE: begin
                penable = 1'b1;
                hrdata = prdata;
                Hreadyout = 1'b1;

                if(valid && !hwrite) begin
                    next_state = READ;
                end else if (!valid) begin
                    next_state = IDLE;
                end else if (valid && hwrite) begin
                    next_state = W_WAIT;
                end
            end
            default: next_state = IDLE;
        endcase
    end
end

endmodule
