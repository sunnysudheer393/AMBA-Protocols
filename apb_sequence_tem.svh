class apb_sequence_tem extends uvm_sequence_item;
    `uvm_object_utils(apb_sequence_tem)
    bit clk, presetn, transfer;

    rand bit [7:0] apb_write_data;
    rand bit [7:0] apb_write_addr, apb_read_addr;
    rand pwrite;


    bit [7:0] apb_read_data_out;

    bit pslverr, pready;


    constraint reset_1 { presetn dist{0 := 20, 1 := 80;}  }
    constraint read_write { pwrite dist { 1 := 50, 0 := 50}  }

    constraint read_address { apb_read_addr < 8'hFF, apb_read_addr > 0;}

    function new (uvm_component parent = null, string name = "trans");
        super.new(name);
    endfunction
 
endclass
