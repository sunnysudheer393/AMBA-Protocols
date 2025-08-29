/*
module axi_slave #(parameter Width = 32) (
    input logic ACLK, ARESETN,
    //signals output in master are input in slave
    //signlas input in master are output in slave
     //Write Req/Addr channel === ready is output from slave
    output logic AWREADY,
    input logic AWVALID,
    input logic [Width-1:0] AWADDR,

    //Write Data channel
    output logic WREADY,
    input logic WVALID,
    input logic [Width-1:0] WDATA,
    input logic [(Width/8)-1:0] WSTRB,

    //Write Response channel
    output logic BVALID,
    output logic [1:0] BRESP,
    input logic BREADY,

    //Read Req/Addr channel
    output logic ARREADY,
    input logic [Width-1:0] ARADDR,
    input logic ARVALID,

    //Read Data channel
    output logic RVALID,
    output logic [Width-1:0] RDATA,
    input logic RREADY
);
//slave memory, write and read addresses
logic [7:0] slave_mem [7:0];
logic[Width-1:0] AWADDR_reg;
logic [Width-1:0] ARADDR_reg;

//////////////////////Write address channel/////////////////////
typedef enum logic [1:0] {WA_IDLE_S= 2'b00,WA_START_S= 2'b01, WA_READY_S= 2'b10} WA_STATE;
WA_STATE WA_STATE_S, WA_NEXT_STATE_S;

//sequential or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) WA_STATE_S <= WA_IDLE_S;
    else WA_STATE_S <= WA_NEXT_STATE_S;
end

//nextstate logic
always @(*) begin
    case(WA_NEXT_STATE_S)
        WA_IDLE_S: begin
            if(AWVALID) WA_NEXT_STATE_S = WA_START_S;
            else WA_NEXT_STATE_S = WA_IDLE_S;
        end
        WA_START_S: WA_NEXT_STATE_S = WA_READY_S;
        WA_READY_S: WA_NEXT_STATE_S = WA_IDLE_S;
        default: WA_NEXT_STATE_S = WA_IDLE_S;
    endcase
end

//input logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) AWREADY <= 1'b0;
    else
        case(WA_NEXT_STATE_S)
            WA_IDLE_S: AWREADY <= 1'b0;
            WA_START_S: begin
                AWREADY <= 1'b1;
                AWADDR_reg <= AWADDR;
            end
            WA_READY_S: AWREADY <= 1'b0;
            default: AWREADY <= 1'b0;
        endcase
end

///////////////////////////////////////Write Data Channel///////////////////////////////
typedef enum logic [1:0] {W_IDLE_S= 2'b00, W_START_S= 2'b01, W_WAIT_S= 2'b10, W_TRAN_S= 2'b11} W_STATE;
W_STATE W_STATE_S, W_NEXT_STATE_S;

//sequential or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) W_STATE_S <= W_IDLE_S;
    else W_STATE_S <= W_NEXT_STATE_S;
end

//next state logic
always @(*) begin
    case(W_STATE_S)
        W_IDLE_S: W_NEXT_STATE_S = W_START_S;
        W_START_S: begin
            if(AWREADY) W_NEXT_STATE_S = W_WAIT_S;
            else W_NEXT_STATE_S = W_START_S;
        end
        W_WAIT_S: begin
            if(WVALID) W_NEXT_STATE_S = W_TRAN_S;
            else W_NEXT_STATE_S = W_WAIT_S;
        end
        W_TRAN_S: W_NEXT_STATE_S = W_IDLE_S;
        default: W_NEXT_STATE_S = W_IDLE_S;
    endcase
end

//input logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
        WREADY <= 1'b0;
        for(int i=0;i<8;i++) slave_mem[i] <= 8'b0;//set all slave memory to all 0's
    end
    else
        case(W_NEXT_STATE_S)
            W_IDLE_S: WREADY <= 1'b0;
            W_START_S: WREADY <= 1'b0;
            W_WAIT_S: WREADY <= 1'b0;
            W_TRAN_S: begin
                WREADY <= 1'b1;
                case(WSTRB)//here we are storing 8 values of 8 bits each so we need 16 combinations of strb
                    4'b0001: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                    end
                    4'b0010: begin
                        slave_mem[AWADDR_reg] <= WDATA[15:8];
                    end
                    4'b0100: begin
                        slave_mem[AWADDR_reg] <= WDATA[23:16];
                    end
                    4'b1000: begin
                        slave_mem[AWADDR_reg] <= WDATA[31:24];
                    end
                    4'b0011: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[15:8];
                    end
                    4'b0101: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[23:16];
                    end
                    4'b1001: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[31:24];
                    end
                    4'b0110: begin
                        slave_mem[AWADDR_reg] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+1] <= WDATA[23:16];
                    end
                    4'b1010: begin
                        slave_mem[AWADDR_reg] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+1] <= WDATA[31:24];
                    end
                    4'b1100: begin
                        slave_mem[AWADDR_reg] <= WDATA[23:16];
                        slave_mem[AWADDR_reg+1] <= WDATA[31:24];
                    end
                    4'b0111: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+2] <= WDATA[23:16];
                    end
                    4'b1110: begin
                        slave_mem[AWADDR_reg] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+1] <= WDATA[23:16];
                        slave_mem[AWADDR_reg+2] <= WDATA[31:24];
                    end
                    4'b1011: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+2] <= WDATA[31:24];
                    end
                    4'b1101: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[23:16];
                        slave_mem[AWADDR_reg+2] <= WDATA[31:24];
                    end
                    4'b1111: begin
                        slave_mem[AWADDR_reg] <= WDATA[7:0];
                        slave_mem[AWADDR_reg+1] <= WDATA[15:8];
                        slave_mem[AWADDR_reg+2] <= WDATA[23:16];
                        slave_mem[AWADDR_reg+3] <= WDATA[31:24];
                    end
                    default: begin
                    end
                endcase
            end
            default: WREADY <= 1'b0;
        endcase
end

////////////////////////////////////Write Response Channel/////////////////////////////////
typedef enum logic [1:0] {B_IDLE_S= 2'b00, B_START_S= 2'b01, B_READY_S= 2'b10} B_STATE;
B_STATE B_STATE_S, B_NEXT_STATE_S;

//sequential or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) B_STATE_S <= B_IDLE_S;
    else B_STATE_S <= B_NEXT_STATE_S;
end

//next state logic
always @(*) begin
    case(B_NEXT_STATE_S)
        B_IDLE_S: begin
            if(WREADY) B_NEXT_STATE_S = B_START_S;
            else B_NEXT_STATE_S = B_IDLE_S;
        end
        B_START_S: B_NEXT_STATE_S = B_READY_S;
        B_READY_S: B_NEXT_STATE_S = B_IDLE_S;
        default: B_NEXT_STATE_S = B_IDLE_S;
    endcase
end

//input logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
        BVALID <= 1'b0;
        BRESP <= 2'b00;
    end
    else begin
        case(B_NEXT_STATE_S)
            B_IDLE_S: begin
                BVALID <= 1'b0;
                BRESP <= 2'b00;
            end
            B_START_S: begin
                BVALID <= 1'b1;
                BRESP <= 2'b00;
            end
            B_READY_S: begin
                BVALID <= 1'b0;
                BRESP <= 2'b00;
            end
            default: begin
                BVALID <= 1'b0;
                BRESP <= 2'b00;
            end
        endcase
    end
end


////////////////////////////////Read Address Channel///////////////////////////////

typedef enum logic {RA_IDLE_S= 1'b0, RA_READY_S= 1'b1} RA_STATE;
RA_STATE RA_STATE_S, RA_NEXT_STATE_S;

//sequential or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) RA_STATE_S <= RA_IDLE_S;
    else RA_STATE_S <= RA_NEXT_STATE_S;
end

//next state logic
always @(*) begin
    case(RA_STATE_S)
        RA_IDLE_S: begin
            if(ARVALID) RA_NEXT_STATE_S = RA_READY_S;
            else RA_NEXT_STATE_S = RA_IDLE_S;
        end
        RA_READY_S: RA_NEXT_STATE_S = RA_IDLE_S;
        default: RA_NEXT_STATE_S = RA_IDLE_S;
    endcase
end

//input logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) ARREADY <= 1'b0;
    else
        case(RA_NEXT_STATE_S)
            RA_IDLE_S: ARREADY <= 1'b0;
            RA_READY_S: begin
                ARREADY <= 1'b0;
                ARADDR_reg <= ARADDR;
            end
            default: ARREADY <= 1'b0;
        endcase
end


///////////////////////////////////////Read Data Channel///////////////////////////////
typedef enum logic [1:0] {R_IDLE_S=2'b00, R_START_S= 2'b01, R_VALID_S= 2'b10} R_STATE;
R_STATE R_STATE_S, R_NEXT_STATE_S;

//sequential or currrent state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) R_STATE_S <= R_IDLE_S;
    else R_STATE_S <= R_NEXT_STATE_S;
end

//next state logic
always @(*) begin
    case(R_STATE_S)
        R_IDLE_S: begin
            if(ARREADY) R_NEXT_STATE_S = R_START_S;
            else R_NEXT_STATE_S = R_IDLE_S;
        end
        R_START_S: R_NEXT_STATE_S = R_VALID_S;
        R_VALID_S: begin
            if(RREADY) R_NEXT_STATE_S = R_IDLE_S;
            else R_NEXT_STATE_S = R_VALID_S;
        end
        default: R_NEXT_STATE_S = R_IDLE_S;
    endcase
end

//input logic
always_ff @(posedge ACLK or ARESETN) begin
    if(!ARESETN) RVALID <= 1'b0;
    else
        RDATA <= '0;
        case(R_NEXT_STATE_S)
            R_IDLE_S: RVALID <= 1'b0;
            R_START_S: RVALID <= 1'b0;
            R_VALID_S: begin
                RVALID <= 1'b1;
                case(WSTRB)
                    4'b0001: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                    end
                    4'b0010: begin
                        RDATA[15:8] <= slave_mem[ARADDR_reg];
                    end
                    4'b0100: begin
                        RDATA[23:16] <= slave_mem[ARADDR_reg];
                    end
                    4'b1000: begin
                        RDATA[31:24] <= slave_mem[ARADDR_reg];
                    end
                    4'b0011: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[15:8] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b0101: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b1001: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b0110: begin
                        RDATA[15:8] <= slave_mem[ARADDR_reg];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b1010: begin
                        RDATA[15:8] <= slave_mem[ARADDR_reg];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b1100: begin
                        RDATA[23:16] <= slave_mem[ARADDR_reg];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+1];
                    end
                    4'b0111: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[15:8] <= slave_mem[ARADDR_reg+1];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+2];
                    end
                    4'b1110: begin
                        RDATA[15:8] <= slave_mem[ARADDR_reg];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+1];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+2];
                    end
                    4'b1011: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[15:8] <= slave_mem[ARADDR_reg+1];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+2];
                    end
                    4'b1101: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+1];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+2];
                    end
                    4'b1111: begin
                        RDATA[7:0] <= slave_mem[ARADDR_reg];
                        RDATA[15:8] <= slave_mem[ARADDR_reg+1];
                        RDATA[23:16] <= slave_mem[ARADDR_reg+2];
                        RDATA[31:24] <= slave_mem[ARADDR_reg+3];
                    end
                    default: begin
                    end
                endcase
            end
            default: RVALID <= 1'b0;
        endcase
end

endmodule
*/


module axi_lite_slave #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic                clk,
  input  logic                rst_n,

  // Write Address Channel
  input  logic [ADDR_WIDTH-1:0] awaddr,
  input  logic                  awvalid,
  output logic                  awready,

  // Write Data Channel
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic                  wvalid,
  output logic                  wready,

  // Write Response Channel
  output logic [1:0]            bresp,
  output logic                  bvalid,
  input  logic                  bready,

  // Read Address Channel
  input  logic [ADDR_WIDTH-1:0] araddr,
  input  logic                  arvalid,
  output logic                  arready,

  // Read Data Channel
  output logic [DATA_WIDTH-1:0] rdata,
  output logic [1:0]            rresp,
  output logic                  rvalid,
  input  logic                  rready
);

  logic [DATA_WIDTH-1:0] mem [0:255];
  logic aw_hs, w_hs;
  logic ar_hs;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      awready <= 1;
      wready  <= 1;
      bvalid  <= 0;
      arready <= 1;
      rvalid  <= 0;
    end else begin
      // WRITE CHANNEL
      if (awvalid && awready) begin
        aw_hs <= 1;
        awready <= 0;
      end

      if (wvalid && wready) begin
        w_hs <= 1;
        wready <= 0;
      end

      if (aw_hs && w_hs) begin
        mem[awaddr[7:0]] <= wdata;
        bresp <= 2'b00;
        bvalid <= 1;
        aw_hs <= 0;
        w_hs <= 0;
      end

      if (bvalid && bready) begin
        bvalid <= 0;
        awready <= 1;
        wready <= 1;
      end

      // READ CHANNEL
      if (arvalid && arready) begin
        
        rresp <= 2'b00;
        rvalid <= 1;
        arready <= 0;
      end

      if (rvalid && rready) begin
        rdata <= mem[araddr[7:0]];
        rvalid <= 0;
        arready <= 1;
      end
    end
  end

endmodule
