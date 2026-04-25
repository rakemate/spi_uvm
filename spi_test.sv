
//SPI Test

class spi_test extends uvm_test;
  
  spi_environment env;
  
  virtual spi_interface vif;
  
  `uvm_component_utils(spi_test)
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------
  //Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env=spi_environment::type_id::create("env", this);
    uvm_config_db#(virtual spi_interface)::set(this, "env", "vif", vif);
    
    if(! uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif)) 
      begin
        `uvm_error("build_phase","Test virtual interface failed")
      end
  endfunction
  
  //---------------------------------------
  //Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    spi_sequence spi_seq;
    spi_seq = spi_sequence::type_id::create("spi_seq",this);
    phase.raise_objection( this, "Starting spi_base_seqin main phase" );
    $display("%t Starting sequence spi_seq run_phase",$time);
    spi_seq.start(env.agt.seq);
    #100ns;
    phase.drop_objection( this , "Finished spi_seq in main phase" );
  endtask
  
endclass

class spi_reset_test extends spi_test;

  `uvm_component_utils(spi_reset_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    spi_sequence pre_reset_seq;
    spi_sequence post_reset_seq;

    phase.raise_objection(this, "Starting spi_reset_test run phase");

    pre_reset_seq = spi_sequence::type_id::create("pre_reset_seq", this);
    post_reset_seq = spi_sequence::type_id::create("post_reset_seq", this);

    $display("%t Starting pre-reset SPI traffic", $time);
    pre_reset_seq.start(env.agt.seq);

    @(posedge vif.mclk);
    vif.start <= 0;
    vif.load_master <= 0;
    vif.load_slave <= 0;
    vif.read_master <= 0;
    vif.read_slave <= 0;
    vif.data_in_master <= '0;
    vif.data_in_slave <= '0;
    vif.reset <= 0;

    repeat (2) @(posedge vif.mclk);

    if ((vif.data_out_master !== 8'h00) || (vif.data_out_slave !== 8'h00)) begin
      `uvm_error("spi_reset_test", $sformatf("Reset did not clear outputs: master=%0h slave=%0h", vif.data_out_master, vif.data_out_slave))
    end

    vif.reset <= 1;
    @(posedge vif.mclk);

    $display("%t Starting post-reset SPI traffic", $time);
    post_reset_seq.start(env.agt.seq);

    #100ns;
    phase.drop_objection(this, "Finished spi_reset_test run phase");
  endtask

endclass
