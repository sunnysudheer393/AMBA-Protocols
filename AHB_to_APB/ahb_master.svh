// module AHB_master(
//     input logic ; Hclk, Hresetn, Hreadyout,
//     input logic [1:0] Hresp,
//     input logic [31:0] Hrdata,
//     output logic Hwrite,, Hreadyin,
//     output logic [1:0] Htrans,
//     output logic [31:0] Hwdata, Haddr,
//     logic [2:0] Hburst,
//     logic [1:0] Hsize

// );

// logic [31:0] write_data;
// logic [31:0] read_data;

// //Write task
// task write_logic();
// begin
//     @(posedge Hclk);
//     begin
//         Hwrite = 1'b1;
//         Htrans = 2'b00;
//         Hsize = 3'b000;
//         Hburst = 3'b00;
//         Hreadyin = 1'b1;
//         Haddr = 32'h8000_0001;
//     end
//     @(posedge Hclk);
//     begin
//         Htrans = 2'b00;
//         Hwdata = write_data;
//     end
// end
// endtask


// //Read task
// task read_logic();
// begin
//     @(posedge Hclk);
//     begin
//         Hwrite = 1'b0;
//         Htrans = 2'b00;
//         Hsize = 3'b000;
//         Hburst = 3'b000;
//         Hreadyin = 1'b1;
//         Haddr = 32'h8000_00A@;
//     end
//     @(posedge Hclk);
//     begin
//         Htrans = 2'b00;
//         read_data = Hrdata;
//     end
// end
// endtask


// endmodule

module ahb_master(
    input logic hclk,
    input logic hresetn,
    input logic hreadyout,
    input logic [1:0] hresp,
    input logic [31:0] hrdata,addr,data_in,
    input logic hwrite,

    output logic [31:0] haddr,data_out,
    input logic [1:0] hsel,
    output logic [2:0] hsize,
    output logic [2:0] hburst,
    output logic [31:0] hwdata,
    output logic hready
);

//logic [31:0] addr, data_in, data_out;

// TB signals
// hwrite
// addr
// data_in

typedef enum logic [1:0] {Idle = 2'b00, Read = 2'b01, Write = 2'b10 } state_r;

state_r current_state, next_state;

always_ff @(posedge hclk) begin
    if(!hresetn) current_state <= Idle;
    else current_state <= next_state;
end

always_comb begin
    if(!hresetn) next_state = Idle;
    else begin
        hsize = 3'b000;
        hburst = 3'b000;
        //hreadyout = 1'b0;
        next_state = current_state;
        case(current_state)
            Idle: begin
                    //data_out <= hrdata;
                haddr = addr;
                if(hwrite) next_state = Write;
                else if(!hwrite) next_state = Read;
            end
            Read: begin
                if(hreadyout) begin
                    hready = 1'b1;
                    data_out = hrdata;
                    next_state = Idle;
                end else next_state = Read;
            end
            Write: begin
                if(hreadyout) begin
                    hready = 1'b1;
                    hwdata = data_in;
                    next_state = Idle;
                end else next_state = Write;
            end
            default: next_state = Idle;
        endcase
    end
end

//assign hrdata = data_out;

endmodule
