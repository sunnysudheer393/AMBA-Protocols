module deocder(
    input [1:0] sel,

    output logic hsel_1,
    output logic hsel_2,
    output logic hsel_3,
    output logic hsel_4
);

always @(*) begin
    hsel_1 = 1'b0;
    hsel_2 = 1'b0;
    hsel_3 = 1'b0;
    hsel_4 = 1'b0;
    case(sel)
        2'b00 : begin // select slave 1
            hsel_1 = 1'b1;
        end
        2'b01 : begin //select slave 2
            hsel_2 = 1'b1;
        end
        2'b10 : begin //select slave 3
            hsel_3 = 1'b1;
        end
        2'b11 : begin //select slave 4
            hsel_4 = 1'b1;
        end
        default : begin
            hsel_1 = 1'b0;
            hsel_2 = 1'b0;
            hsel_3 = 1'b0;
            hsel_4 = 1'b0;
        end
    endcase
end
endmodule