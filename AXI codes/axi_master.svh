/*
module axi_master #(parameter Width = 32) (
    input logic ACLK, ARESETN,

    //Write Req/Addr channel === ready is input from slave
    input logic AWREADY,
    output logic AWVALID,
    output logic [Width-1:0] AWADDR,

    //Write Data channel
    input logic WREADY,
    output logic WVALID,
    output logic [Width-1:0] WDATA,
    output logic [(Width/8)-1:0] WSTRB,

    //Write Response channel
    input logic BVALID,
    //input logic [1:0] BRESP,
    output logic BREADY,

    //Read Req/Addr channel
    input logic ARREADY,
    output logic [Width-1:0] ARADDR,
    output logic ARVALID,

    //Read Data channel
    input logic RVALID,
    input logic [Width-1:0] RDATA,
    //input logic [1:0] RRESP,
    output logic RREADY,


    //other input signals to masteer which transfers to subordinate
    //raddr,waddr,wdata,rdata and wstrb signals
    input logic [Width-1:0] araddr, awaddr,wdata,
    input logic [(Width/8)-1:0] wstrb,
    output logic [Width-1:0] data_out
);

//create a memory of 4096 bytes or 4KB
//logic [7:0] data_mem[4095:0];


////////////////////////////////WRITE ADDRESS CHANNEL LOGIC//////////////////////////////
typedef enum logic [1:0] {WA_IDLE_M= 2'b00, WA_VALID_M= 2'b01, WA_ADDR_M= 2'b10, WA_WAIT_M=2'b11} WA_STATE;
WA_STATE WA_STATE_M, WA_NEXT_STATE_M;

//sequential logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) WA_STATE_M <= WA_IDLE_M;
    else WA_STATE_M <= WA_NEXT_STATE_M;
end

//Next state logic
always @(*) begin
    case(WA_STATE_M)
    WA_IDLE_M: begin
        if(awaddr > 32'h0) WA_NEXT_STATE_M = WA_VALID_M;
        else WA_NEXT_STATE_M = WA_IDLE_M;
    end
    WA_VALID_M: begin
        if(AWREADY) WA_NEXT_STATE_M = WA_ADDR_M;
        else WA_NEXT_STATE_M = WA_VALID_M;
    end
    WA_ADDR_M: begin
        WA_NEXT_STATE_M = WA_WAIT_M;
    end
    WA_WAIT_M: begin
        if(BVALID) WA_NEXT_STATE_M = WA_IDLE_M;
        else WA_NEXT_STATE_M = WA_WAIT_M;
    end
    default: WA_NEXT_STATE_M = WA_IDLE_M;

    endcase
end

//Output logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) AWVALID <= 1'b0;
    else
        case(WA_NEXT_STATE_M)
            WA_IDLE_M: AWVALID <= 1'b0;
            WA_VALID_M: begin
                AWVALID <= 1'b1;
                AWADDR <= awaddr;
            end
            WA_ADDR_M: AWVALID <= 1'b0;
            WA_WAIT_M: AWVALID <= 1'b0;
            default: AWVALID <= 1'b0;
        endcase
end


///////////////////////////////////WRITE DATA CHANNEL///////////////////////////////
typedef enum logic [1:0] {W_IDLE_M= 2'b00, W_GET_M= 2'b01, W_WAIT_M= 2'b10, W_TRANS_M= 2'b11} W_STATE;
W_STATE W_STATE_M, W_NEXT_STATE_M;

//sequential
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) W_STATE_M <= W_IDLE_M;
    else W_STATE_M <= W_NEXT_STATE_M;
end

//next state logic
always @(*) begin
    case(W_STATE_M)
    W_IDLE_M: W_NEXT_STATE_M = W_GET_M;
    W_GET_M: begin
        if(AWREADY) W_NEXT_STATE_M = W_WAIT_M;
        else W_NEXT_STATE_M = W_GET_M;
    end
    W_WAIT_M: begin
        if(WREADY) W_NEXT_STATE_M = W_TRANS_M;
        else W_NEXT_STATE_M = W_WAIT_M;
    end
    W_TRANS_M:W_NEXT_STATE_M = W_IDLE_M;
    default: W_NEXT_STATE_M = W_IDLE_M;

    endcase
end

//output logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) WVALID <= 1'b0;
    else
        case(W_NEXT_STATE_M)
            W_IDLE_M: WVALID <= 1'b0;
            W_GET_M: begin
                WVALID <= 1'b0;
                //WSTRB <= wstrb;
                //WDATA <= wdata;
            end
            W_WAIT_M: begin
                WVALID <= 1'b1;
                WSTRB <= wstrb;
                WDATA <= wdata;
            end
            W_TRANS_M: WVALID <= 1'b0;
            default: WVALID <= 1'b0;
        endcase
end


///////////////////////////////////WRITE RESPONSE CHANNEL////////////////////////////
typedef enum logic [1:0] {B_IDLE_M= 2'b00, B_START_M= 2'b01, B_READY_M= 2'b10} B_STATE;
B_STATE B_STATE_M, B_NEXT_STATE_M;

//sequential logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) B_STATE_M <= B_IDLE_M;
    else B_STATE_M <= B_NEXT_STATE_M;
end

//next state logic
always @(*) begin
    case(B_STATE_M)
        B_IDLE_M: begin
            if(AWREADY) B_NEXT_STATE_M = B_START_M;
            else B_NEXT_STATE_M = B_IDLE_M;
        end
        B_START_M: begin
            if(BVALID) B_NEXT_STATE_M = B_READY_M;
            else B_NEXT_STATE_M = B_START_M;
        end
        B_READY_M: B_NEXT_STATE_M = B_IDLE_M;
        default: B_NEXT_STATE_M = B_IDLE_M;
    endcase
end

//output logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) BREADY <= 1'b0;
    else
        case(B_NEXT_STATE_M)
            B_IDLE_M: BREADY <= 1'b0;
            B_START_M: BREADY <= 1'b1;
            B_READY_M: BREADY <= 1'b0;
            default: BREADY <= 1'b0;
        endcase
end

/////////////////////////////////////Read Address Channel/////////////////////////////////////////

typedef enum logic {RA_IDLE_M= 1'b0, RA_VALID_M= 1'b1} RA_STATE;
RA_STATE RA_STATE_M, RA_NEXT_STATE_M;

//sequential logic or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN)RA_STATE_M <= RA_IDLE_M;
    else RA_STATE_M <= RA_NEXT_STATE_M;
end

//next state logic
always @(*) begin
    case(RA_STATE_M)
        RA_IDLE_M: begin
            if(araddr > 32'h0) begin
                RA_NEXT_STATE_M = RA_VALID_M;
            end else RA_NEXT_STATE_M = RA_VALID_M;
        end
        RA_VALID_M: begin
            if(ARREADY) RA_NEXT_STATE_M = RA_IDLE_M;
            else RA_NEXT_STATE_M = RA_VALID_M;
        end
        default: RA_NEXT_STATE_M = RA_IDLE_M;
    endcase
end

//output logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) ARVALID <= 1'b0;
    else
        case(RA_NEXT_STATE_M)
            RA_IDLE_M: ARVALID <= 1'b0;
            RA_VALID_M: begin
                ARVALID <= 1'b1;
                ARADDR <= araddr;
            end
            default: ARVALID <= 1'b0;
        endcase
end

/////////////////////////////////////Read Data channel///////////////////////////////////

typedef enum logic {R_IDLE_M= 1'b0,R_READY_M= 1'b1} R_STATE;
R_STATE R_STATE_M, R_NEXT_STATE_M;

//sequential or current state logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) R_STATE_M <= R_IDLE_M;
    else R_STATE_M <= R_NEXT_STATE_M;
end

//next state logic
always @(*) begin
    case(R_NEXT_STATE_M)
        R_IDLE_M: begin
            if(ARREADY && ARADDR!=AWADDR) R_NEXT_STATE_M = R_READY_M;
            else R_NEXT_STATE_M = R_IDLE_M;
        end
        R_READY_M: begin
            if(RVALID) R_NEXT_STATE_M = R_IDLE_M;
            else R_NEXT_STATE_M = R_READY_M;
        end
        default:R_NEXT_STATE_M = R_IDLE_M;
    endcase
end

//output logic
always_ff @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) RREADY <= 1'b0;
    else
        case(R_NEXT_STATE_M)
            R_IDLE_M:
                RREADY <= 1'b0;
            R_READY_M: begin
                RREADY <= 1'b1;
                data_out <= RDATA;
            end
            default: RREADY <= 1'b0;
        endcase
end


endmodule

*/


module axi_lite_master #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic                clk,
  input  logic                rst_n,

  // Write Address Channel
  output logic [ADDR_WIDTH-1:0] awaddr,
  output logic                  awvalid,
  input  logic                  awready,

  // Write Data Channel
  output logic [DATA_WIDTH-1:0] wdata,
  output logic                  wvalid,
  input  logic                  wready,

  // Write Response Channel
  input  logic [1:0]            bresp,
  input  logic                  bvalid,
  output logic                  bready,

  // Read Address Channel
  output logic [ADDR_WIDTH-1:0] araddr,
  output logic                  arvalid,
  input  logic                  arready,

  // Read Data Channel
  input  logic [DATA_WIDTH-1:0] rdata,
  input  logic [1:0]            rresp,
  input  logic                  rvalid,
  output logic                  rready,

  // Control signals
  input  logic                  start_write,
  input  logic                  start_read,
  input  logic [ADDR_WIDTH-1:0] addr_in,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic                  done_write,
  output logic                  done_read
);

  typedef enum logic [1:0] {IDLE, WRITE, READ} master_state_t;
  master_state_t state, next_state;

  logic [1:0] write_substate=0;
  logic [1:0] read_substate=0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= next_state;
  end

  always_comb begin
    // defaults
    awvalid = 0;
    wvalid  = 0;
    bready  = 0;
    arvalid = 0;
    rready  = 0;
    awaddr  = addr_in;
    araddr  = addr_in;
    wdata   = data_in;
    done_write = 0;
    done_read  = 0;
    data_out = 0;

    next_state = state;

    case (state)
      IDLE: begin
        if (start_write) next_state = WRITE;
        else if (start_read) next_state = READ;
      end

      WRITE: begin
        case (write_substate)
          2'd0: begin awvalid = 1; if (awready) write_substate = 2'd1; end
          2'd1: begin wvalid = 1; if (wready) write_substate = 2'd2; end
          2'd2: begin bready = 1; if (bvalid) begin done_write = 1; next_state = IDLE; end end
        endcase
      end

      READ: begin
        case (read_substate)
          2'd0: begin arvalid = 1; if (arready) read_substate = 2'd1; end
          2'd1: begin rready = 1; if (rvalid) begin data_out = rdata; done_read = 1; next_state = IDLE; end end
        endcase
      end
    endcase
  end

//   always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       write_substate <= 0;
//       read_substate  <= 0;
//     end else begin
//       if (state == IDLE) begin
//         write_substate <= 0;
//         read_substate  <= 0;
//       end
//     end
//   end

endmodule

