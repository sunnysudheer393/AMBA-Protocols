module ahb_master(
    input hclk,
    input hresetn,
    input enable,
    input [31:0] data_in_a,
    input [31:0] data_in_b,
    input [31:0] addr,
    input wr,
    // input hreadyout,
    // input hresp,
    // input [31:0] hrdata,
    input [1:0] slave_sel,

    output logic [1:0] sel,
    output logic [31:0] haddr,
    output logic hwrite,
    output logic [2:0] hsize,
    output logic [2:0] hburst,
    //output logic [3:0] hprot,
    output logic [1:0] htrans,
    output logic [31:0] hwdata,
    output logic [31:0] dout);

    typedef enum logic { idle = 2'b00, s1 = 2'b01, s2 =2'b10, s3 = 2'b11 } state_r;
    state_r present_state, next_state;

    //state_logic === register logic
    always_ff @(posedge hclk) begin : state_logicister
        if(!hresetn)
            present_state <= idle;
        else
            present_state <= next_state;
        //end if
    end

    //next_state and output logic
    always_comb @(*) begin
        case(present_state)
            idle : begin
                sel <= 2'b00;
                haddr <= '0;
                hwrite <= 1'b0;
                hsize <= 3'b000;
                hburst <= 3'b000;
                //hprot <= 4'b0000;
                htrans <= 2'b00;
                hready <= 1'b0;
                hwdata <= '0;
                dout <= '0;
                if(enable == 1'b1) begin
                    next_state = s1;
                end else begin
                    next_state <= idle;
                end
            end
            s1 : begin
                sel <= slave_sel;
                haddr <= addr;
                hwrite <= wr;
                hburst <= 3'b000;
                hready <= 1'b1;
                hwdata <= data_in_a + data_in_b;
                dout <= dout;
                if(wr == 1'b1) begin
                    next_state <= s2;
                end else begin
                    next_state <= s3;
                end
            end
            s2 : begin
                //hwrite = 1 implies write operation
                sel <= slave_sel;
                haddr <= addr;
                hwrite <= wr;
                hburst <= 3'b000;
                hready <= 1'b1;
                hwdata <= data_in_a + data_in_b;
                dout <= dout;
                if(enable == 1'b1) begin
                    next_state <= s1;
                end else begin
                    next_state <= idle;
                end
            end
            s3 : begin
                sel <= slave_sel;
                haddr <= addr;
                hwrite <= wr;
                hburst <= 3'b000;
                hready <= 1'b1;
                hwdata <= hwdata;
                dout <= dout;
                if(enable == 1'b1) begin
                    next_state <= s1;
                end else begin
                    next_state <= idle;
                end
            end
            default : begin
                sel <= slave_sel;
                haddr <= haddr;
                hwrite <= hwrite;
                hburst <= hburst;
                hready <= 1'b0;
                hwdata <= hwdata;
                dout <= dout;
                next_state ,= idle;
            end

        endcase
    end

endmodule


// module ahb_master(
//     input logic hclk,
//     input logic hresetn,
//     input logic hreadyout,
//     input logic hresp,
//     input logic [31:0] hrdata,
//     input logic hwrite,

//     output logic [31:0] haddr,
//     //output logic [1:0] hsel,
//     output logic [2:0] hsize,
//     output logic [2:0] hburst,
//     output logic [31:0] hwdata
// );

// logic [31:0] addr, data_in, data_out;

// // TB signals
// // hwrite
// // addr
// // data_in

// typedef enum logic [1:0] {Idle = 2'00, Read = 2'b01, Write = 2'10 } state_r;

// state_r current_state, next_state;

// always_ff @(posedge hclk) begin
//     if(!hresentn) current_state <= Idle;
//     else current_state <= next_state;
// end

// always_ff @(posedge hclk) begin
//     if(!hresentn) next_state <= Idle;
//     else begin
//         hsize <= 3'b000;
//         hburst <= 3'b000;

//         case(next_state)
//             Idle: begin
//                     data_out <= hrdata;
//                 haddr <= addr;
//                 if(hwrite) next_state <= Write;
//                 else if(!hwrite) next_state <= Read;
//             end
//             Read: begin
//                 if(hready) begin
//                     data_out <= hrdata;
//                     next_state <= Idle;
//                 end else next_state <= Read;
//             end
//             Write: begin
//                 if(hready) begin
//                     hwdata <= data_in;
//                     next_state <= Idle;
//                 end else next_state <= Write;
//             end
//             default: next_state <= Idle;
//         endcase
//     end
// end

// endmodule
