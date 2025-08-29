module apb_assertions();
logic pclk, presetn;
logic psel, pwakeup, pprot, pnse, pslverr, penable, pwrite, pready;
logic [7:0] paddr, pwdata, prdata;

//written from the APB specifications

assert property (@(posedge pclk) disable iff (presetn) ! $isunknown(psel) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> [*0:$] ! $isunknown(paddr) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> [*0:$] ! $isunknown(pwrite) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> [*0:$] ! $isunknown(pwdata) );

assert property (@(posedge pclk) disable iff (presetn) pready |-> ##1 !(penable) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(paddr) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(pwrite) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(psel) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(penable) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(pwdata) );

assert property (@(posedge pclk) disable iff (presetn) !pwrite |-> !pstrb );

assert property (@(posedge pclk) disable iff (presetn) (psel && !pwrite && $stable(paddr) && pready) |-> ##[0:$] $stable(prdata));

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! ($isunknown(paddr) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(psel) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(pwrite) );

assert property (@(posedge pclk) disable iff (presetn) (penable && !pready) |-> ##[2:$] ! $isunknown(penable) );

assert property (@(posedge pclk) disable iff (presetn) (psel && penable && pready) |-> $stable(pslverr) && $stable(prdata));

assert property (@(posedge pclk) disable iff (presetn) (psel && penable) |-> !$isunknown(pready));

sequence second;
    if(pslverr) pwdata || prdata == $isunknown();
    else !$isunknown(pwdata || prdata);
endsequence

sequence first;
    (psel && penable && pready);
endsequence

assert property (@(posedge pclk) disable iff(presetn) first |-> second );






//Written from the validity check from the APB file

assert property (@(posedge pclk) disable iff (presetn) ! $isunknown(psel) );

assert property (@(posedge pclk) disable iff (presetn) ! $isunknown(pwakeup) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(paddr) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(pprot) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(pnse) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(penable) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(pwrite) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(pstrb) );

assert property (@(posedge pclk) disable iff (presetn) psel |-> !$isunknown(pwdata) );

assert property (@(posedge pclk) disable iff (presetn) (psel && penable) |-> !$isunknown(pready) );

assert property (@(posedge pclk) disable iff (presetn) (psel && penable && pready) |-> !$isunknown(prdata) );

assert property (@(posedge pclk) disable iff (presetn) (psel && penable && pready) |-> !$isunknown(pslverr) );

endmodule
