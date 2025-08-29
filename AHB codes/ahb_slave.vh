module ahb_slave(
    input hclk,
    input hresetn,
    input hsel,
    input [31:0] haddr,
    input [31:0] hwrite,
    input [2:0] hsize,
    input [2:0] hburst,
    input [3:0] hprot,
    input [1:0] htrans,
    input hmastlock,
    input [31:0] hwdata,
    input hready,

    output logic [31:0] hrdata,
    output logic hreadyout,
    output logic hresp);

    logic [31:0] mem_arr[31:0];
    logic [4:0] waddr;
    logic [4:0] raddr;

    typedef enum logic {  idle = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11} state_r;
    state_r present_state, next_state;

    logic single_flag;
    logic incr_flag,
    logic incr4_flag;
    logic incr8_flag;
    logic incr16_flag;
    logic wrap4_flag;
    logic wrap8_flag;
    logic wrap16_flag;

    //state logicister
    always_ff @(posedge hclk) begin
        if(!hresetn) begin
            present_state <= idle;
        end else begin
            present_state <= next_state;
        end
    end

    //transition logic
    always @(posedge hclk) begin
        single_flag = 1'b0;
        incr_flag = 1'b0;
        wrap4_flag = 1'b0;
        wrap8_flag = 1'b0;
        wrap16_flag = 1'b0;
        incr4_flag = 1'b0;
        incr16_flag = 1'b0;
        incr8_flag = 1'b0;

        case(present_state)
            idle : begin

                if(hsel == 1'b1) begin
                    next_state = s1;
                end else begin
                    next_state = idle;
                end
            end
            s1 : begin
                case(hburst) //single tranfer to incr16 burst transfer
                    3'000 : begin
                        single_flag = 1'b1;
                    end
                    3'b001 : begin
                        incr_flag = 1'b1;
                    end
                    3'b010 begin
                        wrap4_flag = 1'b1;
                    end
                    3'b011: begin
                        incr4_flag = 1'b1;
                    end
                    3'b100: begin
                        wrap8_flag = 1'b1;
                    end
                    3'101 : begin
                        incr8_flag = 1'b1;
                    end
                    3'b110 : begin
                        wrap16_flag = 1'b1;
                    end
                    3'b111 : begin
                        incr16_flag = 1'b1;
                    end
                    default : begin
                        single_flag = 1'b0;
                        incr_flag = 1'b0;
                        wrap4_flag = 1'b0;
                        wrap8_flag = 1'b0;
                        wrap16_flag = 1'b0;
                        incr4_flag = 1'b0;
                        incr16_flag = 1'b0;
                        incr8_flag = 1'b0;
                    end
                endcase
                if((hwrite == 1'b1) && (hready == 1'b1)) begin
                    next_state = s2;  //write operation
                end else if (hwrite == 1'b0) && (hready == 1'b1)) begin
                    next_state = s3;  //read operatiom
                end else begin
                    next_state = s1;
                end
            end
            s2 : begin //write phase
                case(hburst)
                    3'b000 : begin
                        if(hsel == 1'b1) begin
                            next_state = s1;
                        end else begin
                            next_state = idle;
                        end
                    end
                    3'b001 : begin
                        next_state = s2;
                    end
                    3'b010 : begin
                        next_state = s2;
                    end
                    3'b011 : begin
                        next_state = s2;
                    end
                    3'b100 : begin
                        next_state = s2;
                    end
                    3'b101 : begin
                        next_state = s2;
                    end
                    3'b110 : begin
                        next_state = s2;
                    end
                    3'b111 : begin
                        next_state = s2;
                    end
                    default : begin
                        if(hsel == 1'b1) begin
                            next_state = s1;
                        end else begin
                            next_state = idle;
                        end
                    end
                endcase
            end
            s3 : begin //read phase
                case(hburst)
                    3'b000 : begin
                        if(hsel == 1'b1) begin
                            next_state = s1;
                        end else begin
                            next_state = idle;
                        end
                    end
                     3'b001 : begin
                        next_state = s3;
                    end
                    3'b010 : begin
                        next_state = s3;
                    end
                    3'b011 : begin
                        next_state = s3;
                    end
                    3'b100 : begin
                        next_state = s3;
                    end
                    3'b101 : begin
                        next_state = s3;
                    end
                    3'b110 : begin
                        next_state = s3;
                    end
                    3'b111 : begin
                        next_state = s3;
                    end
                    default : begin
                        if(hsel == 1'b1) begin
                            next_state = s1;
                        end else begin
                            next_state = idle;
                        end
                    end
                endcase

            end
            default : begin
                next_state = idle;
            end

        endcase
    end

    //output logic
    always @(posedge hclk) begin
        if(!hresentn) begin
            hreadyout <= 1'b0;
            hresp <= 1'b0;
            hrdata <= '0;
            waddr <= waddr;
            raddr <= raddr;
        end else begin
            case(next_state)
                idle : begin
                    hreadyout <= 1'b0;
                    hresp <= 1'b0;
                    hrdata <= hrdata;
                    waddr <= waddr;
                    raddr <= raddr;
                end
                s1 : begin
                    hreadyout <= 1'b0;
                    hresp <= 1'b0;
                    hrdata <= hrdata;
                    waddr <= haddr;
                    raddr <= haddr;
                end
                s2 : begin // write transfer
                    case({single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag})
                        8'b1000_0000 : begin //single_flag is 1'b1
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            mem[waddr] <= hwdata;
                        end
                        8'b0100_0000 : begin //incrementing transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            mem[waddr] <= hwdata;
                            waddr <= waddr + 1'b1;
                        end
                        8'b0010_0000 : begin //wrap4 transfer
                            hreadyout  <= 1'b1;
                            hresp <= 1'b0;
                            if(waddr < (haddr+2'd3)) begin
                                mem[waddr] <= hwdata;
                                waddr <= waddr + 1;//wrapping till 4 bits
                            end else begin
                                mem[addr] <= hwdata;
                                waddr <= haddr;//wrap to initial address
                            end
                        end
                        8'b0001_0000 : begin //incrementing 4
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            mem[waddr] <= hwdata;
                            waddr <= waddr + 1;

                        end
                        8'b0000_1000 : begin //wrap till 8 addresses
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            if(waddr < (waddr+ 3'd7)) begin
                                mem[waddr] <= hwdata;
                                waddr <= waddr + 1;
                            end else begin
                                mem[waddr] <= hwdata;
                                waddr <= haddr;
                            end
                        end
                        8'b0000_0100 : begin //incr8 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            mem[waddr] <= hwdata;
                            waddr <= waddr + 1;
                        end
                        8'b0000_00100 : begin // wrap 16 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            if(waddr < (waddr + 4'd15)) begin // wrappin to 16 bits
                                mem[waddr] <= hwdata;
                                waddr <= waddr + 1;
                            end else begin
                                mem[waddr] <= hwdata;
                                waddr <= haddr;
                            end
                        end
                        8'b0000_0001 : begin //incr 16 bit
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            mem[waddr] <= hwdata;
                            waddr <= waddr + 1;
                        end
                        default : begin
                            hreadyout <= 1'b0;// previously it's 1'b1
                            hresp <= 1'b0;
                        end
                    endcase
                end
                s3: begin //read transfer
                    case(single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag)
                        8'b1000_0000 : begin //single transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            hrdata <= mem[raddr];
                        end
                        8'b0100_0000 : begin // incr transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            hrdata <= mem[raddr];
                            raddr <= raddr + 1;
                        end
                        8'b0010_0000 : begin //wrap4 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            if(raddr < (raddr + 2'd3)) begin //wrap to 4 beats
                                hrdata <= mem[raddr];
                                raddr <= raddr + 1;
                            end else begin
                                hrdata <= mem[raddr];
                                raddr <= haddr;
                            end
                        end
                        8'b0001_0000 : begin // incr4 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            hrdata <= mem[raddr];
                            raddr <= raddr + 1;
                        end
                        8'b0000_1000 : begin //wrap 8 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            if(raddr < (raddr + 3'd7)) begin //wrap to 8 beats
                                hrdata <= mem[raddr];
                                raddr <= raddr + 1;
                            end else begin
                                hrdata <= mem[raddr];
                                raddr <= haddr;
                            end
                        end
                        8'b0000_0100 : begin //incr 8 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            hrdata <= mem[raddr];
                            raddr <= raddr + 1;
                        end
                        8'b0000_0010 : begin  //wrap 16 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            if(raddr < (raddr + 4'd15)) begin //wrap to 4 beats
                                hrdata <= mem[raddr];
                                raddr <= raddr + 1;
                            end else begin
                                hrdata <= mem[raddr];
                                raddr <= haddr;
                            end
                        end
                        8'b0000_0001 : begin //incr 16 transfer
                            hreadyout <= 1'b1;
                            hresp <= 1'b0;
                            hrdata <= mem[raddr];
                            raddr <= raddr + 1;
                        end
                        default : begin
                            hreadyout <= 1'b0; //previously it's 1'b1
                            hresp <= 1'b0;
                        end

                    endcase
                end
                default : begin
                    hreadyout <= 1'b0;
                    hresp <= 1'b0;
                    waddr <= waddr;
                    raddr <= raddr;
                end
            endcase
        end
    end


endmodule


// module ahb_slave(
//     input logic hclk,hresetn,
//     input logic [31:0] haddr, hwdata,
//     input logic [2:0] hszie,
//     input logic [1:0] htrans,
//     input logic hwrite, hreadyin,

//     output logic [31:0] hrdata,
//     output logic hreadyout,
//     output logic [1:0] hresp
// );

// logic [31:0] mem [31:0];
// typedef enum logic [1:0] { Idle = 2'b00, Read = 2'b01, Write = 2'b10 } state_r;
// state_r current_state, next_state;

// always_ff @(posedge hclk)
// begin
//     if(!hresetn) current_state <= Idle;
//     else current_state <= next_state;
// end

// always_ff @(posedge hclk) begin
//     if(!hresetn) next_state <= Idle;
//     else begin
//         case(state)
//             Idle: begin
//                 if(hwrite) begin
//                     next_state <= Write;
//                 end else if (!hwrite) begin
//                     next_state <= Read;
//                 end
//             end
//             Read: begin
//                 if(hready) begin
//                     hreadyout <= 1'b1;
//                     hresp <= 2'b00;
//                     hrdata <= mem[haddr];
//                     next_state <= Idle;
//                 end
//             end
//             Write: begin
//                 if(hready) begin
//                     hreadyout <= 1'b1;
//                     hresp <= 2'b00;
//                     mem[haddr] <= hwdata;
//                     next_state <= Idle;
//                 end
//             end
//             default: next_state <= Idle;
//         endcase
//     end
// end

// endmodule
