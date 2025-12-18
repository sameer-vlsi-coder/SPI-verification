`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////////////

typedef enum bit [1:0]   {readd = 0, writed = 1, rstdut = 2} oper_mode;


class transaction extends uvm_sequence_item;
  
    rand oper_mode   op;
         logic wr;
         logic rst;
    randc logic [7:0] addr;
    randc logic [7:0] din;
         logic [7:0] dout; 
         logic done;
         logic err;
  

        `uvm_object_utils_begin(transaction)
        `uvm_field_int (wr,UVM_ALL_ON)
        `uvm_field_int (rst,UVM_ALL_ON)
        `uvm_field_int (addr,UVM_ALL_ON)
        `uvm_field_int (din,UVM_ALL_ON)
        `uvm_field_int (dout,UVM_ALL_ON)
        `uvm_field_int (done,UVM_ALL_ON)
        `uvm_field_int (err,UVM_ALL_ON)
        `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
        `uvm_object_utils_end
  
  constraint addr_c { addr <= 31; }
  constraint addr_c_err { addr > 31; }

  function new(string name = "transaction");
    super.new(name);
  endfunction

endclass : transaction


///////////////////////////////////////////////////////////////////////


///////////////////write seq
class write_data extends uvm_sequence#(transaction);
  `uvm_object_utils(write_data)
  
  transaction tr;

  function new(string name = "write_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        tr.rst= 1'b0;
        tr.wr = 1'b1; 
        finish_item(tr);
      end
  endtask
  

endclass
//////////////////////////////////////////////////////////


class write_err extends uvm_sequence#(transaction);
  `uvm_object_utils(write_err)
  
  transaction tr;

  function new(string name = "write_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c_err.constraint_mode(1);
        tr.addr_c.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        tr.rst= 1'b0;
        tr.wr = 1'b1;
        finish_item(tr);
      end
  endtask
  

endclass

///////////////////////////////////////////////////////////////

class read_data extends uvm_sequence#(transaction);
  `uvm_object_utils(read_data)
  
  transaction tr;

  function new(string name = "read_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        tr.rst= 1'b0;
        tr.wr = 1'b0;
        finish_item(tr);
      end
  endtask
  

endclass
/////////////////////////////////////////////////////////////////////

class read_err extends uvm_sequence#(transaction);
  `uvm_object_utils(read_err)
  
  transaction tr;

  function new(string name = "read_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(0);
        tr.addr_c_err.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        tr.rst= 1'b0;
        tr.wr = 1'b0;
        finish_item(tr);
      end
  endtask
  

endclass
/////////////////////////////////////////////////////////////////

class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)
  
  transaction tr;

  function new(string name = "reset_dut");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = rstdut;
        tr.rst= 1'b1;
        tr.wr = 1'b0;
        tr.addr= 'h0;
        tr.din = 'h0;
        finish_item(tr);
      end
  endtask
  

endclass
////////////////////////////////////////////////////////////



class writeb_readb extends uvm_sequence#(transaction);
  `uvm_object_utils(writeb_readb)
  
  transaction tr;

  function new(string name = "writeb_readb");
    super.new(name);
  endfunction
  
  virtual task body();
     
    repeat(10)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        tr.rst= 1'b0;
        tr.wr = 1'b1;
        finish_item(tr);  
      end
        
    repeat(10)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        tr.rst= 1'b0;
        tr.wr = 1'b0;
        finish_item(tr);
      end   
    
  endtask
  

endclass



////////////////////////////////////////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  virtual spi_i vif;
  transaction tr;
  
  
  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     tr = transaction::type_id::create("tr");
      
      if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  
  
  task reset_dut();

    repeat(5) 
    begin
    vif.rst      <= 1'b1;  
    vif.addr     <= 'h0;
    vif.din      <= 'h0;
    vif.wr       <= 1'b0; 
   `uvm_info("DRV", "System Reset : Start of Simulation", UVM_MEDIUM);
    @(posedge vif.clk);
      end
  endtask
  
  task drive();
   //reset_dut();
   forever begin
     
         seq_item_port.get_next_item(tr);
     
                
                   if(tr.op ==  rstdut)
                          begin
                          
                          vif.rst   <= tr.rst;
                          vif.wr    <= tr.wr;
                          vif.addr <= tr.addr;
                          vif.din  <= tr.din;
                           @(posedge vif.clk);
                            `uvm_info("DRV", $sformatf("mode : rst rst:%0d wr:%0d addr:%0d din:%0d", vif.rst,vif.wr,vif.addr,vif.din),UVM_NONE);
                           @(posedge vif.clk);
                          end

                  else if(tr.op == writed)
                          begin
					      vif.rst   <= tr.rst;
                          vif.wr    <= tr.wr;
                          vif.addr <= tr.addr;
                          vif.din  <= tr.din;
                          @(posedge vif.clk);
                            `uvm_info("DRV", $sformatf("mode : Writed rst:%0d wr:%0d addr:%0d din:%0d", vif.rst,vif.wr,vif.addr,vif.din),UVM_NONE);
                          @(posedge vif.done);
                          end
                else if(tr.op ==  readd)
                          begin
					     vif.rst   <= tr.rst;
                          vif.wr    <= tr.wr;
                          vif.addr <= tr.addr;
                          vif.din  <= tr.din;
                          @(posedge vif.clk);
                            `uvm_info("DRV", $sformatf("mode : readd rst:%0d wr:%0d addr:%0d din:%0d", vif.rst,vif.wr,vif.addr,vif.din),UVM_NONE);
                          @(posedge vif.done);
                          end
       seq_item_port.item_done();
     
   end
  endtask
  

  virtual task run_phase(uvm_phase phase);
    drive();
  endtask

  
endclass

//////////////////////////////////////////////////////////////////////////////////////////////

class mon extends uvm_monitor;
`uvm_component_utils(mon)

uvm_analysis_port#(transaction) send;
transaction tr;
virtual spi_i vif;

    function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
      if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))
        `uvm_error("MON","Unable to access Interface");
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if(vif.rst)
        begin
        tr.op      = rstdut;
        tr.addr   = vif.addr;
        tr.din    = vif.din;
        tr.dout   = vif.dout;
        tr.err    = vif.err;
        ///for the coverage
        tr.rst    = vif.rst;
        tr.done   = vif.done;
        tr.wr     = vif.wr;
          `uvm_info("MON", $sformatf("rst addr:%0d din:%0d dout:%0d err:%0d",tr.addr,tr.din,tr.dout,tr.err), UVM_NONE); 
       
        send.write(tr);
        end
      else if (!vif.rst && vif.wr)
         begin
          @(posedge vif.done);
          tr.op     = writed;
          tr.addr   = vif.addr;
          tr.din    = vif.din;
          tr.dout   = vif.dout;
          tr.err    = vif.err;
          ///for the coverage
          tr.rst    = vif.rst;
          tr.done   = vif.done;
          tr.wr     = vif.wr;
           `uvm_info("MON", $sformatf("writed addr:%0d din:%0d dout:%0d err:%0d",tr.addr,tr.din,tr.dout,tr.err), UVM_NONE); 
          send.write(tr);
         end
      else if (!vif.rst && !vif.wr)
         begin
          @(posedge vif.done);
          tr.op     = readd;
          tr.addr   = vif.addr;
          tr.din    = vif.din;
          tr.dout   = vif.dout;
          tr.err    = vif.err;
          ///for the coverage
          tr.rst    = vif.rst;
          tr.done   = vif.done;
          tr.wr     = vif.wr;
           `uvm_info("MON", $sformatf("readd addr:%0d din:%0d dout:%0d err:%0d",tr.addr,tr.din,tr.dout,tr.err), UVM_NONE); 
          send.write(tr);
         end
    
    end
   endtask

endclass
//////////////////////////////////////////////////////////////////////////////////////////////////
class spi_cov_subscriber extends uvm_subscriber#(transaction);
  `uvm_component_utils(spi_cov_subscriber)

  transaction tr;
  uvm_analysis_imp#(transaction,spi_cov_subscriber) rec;

  covergroup cg(ref transaction tr);
    option.per_instance = 1;

    addr : coverpoint tr.addr {
      bins non_slv_bin  = { [0:31]   };
      bins slv_error_bin = { [32:255]};
    }

    din  : coverpoint tr.din {
      bins low  = { [0:31]   };
      bins mid  = { [32:127] };
      bins high = { [128:255]};
    }

    dout : coverpoint tr.dout {
      bins low  = { [0:31]   };
      bins mid  = { [32:127] };
      bins high = { [128:255]};
    }

    wr   : coverpoint tr.wr {
      bins low  = {0};
      bins high = {1};
    }

    rst  : coverpoint tr.rst {
      bins low  = {0};
      bins high = {1};
    }

    err  : coverpoint tr.err {
      bins low  = {0};
      bins high = {1};
    }

    done : coverpoint tr.done {
      bins low  = {0};
      bins high = {1};
    }

    // write when addr > 31
    write_rst0_wr1_addrr_high : cross rst, wr, addr {
      ignore_bins rst_high            = binsof(rst)  intersect {1};
      ignore_bins wr_low              = binsof(wr)   intersect {0};
      ignore_bins addr_low_range      = binsof(addr) intersect {[0:31]};
    }

    // write when addr < 31
    write_rst0_wr1_addrr_low : cross rst, wr, addr {
      ignore_bins rst_high            = binsof(rst)  intersect {1};
      ignore_bins wr_low              = binsof(wr)   intersect {0};
      ignore_bins addr_high_range     = binsof(addr) intersect {[32:255]};
    }    

    // read when addr > 31
    read_rst0_wr0_addr_high : cross rst, wr, addr {
      ignore_bins rst_high            = binsof(rst)  intersect {1};
      ignore_bins wr_high             = binsof(wr)   intersect {1};
      ignore_bins addr_low_range      = binsof(addr) intersect {[0:31]};
    }

    
    
    // read when addr < 31
    read_rst0_wr0_addr_low : cross rst, wr, addr {
      ignore_bins rst_high            = binsof(rst)  intersect {1};
      ignore_bins wr_high             = binsof(wr)   intersect {1};
      ignore_bins addr_high_range     = binsof(addr) intersect {[32:255]};
    }

  endgroup

  function new(string name="spi_cov_subscriber", uvm_component parent=null);
    super.new(name, parent);
    cg = new(tr);   
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rec = new("rec", this);
  endfunction

  virtual function void write(transaction t);
    tr = t;         
    cg.sample(); 
  endfunction

endclass





////////////////////////////////////////////////////////////////////////////////////////////
class sco extends uvm_scoreboard;
`uvm_component_utils(sco)

  uvm_analysis_imp#(transaction,sco) recv;
  bit [31:0] arr[32] = '{default:0};
  bit [31:0] addr    = 0;
  bit [31:0] data_rd = 0;
 


    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
    
  virtual function void write(transaction tr);
    if(tr.op == rstdut)
              begin
                `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE);
              end  
    else if (tr.op == writed)
      begin
        if(tr.err == 1'b1)
                begin
                  `uvm_info("SCO", "SLV ERROR during WRITE OP", UVM_NONE);
                end
              else
                begin
                arr[tr.addr] = tr.din;
                  `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, din:%0d arr_wr:%0d",tr.addr,tr.din,  arr[tr.addr]), UVM_NONE);
                end
      end
    else if (tr.op == readd)
      begin
          if(tr.err == 1'b1)
                begin
                  `uvm_info("SCO", "SLV ERROR during READ OP", UVM_NONE);
                end
              else 
                begin
                  data_rd = arr[tr.addr];
                  if (data_rd == tr.dout)
                    `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, dout:%0d",tr.addr,tr.dout), UVM_NONE)
                         else
                           `uvm_info("SCO",$sformatf("TEST FAILED : addr:%0d, dout:%0d data_rd_arr:%0d",tr.addr,tr.dout,data_rd), UVM_NONE) 
                end
 
      end
     
  
    $display("----------------------------------------------------------------");
    endfunction

endclass
//////////////////////////////////////////////////////////////////////////////////////////////
                  
                  
class agent extends uvm_agent;
`uvm_component_utils(agent)
  
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction

 driver d;
 uvm_sequencer#(transaction) seqr;
 mon m;


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   m = mon::type_id::create("m",this);
   d = driver::type_id::create("d",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);

    d.seq_item_port.connect(seqr.seq_item_export);
  
endfunction

endclass

//////////////////////////////////////////////////////////////////////////////////

class env extends uvm_env;
`uvm_component_utils(env)

function new(input string inst = "env", uvm_component c);
super.new(inst,c);
endfunction

agent a;
sco s;
spi_cov_subscriber cov;

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("a",this);
  s = sco::type_id::create("s", this);
  cov=spi_cov_subscriber::type_id::create("cov", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 a.m.send.connect(s.recv);
 a.m.send.connect(cov.rec);

endfunction

endclass

//////////////////////////////////////////////////////////////////////////

class test extends uvm_test;
`uvm_component_utils(test)

function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction

env e;
write_data wdata;
write_err werr;
  
read_data rdata;
read_err rerr;
  
writeb_readb wrrdb;


reset_dut rstdut;  

  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
   wdata  = write_data::type_id::create("wdata");
   werr   = write_err::type_id::create("werr");
   rdata  = read_data::type_id::create("rdata");
   wrrdb  = writeb_readb::type_id::create("wrrdb");
   rerr   = read_err::type_id::create("rerr");
   rstdut = reset_dut::type_id::create("rstdut");
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
rstdut.start(e.a.seqr);
#20;
wrrdb.start(e.a.seqr);
#20;
werr.start(e.a.seqr);
#20;
rerr.start(e.a.seqr);
phase.drop_objection(this);
endtask
endclass

//////////////////////////////////////////////////////////////////////
module tb;
  
  
  spi_i vif();
  
  top dut (.wr(vif.wr), .clk(vif.clk), .rst(vif.rst), .addr(vif.addr), .din(vif.din), .dout(vif.dout), .done(vif.done), .err(vif.err));
  
 bind top assertion dut1 (.wr(vif.wr), .clk(vif.clk), .rst(vif.rst), .addr(vif.addr), .din(vif.din), .dout(vif.dout), .done(vif.done), .err(vif.err));
  
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;

  
  
  initial begin
    uvm_config_db#(virtual spi_i)::set(null, "*", "vif", vif);
    run_test("test");
    
   end
 
 
endmodule
                  
                  



//////////////////////////////////////////////////////////////////////assertions/////////////////////////////////////////////////
module assertion(
    input logic wr, clk, rst,
    input logic [7:0] addr, din,
  input logic [7:0] dout,
  input logic done, err
);

  // 1. wr cannot assert when reset is active
  assert property (@(posedge clk) rst |-> wr == 0)
    else $error("WR asserted during reset at %0t",$time);

  // 2. Valid write must complete
  assert property (@(posedge clk)
      (wr && addr < 32) |-> ##[1:$] done)
    else $error("WRITE did not complete at %0t",$time);

  // 3. Valid read must complete
  assert property (@(posedge clk)(!wr && addr < 32) |-> ##[1:$] done)
    else $error("READ did not complete at %0t",$time);

  // 4. Invalid address must raise error
  assert property (@(posedge clk) addr > 31 |-> ##[1:$] err)
    else $error("ERR not raised on invalid address at %0t",$time);

  // 5. No spurious errors on valid access
  assert property (@(posedge clk) addr < 32 |-> !err)
    else $error("ERR asserted on valid address at %0t",$time);

endmodule

