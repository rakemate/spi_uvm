
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

// Deterministic beats for master/slave handshake (parallel load, shared shift, dual read).
class spi_handshake_sequence extends uvm_sequence#(spi_seq_item);

  `uvm_object_utils(spi_handshake_sequence)

  function new(string name = "spi_handshake_sequence");
    super.new(name);
  endfunction

  task body();
    spi_seq_item seq;
    typedef struct packed {
      bit [7:0] dm;
      bit [7:0] ds;
    } beat_t;

    beat_t beats[$];

    beats.push_back('{8'h00, 8'hFF});
    beats.push_back('{8'hFF, 8'h00});
    beats.push_back('{8'hAA, 8'h55});
    beats.push_back('{8'h55, 8'hAA});
    beats.push_back('{8'h12, 8'h34});
    beats.push_back('{8'h34, 8'h12});

    foreach (beats[i]) begin
      seq = new($sformatf("handshake_beat_%0d", i));
      start_item(seq);
      seq.data_in_master = beats[i].dm;
      seq.data_in_slave = beats[i].ds;
      finish_item(seq);
    end
  endtask

endclass
