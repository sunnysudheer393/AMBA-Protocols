module apb_master(
    input logic [7:0] apb_write_paddr,apb_read_paddr,
    input logic [7:0] apb_write_data,prdata,
    input logic presetn, clk, read, write, transfer, pready,

    output logic psel1,psel2,
    output logic penable,
    output logic [8:0] paddr,
    //output write,
    output logic [7:0] pwdata, apb_read_data_out,
    output logic pslverr
);

    logic invalid_setup_error;
    logic setup_error, invalid_read_paddr, invalid_write_paddr, invalid_write_data;

    //parameter idle = 2'b01, setup = 2'b10. enable = 2'b11;
    typedef enum logic [1:0] { idle = 2'b01, setup = 2'b10, enable = 2'11} state_r;
    state_r present_state ,next_state;
    always_ff @(posedge clk)
    begin
        if(!presetn) begin
            present_state <= idle;
        end
        else begin
            present_state <= next_state;
        end

    end

    always @(present_state,transfer, pready)
    begin
        pwrite = write;
        case(present_state)
            idle:
                begin
                    penable = 0;
                    if(!transfer)
                        next_state = idle;
                    else
                        next_state = setup;
                end
            setup:
                begin
                    penable = 0;
                    if(read == 1'b1 && write ==1'b0) begin
                        paddr = apb_read_paddr;

                    end else if(read == 1'b0 && write == 1'b1) begin
                        paddr = apb_write_paddr;
                        pwdata = apb_write_data;

                    end else paddr = '0;
                end
            enable:
                begin
                    if(psel1 || psel2)
                        penabe = 1'b1;
                    if(transfer & !pslverr) begin
                        if(pready) begin
                            if(read == 1'b0 && write == 1'b1)
                                next_state = setup;
                            else if (read == 1'b1 && write == 1'b0) begin
                                next_state = setup;
                                apb_read_data_out = prdata;
                            end

                        else
                            next_state = enable;
                        end
                        next_state = idle;
                    end
                end
            default: begin
                    next_state = idle;
                end

        endcase

    end

    //if present state is idle then selects are 1'b0 and 1'b0;
    //if not idle it'll check for last bit of paddr
    //if paddr[8] is asserted, psel2 is selected else psel1 is selected
    assign {psel1,psel2} = (present_state != idle)?(paddr[8]? {1'b0,1'b1}:{1'b1,1'b0}) :2'd0;


    //PSLAVE ERROR LOGIC
    always_comb
    begin
        invalid_setup_error = setup_error || invalid_read_paddr ||invalid_write_data || invalid_write_paddr;
        if(!presetn) begin
            setup_error = 0;
            invalid_read_paddr = 0;
            invalid_write_paddr = 0;

        end else if (present_state == idle && next_state == enable) begin
            setup_error = 1;
        end else if ((apb_write_data == 8'dx) && (read == 1'b0) && (write == 1'b1) && (present_state == setup ||present_state == enable)) begin
            invalid_write_data = 1'b1;
        end else if ((apb_read_paddr == 9'dx) && (read == 1'b1) && (write ==1'b0) && (present_state == setup) || (present_state == enable)) begin
            invalid_read_paddr = 1'b1;
        end else if ((apb_write_paddr == 9'dx) && (read == 1'b0) && (write == 1'b1) && (present_state == setup) || (present_state == enable)) begin
            invalid_write_paddr = 1'b0;
        end else begin
            invalid_write_paddr = 1'b0;
            invalid_write_data = 1'b0;
            invalid_read_paddr = 1'b0;
            //invalid_setup_error = 1'b0;
        end
        pslverr = invalid_setup_error;
    end

endmodule
