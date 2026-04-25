






//SPI Scoreboard

class spi_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(spi_scoreboard)
  
  //---------------------------------------
  //Analysis import declaration
  //---------------------------------------
  uvm_analysis_imp#(spi_seq_item, spi_scoreboard) mon_imp;
  
  spi_seq_item trans;
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
    mon_imp = new("mon_imp", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  //---------------------------------------
  //Write function implemetation
  //---------------------------------------
  function void write(spi_seq_item trans);
    `uvm_info("SPI_SCOREBOARD", "------ RESULT ------", UVM_MEDIUM)
    `uvm_info("SPI_SCOREBOARD", $sformatf("data_in_master:%0h data_in_slave:%0h", trans.data_in_master, trans.data_in_slave), UVM_MEDIUM)
    `uvm_info("SPI_SCOREBOARD", $sformatf("data_out_master:%0h data_out_slave:%0h", trans.data_out_master, trans.data_out_slave), UVM_MEDIUM)
    if (trans.data_in_master == trans.data_out_slave)
      `uvm_info("SPI_SCOREBOARD", "MOSI path: master -> slave PASS", UVM_MEDIUM)
    else
      `uvm_error("SPI_SCOREBOARD", "MOSI path: master -> slave FAIL")
    if (trans.data_in_slave == trans.data_out_master)
      `uvm_info("SPI_SCOREBOARD", "MISO path: slave -> master PASS", UVM_MEDIUM)
    else
      `uvm_error("SPI_SCOREBOARD", "MISO path: slave -> master FAIL")
  endfunction 
        
endclass
        
