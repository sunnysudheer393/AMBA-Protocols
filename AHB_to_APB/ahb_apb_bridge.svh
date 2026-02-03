module ahb_apb_bridge(
    //output to AHB/input to bridge
    input logic hclk, hresetn, hsel,
    input logic [2:0] hsize,
    input logic [31:0] haddr, hwdata,
    input logic [1:0] htrans,
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

logic valid;
logic hwrite_reg_temp, hwrite_reg;
logic [31:0] haddr_reg, hwdata_reg;

typedef enum logic [2:0] {IDLE = 3'b000, W_WAIT = 3'b001, WRITE = 3'b010, W_ENABLE = 3'b011, WRITE_P = 3'b100, W_ENABLE_P = 3'b101, READ = 3'b110, R_ENABLE = 3'b111 } state_r;

state_r current_state, next_state;

assign valid = ((hsel) && (htrans == 2'b01 || htrans == 2'b10));


// current state logic
always_ff @(posedge hclk) begin
    if(!hresetn) begin
        current_state <= IDLE;
        hwdata_reg <= 32'h0;
        haddr_reg <= 32'h0;
        hwrite_reg <= 1'b0;
        hwrite_reg_temp <= 1'b0;
    end else begin
        current_state <= next_state;

        //capture address for valid transaction
        if(valid) begin
            haddr_reg <= haddr;
            hwrite_reg <= hwrite;
        end

        //capture data when it's available
        if(current_state == W_WAIT || current_state == WRITE_P) begin
            hwdata_reg <= hwdata;
        end

        //for pipelined data transfers
        if(curren_state == WRITE_P || current_state == W_ENABLE_P) begin
            hwrite_reg_temp <= hwrite;
        end
    end
end

//next state logic
always_comb begin
    if(!hresetn) begin
        next_state = IDLE;
        //default values to all outputs(to avoid latches)
        psel = 3'b000;
        penable = 1'b0;
        pwrite = 1'b0;
        Hreadyout = 1'b1;
        paddr = 32'h0;
        pwdata = 32'h0;
        hrdata = 32'h0;
        hresp = 2'b00; //Ok response
    end else begin
        case(current_state)
            IDLE: begin
                if(valid) begin
                    if(hwrite) begin
                        paddr = haddr_reg;
                        next_state = W_WAIT;
                    end else if (!hwrite) begin
                        paddr = haddr_reg;
                        next_state = READ;
                    end
                end else next_state = IDLE;
            end
            W_WAIT: begin
                if(valid) begin
                    next_state = WRITE_P;
                end else if(!valid) next_state = WRITE;
            end
            WRITE: begin
                psel = 3'b001;
                paddr = haddr_reg; // addr captured in W_Wait state
                pwdata = hwdata_reg;// Data captured in W_Wait state
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
                psel = 3'b001;
                penable = 1'b1;
                Hreadyout = 1'b1;
                pwrite = 1'b1;
                //below for maintaining stability
                pwdata = hwdata_reg;
                paddr = haddr_reg;
                if(valid && hwrite) begin
                    next_state = W_WAIT;
                end else if (valid && !hwrite) begin
                    next_state = READ;
                end else if (!valid) begin
                    next_state = IDLE;
                end
            end
            WRITE_P: begin
                psel = 3'b001;
                paddr = haddr_reg;
                pwdata = hwdata_reg;
                penable = 1'b0;
                pwrite = 1'b1;
                Hreadyout = 1'b0;
                next_state = W_ENABLE_P;
            end
            W_ENABLE_P: begin
                psel = 1'b1;
                paddr = haddr_reg;
                pwdata = hwdata_reg;
                pwrite = 1'b1;
                penable = 1'b1;
                Hreadyout = 1'b1;
                if(valid && hwrite_reg) begin
                    next_state = WRITE_P;
                end else if (!valid && hwrite_reg) begin
                    next_state = WRITE;
                end else if (!hwrite_reg) begin
                    next_state = READ;
                end
            end
            READ: begin
                psel = 3'b001;
                penable = 1'b0;
                pwrite = 1'b0;
                Hreadyout = 1'b0;
                paddr = haddr_reg;

                next_state = R_ENABLE;
            end
            R_ENABLE: begin
                psel = 3'b001;
                paddr = haddr_reg;
                pwrite = 1'b0;
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
