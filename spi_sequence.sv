
//SPI Sequence

class spi_sequence extends uvm_sequence#(spi_seq_item);
  
  `uvm_object_utils(spi_sequence)
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "spi_sequence");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //Randomizing sequence item
  //---------------------------------------
  task body();
    spi_seq_item seq;
`ifdef SPI_UVM_FAST_SIM
    repeat (3) begin
`else
    repeat (10) begin
`endif
      seq = new();
      start_item(seq);
      assert (seq.randomize());
      finish_item(seq);
    end
  endtask
    
endclass
