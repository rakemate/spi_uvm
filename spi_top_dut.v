//-----------SPI TOP DUT-------------//

module top_dut(mclk, reset,load_master,load_slave,read_master,
  read_slave,start,data_in_master,data_in_slave,
  data_out_master,data_out_slave);
  
  input mclk, reset, load_master,load_slave,read_master,
  read_slave,start;
  input [7:0]data_in_master,data_in_slave;
  output [7:0]data_out_master,data_out_slave;
    wire miso,mosi,cs,sclk;
  spi_master s_m(mclk,reset,load_master, read_slave,miso,start,data_in_master,data_out_master,mosi,sclk,cs);
  
  spi_slave s_s(sclk,reset,cs,mosi,miso,data_in_slave,data_out_slave,read_slave,load_slave);
  
`ifndef SPI_UVM_FAST_SIM
  property p1;
    @(posedge mclk)
      disable iff (!reset)
      load_master |-> !read_master;
  endproperty

  property p2;
    @(posedge mclk)
      disable iff (!reset)
      load_slave |-> !read_slave;
  endproperty

  property p3;
    @(posedge mclk)
      disable iff (!reset)
      (!load_master && !read_master) |-> (!load_slave && !read_slave);
  endproperty

  property p4;
    @(posedge mclk)
      disable iff (!reset)
      $fell(load_master) && $fell(load_slave)
      && !$rose(read_master) && !$rose(read_slave)
      |=> ($stable(load_master) && $stable(load_slave) && $stable(read_master) && $stable(read_slave)) [*8];
  endproperty

  assert property (p1)
    else
      $error("MASTER: load implies !read failed");
  assert property (p2)
    else
      $error("SLAVE: load implies !read failed");
  assert property (p3)
    else
      $error("MASTER/SLAVE shift phase coupling failed");
  assert property (p4)
    else
      $error("CONTROL signals unstable during shift");
`endif
    
    
endmodule
