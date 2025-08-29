module apb_master(
    input logic pclk, presetn,
    input logic [31:0] wdata, prdata, addr,
    input logic transfer, pready, pwrite,

    output logic [31:0] pwdata, rdata, paddr,
    output logic penable,psel,
    output logic pslverr

);

logic invalid_state_error, invalid_read_addr, invalid_write_addr, invalid_write_data;

typedef enum logic [1:0] { Idle = 2'b00, Setup = 2'b01, Enable = 2'b10  } state_r;
state_r current_state, next_state;

always_ff @(posedge pclk) begin
    if(!presetn) begin
        current_state <= Idle;
        //pwdata <= '0;
    end else current_state <= next_state;
end

always_comb begin
   // pwrite = write;
   if(!presetn) begin
        pwdata = '0;
        penable = 1'b0;
        psel = 1'b0;
        paddr = '0;
   end else begin
    next_state = current_state;
        case (current_state)
            Idle: begin
                penable = 1'b0;
                psel = 1'b0;
                if(transfer) begin
                    //psel <= 1'b1;
                    paddr = addr;
                    pwdata = wdata;
                    next_state = Setup;
                end else next_state = Idle;
            end
            Setup: begin
                psel = 1'b1;
                penable = 1'b1;
                if(!transfer) next_state = Idle;
                // if(pwrite) begin
                //     pwdata = wdata;
                //     next_state = Enable;
                // end else if(!pwrite) begin
                //     paddr = addr;
                //    pwdata = '0;
                //     next_state = Enable;
                // end //else paddr = '0;
                next_state = Enable;
            end
            Enable: begin
            // if(psel) begin
                //penable = 1'b1;
                //end
                //psel = 1'b0;
                if(transfer && pready && !pwrite) begin
                    rdata = prdata;
                    next_state = Setup;
                end else if(!pready) next_state = Enable;
                else next_state = Idle;
                // if(transfer && !pslverr) begin
                //     if(pready) begin
                //         rdata = prdata;
                //         next_state = Setup;
                //         //if(!pwrite) begin

                //         //end
                //     end else next_state = Enable;
                //end else next_state = Idle;
            end
            default: next_state = Idle;
        endcase
   end
end

//implement plsverr logic here for the master and used it to read data and change state above
always_comb begin
    
    if(!presetn) begin
        pslverr = 1'b0;
        invalid_state_error = 1'b0;
        invalid_read_addr = 1'b0;
        invalid_write_addr = 1'b0;
        invalid_write_data = 1'b0;
    end else if(current_state == Idle && next_state == Enable) invalid_state_error = 1'b1;
    else if((wdata == 32'dx) && (pwrite) &&(current_state == Idle || next_state == Enable)) invalid_write_data = 1'b1;
    else if((addr == 32'dx) && (pwrite) &&(current_state == Idle || next_state == Enable)) invalid_write_addr = 1'b1;
    else if((addr == 32'dx) && (!pwrite) &&(current_state == Idle || next_state == Enable)) invalid_read_addr = 1'b1;
    else begin
        pslverr = 1'b0;
        invalid_state_error = 1'b0;
        invalid_read_addr = 1'b0;
        invalid_write_addr = 1'b0;
        invalid_write_data = 1'b0;
    end
    pslverr = invalid_state_error || invalid_read_addr || invalid_write_addr || invalid_write_data;
end

endmodule
