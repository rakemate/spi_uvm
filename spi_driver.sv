// SPI Driver — bit-serial exchange through shared shift path (master MOSI / slave MISO).
// Protocol (see spi_master.v / spi_slave.v):
//   1) While start=1: one cycle with load_*=1 latches TX data into both shift registers.
//   2) load_* deasserted for SPI_BIT_CYCLES posedges of mclk (sclk): 8 data bits + one
//      settle cycle so the last shifted bit is stable before read strobes.
//   3) read_* asserted one cycle so data_out_* registers capture completed shift regs.
//   4) start deasserted for one idle cycle before the next transaction (clean handoff).

`define DRIV_IF vif.DRIVER.driver_cb

class spi_driver extends uvm_driver #(spi_seq_item);

  `uvm_component_utils(spi_driver)

  virtual spi_interface vif;

  // Match monitor/driver timing: 8 shifts + 1 guard cycle before read.
  localparam int unsigned SPI_BIT_CYCLES = 9;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif)) begin
      `uvm_error("build_phase", "driver virtual interface failed");
    end
  endfunction

  // Drive all control/data to a known idle state (used after each beat).
  task automatic drive_idle();
    `DRIV_IF.start <= 1'b0;
    `DRIV_IF.load_master <= 1'b0;
    `DRIV_IF.load_slave <= 1'b0;
    `DRIV_IF.read_master <= 1'b0;
    `DRIV_IF.read_slave <= 1'b0;
    `DRIV_IF.data_in_master <= '0;
    `DRIV_IF.data_in_slave <= '0;
  endtask

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // Align to clocking block: first action on a posedge after reset/release.
    @(posedge vif.DRIVER.mclk);
    drive_idle();

    forever begin
      spi_seq_item trans;
      seq_item_port.get_next_item(trans);
      `uvm_info("SPI_DRIVER", trans.convert2string(), UVM_HIGH)

      // --- Phase A: latch parallel data into both shifters (start must be high). ---
      @(posedge vif.DRIVER.mclk);
      `DRIV_IF.start <= 1'b1;
      `DRIV_IF.load_master <= 1'b1;
      `DRIV_IF.load_slave <= 1'b1;
      `DRIV_IF.read_master <= 1'b0;
      `DRIV_IF.read_slave <= 1'b0;
      `DRIV_IF.data_in_master <= trans.data_in_master;
      `DRIV_IF.data_in_slave <= trans.data_in_slave;

      // --- Phase B: leave load, run SPI_BIT_CYCLES shift clocks with stable controls. ---
      @(posedge vif.DRIVER.mclk);
      `DRIV_IF.load_master <= 1'b0;
      `DRIV_IF.load_slave <= 1'b0;
      repeat (SPI_BIT_CYCLES) @(posedge vif.DRIVER.mclk);

      // --- Phase C: pulse read to snapshot shift registers onto data_out_* buses. ---
      `DRIV_IF.read_master <= 1'b1;
      `DRIV_IF.read_slave <= 1'b1;
      @(posedge vif.DRIVER.mclk);
      trans.data_out_master = `DRIV_IF.data_out_master;
      trans.data_out_slave = `DRIV_IF.data_out_slave;

      // --- Phase D: drop read then idle start so DUT does not continue shifting. ---
      `DRIV_IF.read_master <= 1'b0;
      `DRIV_IF.read_slave <= 1'b0;
      @(posedge vif.DRIVER.mclk);
      drive_idle();

      seq_item_port.item_done();
    end
  endtask

endclass
  
  
  
  
  
    
